#!/usr/bin/env python3
from mininet.topo import Topo
from mininet.net import Mininet
from mininet.util import dumpNodeConnections
from mininet.log import setLogLevel
from mininet.net import Mininet
from mininet.node import Node
from mininet.node import Host
from mininet.link import TCLink
from mininet.link import Intf
from mininet.log import setLogLevel, info
from mininet.cli import CLI
from mininet.node import Controller
from mininet.node import RemoteController
from mininet.util import quietRun

def myNetwork():
    info( 'Creating empty network..\n' )
    net = Mininet(topo=None, build=False, link=TCLink)
    sw1 = net.addSwitch('sw1')
    sw2 = net.addSwitch('sw2')
    # Adding hosts
    h1 = net.addHost('host1')
    h2 = net.addHost('host2')
    h3 = net.addHost('host3')
    # Connecting hosts to switches and switch to switch
    net.addLink(h1, sw1)
    net.addLink(h2, sw1)
    net.addLink(h3, sw2)
    net.addLink(sw1, sw2)

    h1.setMAC("00:00:00:00:00:01", h1.name + "-eth0")
    h2.setMAC("00:00:00:00:00:02", h2.name + "-eth0")
    h3.setMAC("00:00:00:00:00:03", h3.name + "-eth0")

    # Connecting switches to external controller
    net.start()
    sw1.cmd('ovs-vsctl set-controller ' +  sw1.name + ' tcp:127.0.0.1:6633 tcp:127.0.0.1:6653')
    sw2.cmd('ovs-vsctl set-controller ' +  sw2.name + ' tcp:127.0.0.1:6653')
    CLI(net)
    net.stop()

#Main
if __name__ == '__main__':
    setLogLevel('info')
    myNetwork()
