# Copyright (C) 2011 Nippon Telegraph and Telephone Corporation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import CONFIG_DISPATCHER, MAIN_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto_v1_3
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet, arp, ipv4
from ryu.lib.packet import ether_types

FRONTEND = ("10.0.0.103", "00:00:01:00:00:03", 8080)
BACKENDS = [
        ("10.0.0.1", "00:00:00:00:00:01"),
        ("10.0.0.2", "00:00:00:00:00:02"),
]
LAST_BACKEND = len(BACKENDS) - 1

def get_backend():
    i = (LAST_BACKEND + 1) % len(BACKENDS)
    return BACKENDS[i]

class SimpleSwitch13(app_manager.RyuApp):
    OFP_VERSIONS = [ofproto_v1_3.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(SimpleSwitch13, self).__init__(*args, **kwargs)
        self.mac_to_port = {}

    @set_ev_cls(ofp_event.EventOFPSwitchFeatures, CONFIG_DISPATCHER)
    def switch_features_handler(self, ev):
        datapath = ev.msg.datapath
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        # install table-miss flow entry
        #
        # We specify NO BUFFER to max_len of the output action due to
        # OVS bug. At this moment, if we specify a lesser number, e.g.,
        # 128, OVS will send Packet-In with invalid buffer_id and
        # truncated packet data. In that case, we cannot output packets
        # correctly.  The bug has been fixed in OVS v2.1.0.
        match = parser.OFPMatch()
        actions = [parser.OFPActionOutput(ofproto.OFPP_CONTROLLER,
                                          ofproto.OFPCML_NO_BUFFER)]
        self.add_flow(datapath, 0, match, actions)

    def add_flow(self, datapath, priority, match, actions, buffer_id=None):
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        inst = [parser.OFPInstructionActions(ofproto.OFPIT_APPLY_ACTIONS,
                                             actions)]
        if buffer_id:
            mod = parser.OFPFlowMod(datapath=datapath, buffer_id=buffer_id,
                                    priority=priority, match=match,
                                    instructions=inst)
        else:
            mod = parser.OFPFlowMod(datapath=datapath, priority=priority,
                                    match=match, instructions=inst)
        datapath.send_msg(mod)

    @set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
    def _packet_in_handler(self, ev):
        # If you hit this you might want to increase
        # the "miss_send_length" of your switch
        if ev.msg.msg_len < ev.msg.total_len:
            self.logger.debug("packet truncated: only %s of %s bytes",
                              ev.msg.msg_len, ev.msg.total_len)
        msg = ev.msg
        datapath = msg.datapath
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser
        in_port = msg.match['in_port']

        pkt = packet.Packet(msg.data)
        eth = pkt.get_protocols(ethernet.ethernet)[0]

        if eth.ethertype == ether_types.ETH_TYPE_LLDP:
            # ignore lldp packet
            return
        elif eth.ethertype == ether_types.ETH_TYPE_ARP:
            arp_req = pkt.get_protocols(arp.arp)[0]

            # Check if the requested IP is one of the load balancer's IPs
            if arp_req.dst_ip == FRONTEND[0]:  # Check if the target IP matches the load balancer's IP
                # Create ARP reply
                arp_reply = arp.arp(
                    opcode=arp.ARP_REPLY,
                    src_mac=FRONTEND[1],  # Load balancer's MAC
                    src_ip=FRONTEND[0],   # Load balancer's IP
                    dst_mac=arp_req.src_mac,  # Source MAC from the ARP request
                    dst_ip=arp_req.src_ip  # Source IP from the ARP request
                )

                # Create Ethernet frame for the ARP reply
                eth_reply = ethernet.ethernet(
                    ethertype=ether_types.ETH_TYPE_ARP,
                    src=FRONTEND[1],
                    dst=arp_req.src_mac
                )

                # Create a new packet with the Ethernet and ARP layers
                pkt_reply = packet.Packet()
                pkt_reply.add_protocol(eth_reply)
                pkt_reply.add_protocol(arp_reply)
                pkt_reply.serialize()

                # Send the ARP reply
                actions = [parser.OFPActionOutput(in_port)]
                out = parser.OFPPacketOut(datapath=datapath, buffer_id=ofproto.OFP_NO_BUFFER,
                                           in_port=ofproto.OFPP_CONTROLLER, actions=actions,
                                           data=pkt_reply.data)
                datapath.send_msg(out)
                return

        dst = eth.dst
        src = eth.src

        dpid = format(datapath.id, "d").zfill(16)
        self.mac_to_port.setdefault(dpid, {})

        self.logger.info("packet in %s %s %s %s", dpid, src, dst, in_port)

        # provisional
        out_port = ofproto.OFPP_FLOOD
        actions = []

        # Load balancing
        if dst == FRONTEND[1] and eth.ethertype == ether_types.ETH_TYPE_IP:
            ip_pkt = pkt.get_protocols(ipv4.ipv4)[0]
            # Change:
            # - DST IP
            # - DST MAC
            # Set out port
            # Build symmetrical rule

            print("Establishing redirect")
            dst_ip, dst = get_backend()
            actions.append(parser.OFPActionSetField(eth_dst=dst))
            actions.append(parser.OFPActionSetField(ipv4_dst=dst_ip))

            sym_matcher = parser.OFPMatch(eth_src=dst, eth_dst=src, ipv4_dst=ip_pkt.src, ipv4_src=dst_ip)
            sym_actions = [
                    parser.OFPActionSetField(eth_src=FRONTEND[1]),
                    parser.OFPActionSetField(ipv4_src=FRONTEND[0]),
                    parser.OFPActionOutput(in_port),
            ]
            self.add_flow(datapath, 20, sym_matcher, sym_actions)
            print(sym_matcher)
            
        #else:
        # learn a mac address to avoid FLOOD next time.
        self.mac_to_port[dpid][src] = in_port

        if dst in self.mac_to_port[dpid]:
            out_port = self.mac_to_port[dpid][dst]
        else:
            out_port = ofproto.OFPP_FLOOD

        actions.append(parser.OFPActionOutput(out_port))

        # install a flow to avoid packet_in next time
        if out_port != ofproto.OFPP_FLOOD:
            match = parser.OFPMatch(in_port=in_port, eth_dst=dst, eth_src=src)
            # verify if we have a valid buffer_id, if yes avoid to send both
            # flow_mod & packet_out
            if msg.buffer_id != ofproto.OFP_NO_BUFFER:
                #self.add_flow(datapath, 2, match, actions, msg.buffer_id)
                #return
                pass
            else:
                pass
                #self.add_flow(datapath, 2, match, actions)
        data = None
        if msg.buffer_id == ofproto.OFP_NO_BUFFER:
            data = msg.data

        out = parser.OFPPacketOut(datapath=datapath, buffer_id=msg.buffer_id,
                                  in_port=in_port, actions=actions, data=data)
        datapath.send_msg(out)
