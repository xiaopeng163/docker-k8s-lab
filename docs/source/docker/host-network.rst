Host Network Deep Dive
======================

In host network mode, the container and the host will be in the same network namespace.

Docker version for this lab:

.. code-block:: bash

  $ docker version
  Client:
   Version:      1.11.2
   API version:  1.23
   Go version:   go1.5.4
   Git commit:   b9f10c9
   Built:        Wed Jun  1 21:23:11 2016
   OS/Arch:      linux/amd64

  Server:
   Version:      1.11.2
   API version:  1.23
   Go version:   go1.5.4
   Git commit:   b9f10c9
   Built:        Wed Jun  1 21:23:11 2016
   OS/Arch:      linux/amd64
   docker
   
Start a container in host network mode with ``--net=host``.

.. code-block:: bash

  $ docker run -d --name test3 --net=host centos:7 /bin/bash -c "while true; do sleep 3600; done"
  c05d6d379459a651dbd6a98606328236063c541842db5e456767c219e2c52716
  $ ip link
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
      link/ether 06:95:4a:1f:08:7f brd ff:ff:ff:ff:ff:ff
  3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT
      link/ether 02:42:d6:23:e6:18 brd ff:ff:ff:ff:ff:ff
  $ docker network inspect host
  [
      {
          "Name": "host",
          "Id": "c363d9a92877e78cb33e7e5dd7884babfd6d05ae2100162fca21f756fe340b79",
          "Scope": "local",
          "Driver": "host",
          "EnableIPv6": false,
          "IPAM": {
              "Driver": "default",
              "Options": null,
              "Config": []
          },
          "Internal": false,
          "Containers": {
              "c05d6d379459a651dbd6a98606328236063c541842db5e456767c219e2c52716": {
                  "Name": "test3",
                  "EndpointID": "929c58100f6e4356eadccbe2f44bf1ce40567763594266831259d012cd76e4d6",
                  "MacAddress": "",
                  "IPv4Address": "",
                  "IPv6Address": ""
              }
          },
          "Options": {},
          "Labels": {}
      }
  ]

Unlike bridge network mode, there is no veth pair. Go to the inside of the container.

.. code-block:: bash

  $ docker exec -it test3 bash
  # yum install net-tools -y
  # ifconfig
  docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
          inet 172.17.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
          inet6 fe80::42:d6ff:fe23:e618  prefixlen 64  scopeid 0x20<link>
          ether 02:42:d6:23:e6:18  txqueuelen 0  (Ethernet)
          RX packets 6624  bytes 359995 (351.5 KiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 11019  bytes 16432384 (15.6 MiB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

  eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9001
          inet 172.31.43.155  netmask 255.255.240.0  broadcast 172.31.47.255
          inet6 fe80::495:4aff:fe1f:87f  prefixlen 64  scopeid 0x20<link>
          ether 06:95:4a:1f:08:7f  txqueuelen 1000  (Ethernet)
          RX packets 1982838  bytes 765628507 (730.1 MiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 2689881  bytes 330857410 (315.5 MiB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

  lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
          inet 127.0.0.1  netmask 255.0.0.0
          inet6 ::1  prefixlen 128  scopeid 0x10<host>
          loop  txqueuelen 0  (Local Loopback)
          RX packets 6349  bytes 8535636 (8.1 MiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 6349  bytes 8535636 (8.1 MiB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
  # ping www.google.com
  PING www.google.com (172.217.3.196) 56(84) bytes of data.
  64 bytes from sea15s12-in-f196.1e100.net (172.217.3.196): icmp_seq=1 ttl=43 time=7.34 ms
  64 bytes from sea15s12-in-f4.1e100.net (172.217.3.196): icmp_seq=2 ttl=43 time=7.35 ms
  ^C
  --- www.google.com ping statistics ---
  2 packets transmitted, 2 received, 0% packet loss, time 1001ms
  rtt min/avg/max/mdev = 7.342/7.346/7.350/0.004 ms

The container has the same ip/mac address as the host. we see that when using host mode networking,
the container effectively inherits the IP address from its host. This mode is faster than the bridge
mode (because there is no routing overhead), but it exposes the container directly to the public network,
with all its security implications [#f1]_.




Reference
----------

.. [#f1] https://www.oreilly.com/learning/what-is-docker-networking
