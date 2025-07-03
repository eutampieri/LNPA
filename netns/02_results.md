# Homework 1 - results

## Hosts spread across nodes
```
PING 10.0.1.2 (10.0.1.2): 56 data bytes
64 bytes from 10.0.1.2: seq=0 ttl=64 time=1.141 ms
64 bytes from 10.0.1.2: seq=1 ttl=64 time=0.107 ms
64 bytes from 10.0.1.2: seq=2 ttl=64 time=0.127 ms
64 bytes from 10.0.1.2: seq=3 ttl=64 time=0.198 ms

--- 10.0.1.2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.107/0.393/1.141 ms
PING 10.0.1.254 (10.0.1.254): 56 data bytes
64 bytes from 10.0.1.254: seq=0 ttl=64 time=3.289 ms
64 bytes from 10.0.1.254: seq=1 ttl=64 time=0.201 ms
64 bytes from 10.0.1.254: seq=2 ttl=64 time=0.186 ms
64 bytes from 10.0.1.254: seq=3 ttl=64 time=0.159 ms

--- 10.0.1.254 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.159/0.958/3.289 ms
-----------------------------------------------------------
Server listening on 5201 (test #1)
-----------------------------------------------------------
Accepted connection from 10.0.1.2, port 55158
Connecting to host 10.0.1.1, port 5201
[  5] local 10.0.1.1 port 5201 connected to 10.0.1.2 port 55168
[  5] local 10.0.1.2 port 55168 connected to 10.0.1.1 port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec  1.19 GBytes  10.2 Gbits/sec                  
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.19 GBytes  10.2 Gbits/sec    0    667 KBytes       
[  5]   1.00-2.00   sec  1.58 GBytes  13.6 Gbits/sec    0    667 KBytes       
[  5]   1.00-2.00   sec  1.58 GBytes  13.5 Gbits/sec                  
[  5]   2.00-3.00   sec  1.66 GBytes  14.2 Gbits/sec                  
[  5]   2.00-3.00   sec  1.66 GBytes  14.2 Gbits/sec    0    667 KBytes       
[  5]   3.00-4.00   sec  1.63 GBytes  14.0 Gbits/sec    0    667 KBytes       
[  5]   3.00-4.00   sec  1.63 GBytes  14.0 Gbits/sec                  
[  5]   4.00-5.00   sec  1.60 GBytes  13.7 Gbits/sec    0    667 KBytes       
[  5]   4.00-5.00   sec  1.60 GBytes  13.7 Gbits/sec                  
[  5]   5.00-6.00   sec  1.29 GBytes  11.1 Gbits/sec                  
[  5]   5.00-6.00   sec  1.29 GBytes  11.1 Gbits/sec    0    667 KBytes       
[  5]   6.00-7.00   sec  1.61 GBytes  13.8 Gbits/sec    0    667 KBytes       
[  5]   6.00-7.00   sec  1.61 GBytes  13.8 Gbits/sec                  
[  5]   7.00-8.00   sec  1.62 GBytes  13.9 Gbits/sec    0    667 KBytes       
[  5]   7.00-8.00   sec  1.62 GBytes  13.9 Gbits/sec                  
[  5]   8.00-9.00   sec  1.61 GBytes  13.8 Gbits/sec    0    667 KBytes       
[  5]   8.00-9.00   sec  1.61 GBytes  13.8 Gbits/sec                  
[  5]   9.00-10.00  sec  1.43 GBytes  12.3 Gbits/sec                  
[  5]  10.00-10.00  sec   128 KBytes  2.65 Gbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-10.00  sec  15.2 GBytes  13.1 Gbits/sec                  receiver
[  5]   9.00-10.00  sec  1.43 GBytes  12.3 Gbits/sec    0    667 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  15.2 GBytes  13.1 Gbits/sec    0             sender
[  5]   0.00-10.00  sec  15.2 GBytes  13.1 Gbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201 (test #2)
-----------------------------------------------------------

iperf Done.
iperf3: interrupt - the server has terminated
```

## Same tenant in the same node
```
PING 10.0.1.2 (10.0.1.2): 56 data bytes
64 bytes from 10.0.1.2: seq=0 ttl=64 time=0.735 ms
64 bytes from 10.0.1.2: seq=1 ttl=64 time=0.121 ms
64 bytes from 10.0.1.2: seq=2 ttl=64 time=0.117 ms
64 bytes from 10.0.1.2: seq=3 ttl=64 time=0.130 ms

--- 10.0.1.2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.117/0.275/0.735 ms
PING 10.0.1.254 (10.0.1.254): 56 data bytes
64 bytes from 10.0.1.254: seq=0 ttl=64 time=1.984 ms
64 bytes from 10.0.1.254: seq=1 ttl=64 time=0.171 ms
64 bytes from 10.0.1.254: seq=2 ttl=64 time=0.217 ms
64 bytes from 10.0.1.254: seq=3 ttl=64 time=0.167 ms

--- 10.0.1.254 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.167/0.634/1.984 ms
-----------------------------------------------------------
Server listening on 5201 (test #1)
-----------------------------------------------------------
Accepted connection from 10.0.1.2, port 40286
Connecting to host 10.0.1.1, port 5201
[  5] local 10.0.1.1 port 5201 connected to 10.0.1.2 port 40296
[  5] local 10.0.1.2 port 40296 connected to 10.0.1.1 port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec  1.32 GBytes  11.3 Gbits/sec                  
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.32 GBytes  11.3 Gbits/sec    0    530 KBytes       
[  5]   1.00-2.00   sec  1.40 GBytes  12.0 Gbits/sec                  
[  5]   1.00-2.00   sec  1.40 GBytes  12.0 Gbits/sec    0    530 KBytes       
[  5]   2.00-3.00   sec  1.37 GBytes  11.7 Gbits/sec                  
[  5]   2.00-3.00   sec  1.37 GBytes  11.7 Gbits/sec    0    530 KBytes       
[  5]   3.00-4.00   sec  1.49 GBytes  12.8 Gbits/sec                  
[  5]   3.00-4.00   sec  1.49 GBytes  12.8 Gbits/sec    0    530 KBytes       
[  5]   4.00-5.00   sec  1.08 GBytes  9.23 Gbits/sec                  
[  5]   4.00-5.00   sec  1.07 GBytes  9.22 Gbits/sec    0    530 KBytes       
[  5]   5.00-6.00   sec  1.42 GBytes  12.2 Gbits/sec                  
[  5]   5.00-6.00   sec  1.42 GBytes  12.2 Gbits/sec    0    530 KBytes       
[  5]   6.00-7.00   sec  1.56 GBytes  13.4 Gbits/sec                  
[  5]   6.00-7.00   sec  1.56 GBytes  13.4 Gbits/sec    0    530 KBytes       
[  5]   7.00-8.00   sec  1.43 GBytes  12.3 Gbits/sec                  
[  5]   7.00-8.00   sec  1.43 GBytes  12.3 Gbits/sec    0    530 KBytes       
[  5]   8.00-9.00   sec  1.48 GBytes  12.8 Gbits/sec                  
[  5]   8.00-9.00   sec  1.48 GBytes  12.8 Gbits/sec    0    530 KBytes       
[  5]   9.00-10.00  sec  1.73 GBytes  14.8 Gbits/sec                  
[  5]  10.00-10.00  sec  1.38 MBytes  10.0 Gbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-10.00  sec  14.3 GBytes  12.3 Gbits/sec                  receiver
[  5]   9.00-10.00  sec  1.73 GBytes  14.8 Gbits/sec    0    530 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  14.3 GBytes  12.3 Gbits/sec    0             sender
[  5]   0.00-10.00  sec  14.3 GBytes  12.3 Gbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201 (test #2)
-----------------------------------------------------------

iperf Done.
iperf3: interrupt - the server has terminated
```

## Results

The latency is lower using the same topology (noticeable especially during the ARP request).
The bandwidth seems to be the same.
