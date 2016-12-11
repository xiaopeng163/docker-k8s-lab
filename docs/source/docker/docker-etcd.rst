Multi-Host Overlay Networking with Etcd
=======================================

Docker has a build-in overlay networking driver, and it is used by default when docker running in swarm mode [#f1]_.

This lab we will not run docker in swarm mode, but use docker engine with external key-value store to do mutli-host
overlay networking.

We chose etcd [#f2]_ as our external key-value store.

Prepare Environment
--------------------

Create a ``etcd`` two node cluster [#f3]_. On docker-node1:

.. code-block:: bash

  ubuntu@docker-node1:~$ wget https://github.com/coreos/etcd/releases/download/v3.0.12/etcd-v3.0.12-linux-amd64.tar.gz
  ubuntu@docker-node1:~$ tar zxvf etcd-v3.0.12-linux-amd64.tar.gz
  ubuntu@docker-node1:~$ cd etcd-v3.0.12-linux-amd64
  ubuntu@docker-node1:~$ nohup ./etcd --name docker-node1 --initial-advertise-peer-urls http://192.168.205.10:2380 \
  --listen-peer-urls http://192.168.205.10:2380 \
  --listen-client-urls http://192.168.205.10:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.205.10:2379 \
  --initial-cluster-token etcd-cluster \
  --initial-cluster docker-node1=http://192.168.205.10:2380,docker-node2=http://192.168.205.11:2380 \
  --initial-cluster-state new&

On docker-node2, start etcd and check cluster status.

.. code-block:: bash

  ubuntu@docker-node2:~$ wget https://github.com/coreos/etcd/releases/download/v3.0.12/etcd-v3.0.12-linux-amd64.tar.gz
  ubuntu@docker-node2:~$ tar zxvf etcd-v3.0.12-linux-amd64.tar.gz
  ubuntu@docker-node2:~$ cd etcd-v3.0.12-linux-amd64/
  ubuntu@docker-node2:~$ nohup ./etcd --name docker-node2 --initial-advertise-peer-urls http://192.168.205.11:2380 \
  --listen-peer-urls http://192.168.205.11:2380 \
  --listen-client-urls http://192.168.205.11:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.205.11:2379 \
  --initial-cluster-token etcd-cluster \
  --initial-cluster docker-node1=http://192.168.205.10:2380,docker-node2=http://192.168.205.11:2380 \
  --initial-cluster-state new&
  ubuntu@docker-node2:~/etcd-v3.0.12-linux-amd64$ ./etcdctl cluster-health
  member 21eca106efe4caee is healthy: got healthy result from http://192.168.205.10:2379
  member 8614974c83d1cc6d is healthy: got healthy result from http://192.168.205.11:2379
  cluster is healthy

Restart docker engine with cluster configuration
------------------------------------------------

on docker-node1

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo service docker stop
  ubuntu@docker-node1:~$ sudo /usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://192.168.205.10:2379 --cluster-advertise=192.168.205.10:2375

On docker-node2

.. code-block:: bash

  ubuntu@docker-node2:~$ sudo service docker stop
  ubuntu@docker-node2:~$ sudo /usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://192.168.205.11:2379 --cluster-advertise=192.168.205.11:2375

Create Overlay Network
-----------------------

On docker-node1

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo docker network ls
  NETWORK ID          NAME                DRIVER              SCOPE
  0e7bef3f143a        bridge              bridge              local
  a5c7daf62325        host                host                local
  3198cae88ab4        none                null                local
  ubuntu@docker-node1:~$ sudo docker network create -d overlay demo
  3d430f3338a2c3496e9edeccc880f0a7affa06522b4249497ef6c4cd6571eaa9
  ubuntu@docker-node1:~$ sudo docker network ls
  NETWORK ID          NAME                DRIVER              SCOPE
  0e7bef3f143a        bridge              bridge              local
  3d430f3338a2        demo                overlay             global
  a5c7daf62325        host                host                local
  3198cae88ab4        none                null                local
  ubuntu@docker-node1:~$ sudo docker network inspect demo
  [
      {
          "Name": "demo",
          "Id": "3d430f3338a2c3496e9edeccc880f0a7affa06522b4249497ef6c4cd6571eaa9",
          "Scope": "global",
          "Driver": "overlay",
          "EnableIPv6": false,
          "IPAM": {
              "Driver": "default",
              "Options": {},
              "Config": [
                  {
                      "Subnet": "10.0.0.0/24",
                      "Gateway": "10.0.0.1/24"
                  }
              ]
          },
          "Internal": false,
          "Containers": {},
          "Options": {},
          "Labels": {}
      }
  ]

On docker-node2, we can see the demo network is added automatically.

.. code-block:: bash

  ubuntu@docker-node2:~$ sudo docker network ls
  NETWORK ID          NAME                DRIVER              SCOPE
  c9947d4c3669        bridge              bridge              local
  3d430f3338a2        demo                overlay             global
  fa5168034de1        host                host                local
  c2ca34abec2a        none                null                local


Start Containers With Overlay Network
--------------------------------------

On docker-node1:

.. code-block:: bash


  ubuntu@docker-node1:~$ sudo docker run -d --name test1 --net demo centos:7 /bin/bash -c "while true; do sleep 3600; done"
  Unable to find image 'centos:7' locally
  7: Pulling from library/centos
  08d48e6f1cff: Pull complete
  Digest: sha256:b2f9d1c0ff5f87a4743104d099a3d561002ac500db1b9bfa02a783a46e0d366c
  Status: Downloaded newer image for centos:7
  a9208a7c6b79e7538846fe83fd0d9f175f4108faea687f0209eccca32d71d148
  ubuntu@docker-node1:~$ sudo docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
  a9208a7c6b79        centos:7            "/bin/bash -c 'while "   6 seconds ago       Up 5 seconds                            test1
  ubuntu@docker-node1:~$

On docker-node2:

.. code-block:: bash

  ubuntu@docker-node2:~$ sudo docker run -d --name test1 --net demo centos:7 /bin/bash -c "while true; do sleep 3600; done"
  Unable to find image 'centos:7' locally
  7: Pulling from library/centos
  08d48e6f1cff: Pull complete
  Digest: sha256:b2f9d1c0ff5f87a4743104d099a3d561002ac500db1b9bfa02a783a46e0d366c
  Status: Downloaded newer image for centos:7
  1d6c1c59171e513a7008b44568d0e34a8e093efe1dc0aa6ec9774fc141538c51
  docker: Error response from daemon: service endpoint with name test1 already exists.
  ubuntu@docker-node2:~$
  ubuntu@docker-node2:~$ sudo docker run -d --name test2 --net demo centos:7 /bin/bash -c "while true; do sleep 3600; done"
  dc62b5bca68ac0276949b5e4571708036fb35d6da2088e226017b9d24859700a
  ubuntu@docker-node2:~$ sudo docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
  dc62b5bca68a        centos:7            "/bin/bash -c 'while "   53 seconds ago      Up 51 seconds                           test2
  ubuntu@docker-node2:~$

We can see that if we create a container named test1, it return an error: test1 already exists. The reason is that the two
hosts share configurations through etcd.

Let check the connectivity.


on docker-node1:

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo docker exec -it test1 bash
  [root@a9208a7c6b79 /]# yum install net-tools -y
  [root@a9208a7c6b79 /]# ifconfig
  eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
          inet 10.0.0.2  netmask 255.255.255.0  broadcast 0.0.0.0
          inet6 fe80::42:aff:fe00:2  prefixlen 64  scopeid 0x20<link>
          ether 02:42:0a:00:00:02  txqueuelen 0  (Ethernet)
          RX packets 15  bytes 1206 (1.1 KiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 8  bytes 648 (648.0 B)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

  eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
          inet 172.18.0.2  netmask 255.255.0.0  broadcast 0.0.0.0
          inet6 fe80::42:acff:fe12:2  prefixlen 64  scopeid 0x20<link>
          ether 02:42:ac:12:00:02  txqueuelen 0  (Ethernet)
          RX packets 12652  bytes 16390036 (15.6 MiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 6791  bytes 370402 (361.7 KiB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

  lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
          inet 127.0.0.1  netmask 255.0.0.0
          inet6 ::1  prefixlen 128  scopeid 0x10<host>
          loop  txqueuelen 1  (Local Loopback)
          RX packets 80  bytes 15743 (15.3 KiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 80  bytes 15743 (15.3 KiB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

on docker-node2:

.. code-block:: bash

  ubuntu@docker-node2:~$ sudo docker exec -it test1 bash
  [root@dc62b5bca68a /]# yum install net-tools -y
  [root@dc62b5bca68a /]# ifconfig
  eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
          inet 10.0.0.3  netmask 255.255.255.0  broadcast 0.0.0.0
          inet6 fe80::42:aff:fe00:3  prefixlen 64  scopeid 0x20<link>
          ether 02:42:0a:00:00:03  txqueuelen 0  (Ethernet)
          RX packets 16  bytes 1276 (1.2 KiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 11  bytes 886 (886.0 B)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

  eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
          inet 172.18.0.2  netmask 255.255.0.0  broadcast 0.0.0.0
          inet6 fe80::42:acff:fe12:2  prefixlen 64  scopeid 0x20<link>
          ether 02:42:ac:12:00:02  txqueuelen 0  (Ethernet)
          RX packets 12679  bytes 16391351 (15.6 MiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 6735  bytes 367657 (359.0 KiB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

  lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
          inet 127.0.0.1  netmask 255.0.0.0
          inet6 ::1  prefixlen 128  scopeid 0x10<host>
          loop  txqueuelen 1  (Local Loopback)
          RX packets 76  bytes 14648 (14.3 KiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 76  bytes 14648 (14.3 KiB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

Container test1 ping test2:

.. code-block:: bash

  [root@a9208a7c6b79 /]# ping 10.0.0.3
  PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
  64 bytes from 10.0.0.3: icmp_seq=1 ttl=64 time=0.627 ms
  64 bytes from 10.0.0.3: icmp_seq=2 ttl=64 time=0.519 ms
  ^C
  --- 10.0.0.3 ping statistics ---
  2 packets transmitted, 2 received, 0% packet loss, time 999ms
  rtt min/avg/max/mdev = 0.519/0.573/0.627/0.054 ms

Analysis
--------

please go to https://www.singlestoneconsulting.com/~/media/files/whitepapers/dockernetworking2.pdf


Reference
---------

.. [#f1] https://docs.docker.com/engine/swarm/swarm-mode/
.. [#f2] https://github.com/coreos/etcd
.. [#f3] https://coreos.com/etcd/docs/latest/op-guide/clustering.html
