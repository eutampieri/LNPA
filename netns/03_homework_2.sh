#!/bin/sh

modprobe ip_gre

# Gateways
for g in 1 2 3
do
	ip netns add GW$g
	ip netns exec GW$g sysctl -w net.ipv4.ip_forward=1
done

# Connectivity between GW1 and GW2

ip link add eth-gw1-gw2 type veth peer name eth-gw2-gw1
ip link set eth-gw1-gw2 netns GW1
ip link set eth-gw2-gw1 netns GW2
ip netns exec GW1 ip l set eth-gw1-gw2 up
ip netns exec GW1 ip a a 10.0.10.1/30 dev eth-gw1-gw2
ip netns exec GW2 ip l set eth-gw2-gw1 up
ip netns exec GW2 ip a a 10.0.10.2/30 dev eth-gw2-gw1

# Connectivity between GW2 and GW3

ip link add eth-gw2-gw3 type veth peer name eth-gw3-gw2
ip link set eth-gw2-gw3 netns GW2
ip link set eth-gw3-gw2 netns GW3
ip netns exec GW2 ip l set eth-gw2-gw3 up
ip netns exec GW2 ip a a 10.0.10.5/30 dev eth-gw2-gw3
ip netns exec GW3 ip l set eth-gw3-gw2 up
ip netns exec GW3 ip a a 10.0.10.6/30 dev eth-gw3-gw2

# Routing table

ip netns exec GW1 ip r a 10.0.10.4/30 via 10.0.10.2
ip netns exec GW3 ip r a 10.0.10.0/30 via 10.0.10.5

# Connectivity check
ip netns exec GW1 ping -c 4 10.0.10.6
ip netns exec GW3 ping -c 4 10.0.10.1

# Tunneling
ip netns exec GW1 ip tunnel add G1 mode gre remote 10.0.10.6 local 10.0.10.1 ttl 63
ip netns exec GW1 ip l set G1 up
#ip netns exec GW1 ip a a 10.0.11.1 dev G1
ip netns exec GW3 ip tunnel add G1 mode gre remote 10.0.10.1 local 10.0.10.6 ttl 63
ip netns exec GW3 ip l set G1 up
#ip netns exec GW3 ip a a 10.0.11.2 dev G1

# Management L2 tunneling
# ip netns exec GW1 ip tunnel add V1 type vxlan id 100 local 10.0.10.1 remote 10.0.10.6 nolearning dstport 4789
# ip netns exec GW3 ip tunnel add V1 type vxlan id 100 local 10.0.10.6 remote 10.0.10.1 nolearning dstport 4789

# Switches

for s in 1 2
do
	ovs-vsctl add-br SW$s
done

ip link add eth-sw1-gw1 type veth peer name eth-gw1-sw1
ovs-vsctl add-port SW1 eth-sw1-gw1
ip link set eth-sw1-gw1 up
ip link set eth-gw1-sw1 netns GW1
ip netns exec GW1 ip l set eth-gw1-sw1 up
ip netns exec GW1 ip a a 10.0.1.254/24 dev eth-gw1-sw1
ip netns exec GW1 ip r a 10.0.2.0/24 dev G1

ip link add eth-sw2-gw3 type veth peer name eth-gw3-sw2
ovs-vsctl add-port SW2 eth-sw2-gw3
ip link set eth-sw2-gw3 up
ip link set eth-gw3-sw2 netns GW3
ip netns exec GW3 ip l set eth-gw3-sw2 up
ip netns exec GW3 ip a a 10.0.2.254/24 dev eth-gw3-sw2
ip netns exec GW3 ip r a 10.0.1.0/24 dev G1

#ovs-vsctl set port eth-sw1-2 trunks=10,20
#ovs-vsctl set port eth-sw2-1 trunks=10,20
#ovs-vsctl set port eth-sw2-3 trunks=10,20
#ovs-vsctl set port eth-sw3-2 trunks=10,20
#ip l s eth-sw1-2 up
#ip l s eth-sw2-1 up
#ip l s eth-sw2-3 up
#ip l s eth-sw3-2 up

# Hosts
for HOST in 1 2
do
	ip netns add H$HOST
	ip link add veth0 address 00:00:00:0$HOST:0$HOST:0$HOST type veth peer name eth-H$HOST
	ovs-vsctl add-port SW$HOST eth-H$HOST
	#ovs-vsctl set port eth-H$HOST
	ip link set eth-H$HOST up
	ip link set veth0 netns H$HOST
	ip netns exec H$HOST ip link set veth0 up
	ip netns exec H$HOST ip a a 10.0.$HOST.1/24 dev veth0
	ip netns exec H$HOST ip r a default via 10.0.$HOST.254
done

ip netns exec H1 traceroute 10.0.2.1
ip netns exec H2 traceroute 10.0.1.1
ip netns exec H1 ping -c 4 10.0.1.254

