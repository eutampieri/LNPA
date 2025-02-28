#!/bin/ash
for s in $(ovs-vsctl list-br)
do
	ovs-vsctl del-br $s
done
for ns in $(ip netns | cut -d' ' -f1)
do
	ip netns d $ns
done
