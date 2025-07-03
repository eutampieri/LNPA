# Exercise 1
## Step 0
In the default configuration, we get the following:
```
ubuntu@netprog:~/LNPA/openflow$ sudo ovs-vsctl list controller
_uuid               : f9bbafb8-d334-44cf-803b-bc88ebde4867
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : true
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : other
status              : {sec_since_connect="69", state=ACTIVE}
target              : "tcp:127.0.0.1:6653"
type                : []

_uuid               : 452d7ae8-e43e-4371-b293-f189698c8f88
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : true
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : other
status              : {sec_since_connect="69", state=ACTIVE}
target              : "tcp:127.0.0.1:6653"
type                : []

_uuid               : 2fdbcad1-37eb-4758-bc96-bd6dd95f6f9d
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : true
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : other
status              : {sec_since_connect="69", state=ACTIVE}
target              : "tcp:127.0.0.1:6633"
type                : []
```
This output has two entries for the first switch and one entry for the second switch.

On the first controller:
```
curl http://netprog:8080/stats/role/1
{"1": [{"generation_id": 18446744073709551615, "role": "EQUAL"}]}
```
On the second:
```
curl http://netprog:8081/stats/role/1
{"1": [{"generation_id": 18446744073709551615, "role": "EQUAL"}]}
curl http://netprog:8081/stats/role/2
{"2": [{"generation_id": 18446744073709551615, "role": "EQUAL"}]}
```
All controllers are in the `EQUAL` role for each switch.

## Step 1
```
curl -X POST -d '{
    "dpid": 1,
    "role": "SLAVE"
 }' http://netprog:8081/stats/role
```
## Step 2
```
curl -X POST -d '{
    "dpid": 1,
    "role": "MASTER"
 }' http://netprog:8080/stats/role
```
## Step 3
```
curl -X POST -d '{
    "dpid": 2,
    "role": "MASTER"
 }' http://netprog:8081/stats/role
```
Controller status:
```
ubuntu@netprog:~/LNPA/openflow$ sudo ovs-vsctl list controller
_uuid               : 3f27fd3d-e9bf-4880-a534-97629c2a4cfc
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : true
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : master
status              : {sec_since_connect="34", state=ACTIVE}
target              : "tcp:127.0.0.1:6653"
type                : []

_uuid               : 775a2387-cf75-4c0e-8e8d-2f04b7910c35
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : true
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : master
status              : {sec_since_connect="34", state=ACTIVE}
target              : "tcp:127.0.0.1:6633"
type                : []

_uuid               : 39637903-42a1-47b1-8ae6-9b8b697f30c3
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : true
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : slave
status              : {sec_since_connect="34", state=ACTIVE}
target              : "tcp:127.0.0.1:6653"
type                : []

```
The roles changed from `other` to either `master` or `slave`.
## Step 4
```
mininet> host1 ping host2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=13.2 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=64 time=0.656 ms
64 bytes from 10.0.0.2: icmp_seq=3 ttl=64 time=0.120 ms
64 bytes from 10.0.0.2: icmp_seq=4 ttl=64 time=0.124 ms
^C
--- 10.0.0.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3090ms
rtt min/avg/max/mdev = 0.120/3.521/13.184/5.583 ms
```
Ping works because the switch is connected to a controller that tells it how to handle packets.
```
ubuntu@netprog:~/ryu-venv/ryu/ryu/app$ sudo ovs-ofctl dump-flows sw1
 cookie=0x0, duration=46.749s, table=0, n_packets=5, n_bytes=434, priority=1,in_port="sw1-eth2",dl_src=00:00:00:00:00:02,dl_dst=00:00:00:00:00:01 actions=output:"sw1-eth1"
 cookie=0x0, duration=46.745s, table=0, n_packets=4, n_bytes=336, priority=1,in_port="sw1-eth1",dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:02 actions=output:"sw1-eth2"
 cookie=0x0, duration=108.808s, table=0, n_packets=55, n_bytes=6650, priority=0 actions=CONTROLLER:65535
```
## Step 5
Yes, ping works because the (now offline) controller installed the flow on the switch.

## Step 6
```
mininet> host1 ping host3
PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
From 10.0.0.1 icmp_seq=1 Destination Host Unreachable
From 10.0.0.1 icmp_seq=2 Destination Host Unreachable
From 10.0.0.1 icmp_seq=3 Destination Host Unreachable
^C
--- 10.0.0.3 ping statistics ---
4 packets transmitted, 0 received, +3 errors, 100% packet loss, time 3056ms
```
The ping does not work because the master controller is offline and the slave controller, by definition, has read-only access to the switch.
```
 cookie=0x0, duration=386.579s, table=0, n_packets=9, n_bytes=714, priority=1,in_port="sw1-eth2",dl_src=00:00:00:00:00:02,dl_dst=00:00:00:00:00:01 actions=output:"sw1-eth1"
 cookie=0x0, duration=386.575s, table=0, n_packets=8, n_bytes=616, priority=1,in_port="sw1-eth1",dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:02 actions=output:"sw1-eth2"
 cookie=0x0, duration=448.638s, table=0, n_packets=83, n_bytes=11552, priority=0 actions=CONTROLLER:65535
```
No flows were added.
```
_uuid               : 3f27fd3d-e9bf-4880-a534-97629c2a4cfc
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : true
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : master
status              : {sec_since_connect="254", state=ACTIVE}
target              : "tcp:127.0.0.1:6653"
type                : []

_uuid               : 775a2387-cf75-4c0e-8e8d-2f04b7910c35
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : false
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : []
status              : {last_error="Connection refused", sec_since_connect="254", sec_since_disconnect="105", state=BACKOFF}
target              : "tcp:127.0.0.1:6633"
type                : []

_uuid               : 39637903-42a1-47b1-8ae6-9b8b697f30c3
connection_mode     : []
controller_burst_limit: []
controller_queue_size: []
controller_rate_limit: []
enable_async_messages: []
external_ids        : {}
inactivity_probe    : []
is_connected        : true
local_gateway       : []
local_ip            : []
local_netmask       : []
max_backoff         : []
other_config        : {}
role                : slave
status              : {sec_since_connect="254", state=ACTIVE}
target              : "tcp:127.0.0.1:6653"
type                : []
```
And the switch knows that the controller is offline.
## Step 7
```
curl -X POST -d '{
    "dpid": 1,
    "role": "MASTER"
 }' http://netprog:8081/stats/role
```
## Step 8
```
mininet> host1 ping host3
PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
64 bytes from 10.0.0.3: icmp_seq=1 ttl=64 time=28.3 ms
64 bytes from 10.0.0.3: icmp_seq=2 ttl=64 time=0.597 ms
64 bytes from 10.0.0.3: icmp_seq=3 ttl=64 time=0.121 ms
^C
--- 10.0.0.3 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2012ms
rtt min/avg/max/mdev = 0.121/9.664/28.275/13.161 ms
```
Ping works now, because the switch is now connected to a master controller that adds the flow.
```
ubuntu@netprog:~/ryu-venv/ryu/ryu/app$ sudo ovs-ofctl dump-flows sw1
 cookie=0x0, duration=528.140s, table=0, n_packets=9, n_bytes=714, priority=1,in_port="sw1-eth2",dl_src=00:00:00:00:00:02,dl_dst=00:00:00:00:00:01 actions=output:"sw1-eth1"
 cookie=0x0, duration=528.136s, table=0, n_packets=8, n_bytes=616, priority=1,in_port="sw1-eth1",dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:02 actions=output:"sw1-eth2"
 cookie=0x0, duration=35.274s, table=0, n_packets=4, n_bytes=336, priority=1,in_port="sw1-eth3",dl_src=00:00:00:00:00:03,dl_dst=00:00:00:00:00:01 actions=output:"sw1-eth1"
 cookie=0x0, duration=35.270s, table=0, n_packets=3, n_bytes=238, priority=1,in_port="sw1-eth1",dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:03 actions=output:"sw1-eth3"
 cookie=0x0, duration=590.199s, table=0, n_packets=96, n_bytes=13752, priority=0 actions=CONTROLLER:65535
```
```
 cookie=0x0, duration=61.918s, table=0, n_packets=4, n_bytes=336, priority=1,in_port="sw2-eth1",dl_src=00:00:00:00:00:03,dl_dst=00:00:00:00:00:01 actions=output:"sw2-eth2"
 cookie=0x0, duration=61.906s, table=0, n_packets=3, n_bytes=238, priority=1,in_port="sw2-eth2",dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:03 actions=output:"sw2-eth1"
 cookie=0x0, duration=616.820s, table=0, n_packets=97, n_bytes=14202, priority=0 actions=CONTROLLER:65535
```
