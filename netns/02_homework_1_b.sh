#!/bin/sh

# To enable outside IPv6 connectivity
sysctl -w net.ipv6.conf.all.forwarding=1

# Topology: 3 switches linked with trunks

# IPAM
PREFIX=2001:470:705c
FIRST=${PREFIX}:8::
SECOND=${PREFIX}:9::
OUTSIDE=${PREFIX}:a::

# Switches

for s in 1 2 3
do
	ovs-vsctl add-br SW$s
done

ip link add eth-sw2-1 type veth peer name eth-sw1-2
ovs-vsctl add-port SW1 eth-sw2-1
ovs-vsctl add-port SW2 eth-sw1-2
ip link add eth-sw3-2 type veth peer name eth-sw2-3
ovs-vsctl add-port SW2 eth-sw3-2
ovs-vsctl add-port SW3 eth-sw2-3

ovs-vsctl set port eth-sw1-2 trunks=10,20
ovs-vsctl set port eth-sw2-1 trunks=10,20
ovs-vsctl set port eth-sw2-3 trunks=10,20
ovs-vsctl set port eth-sw3-2 trunks=10,20
ip l s eth-sw1-2 up
ip l s eth-sw2-1 up
ip l s eth-sw2-3 up
ip l s eth-sw3-2 up

# Routing
ip netns add GW
ip netns exec GW sysctl -w net.ipv4.ip_forward=1
ip netns exec GW sysctl -w net.ipv6.conf.all.forwarding=1
ip link add veth0 type veth peer name eth-GW
ip link set eth-GW up
ip -6 a a ${OUTSIDE}1/64 dev eth-GW
ip -6 r a ${FIRST}/62 via ${OUTSIDE}2
ip link set veth0 netns GW
ip netns exec GW ip link set veth0 up
ip netns exec GW ip -6 a a ${OUTSIDE}2/64 dev veth0
ip netns exec GW ip -6 r a default via ${OUTSIDE}1

ip link add veth1 type veth peer name eth-GW1
ip link set eth-GW1 up
ovs-vsctl add-port SW3 eth-GW1
ovs-vsctl set port eth-GW1 trunks=10,20
ip link set veth1 netns GW
ip netns exec GW ip l set veth1 up
ip netns exec GW ip l a link veth1 name veth1.10 type vlan id 10
ip netns exec GW ip l a link veth1 name veth1.20 type vlan id 20
ip netns exec GW ip l set veth1.10 up
ip netns exec GW ip l set veth1.20 up
ip netns exec GW ip a a 10.0.1.254/24 dev veth1.10
ip netns exec GW ip a a 10.0.2.254/24 dev veth1.20
ip netns exec GW ip -6 a a ${FIRST}254/64 dev veth1.10
ip netns exec GW ip -6 a a ${SECOND}254/64 dev veth1.20

# Hosts
for NET in 1 2
do
	for HOST in 1 2
	do
		ip netns add H$NET$HOST
		ip link add veth0 address 00:00:00:$NET$HOST:$NET$HOST:$NET$HOST type veth peer name eth-H$NET$HOST
		ovs-vsctl add-port SW$NET eth-H$NET$HOST
		ovs-vsctl set port eth-H$NET$HOST tag=${NET}0
		ip link set eth-H$NET$HOST up
		ip link set veth0 netns H$NET$HOST
		ip netns exec H$NET$HOST ip link set veth0 up
		ip netns exec H$NET$HOST ip a a 10.0.$NET.$HOST/24 dev veth0
		ip netns exec H$NET$HOST ip r a default via 10.0.$NET.254
		if [ "$NET" == "1" ]
		then
			ip netns exec H$NET$HOST ip -6 a a ${FIRST}${HOST}/64 dev veth0
			ip netns exec H$NET$HOST ip -6 r a default via ${FIRST}254
		else
			ip netns exec H$NET$HOST ip -6 a a ${SECOND}${HOST}/64 dev veth0
			ip netns exec H$NET$HOST ip -6 r a default via ${SECOND}254
		fi
	done
done

ip netns exec H11 ping -c 4 10.0.1.2
ip netns exec H11 ping -c 4 10.0.1.254
ip netns exec H11 iperf3 -s &
sleep 2
ip netns exec H12 iperf3 -c 10.0.1.1 
killall iperf3

