#!/bin/sh

ovs-vsctl add-br SW1
ip netns add GW
ip netns exec GW sysctl -w net.ipv4.ip_forward=1

for NET in 1 2
do
	for HOST in 1 2
	do
		ip netns add H$NET$HOST
		ip link add veth0 address 00:00:00:$NET$HOST:$NET$HOST:$NET$HOST type veth peer name eth-H$NET$HOST
		ovs-vsctl add-port SW1 eth-H$NET$HOST
		ip link set eth-H$NET$HOST up
		ip link set veth0 netns H$NET$HOST
		ip netns exec H$NET$HOST ip link set veth0 up
		ip netns exec H$NET$HOST ip a a 10.0.$NET.$HOST/24 dev veth0
		ip netns exec H$NET$HOST ip r a default via 10.0.$NET.254
	done
	ip link add veth-N$NET type veth peer name eth-GW$NET
	ovs-vsctl add-port SW1 eth-GW$NET
	ip link set eth-GW$NET up
	ip link set veth-N$NET netns GW
	ip netns exec GW ip link set veth-N$NET up
	ip netns exec GW ip a a 10.0.$NET.254/24 dev veth-N$NET
done

