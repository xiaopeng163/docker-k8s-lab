Bridge Networking
==================

The bridge network represents the docker0 network present in all Docker installations. Unless you specify otherwise with
the ``docker run --network=<NETWORK> option``, the Docker daemon connects containers to this network by default.

There are four importance concepts about bridged networking:

- Docker0 Bridge
- Network Namespace
- Veth Pair
- External Communication


Docker0 bridge
--------------

Through ``docker network`` command we can get more details about the docker0 bridge, and from the output, we can see there is no Container
connected with the bridge now.

.. code-block:: bash

  $ docker network inspect 32b93b141bae
  [
      {
          "Name": "bridge",
          "Id": "32b93b141baeeac8bbf01382ec594c23515719c0d13febd8583553d70b4ecdba",
          "Scope": "local",
          "Driver": "bridge",
          "EnableIPv6": false,
          "IPAM": {
              "Driver": "default",
              "Options": null,
              "Config": [
                  {
                      "Subnet": "172.17.0.0/16",
                      "Gateway": "172.17.0.1"
                  }
              ]
          },
          "Internal": false,
          "Containers": {},
          "Options": {
              "com.docker.network.bridge.default_bridge": "true",
              "com.docker.network.bridge.enable_icc": "true",
              "com.docker.network.bridge.enable_ip_masquerade": "true",
              "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
              "com.docker.network.bridge.name": "docker0",
              "com.docker.network.driver.mtu": "1500"
          },
          "Labels": {}
      }
  ]

You can also see this bridge as a part of a host’s network stack by using the ifconfig/ip command on the host.

.. code-block:: bash

  $ ip link
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
      link/ether 06:95:4a:1f:08:7f brd ff:ff:ff:ff:ff:ff
  3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT
      link/ether 02:42:d6:23:e6:18 brd ff:ff:ff:ff:ff:ff

Because there are no containers running, the bridge ``docker0`` status is down.

You can also use ``brctl`` command to get brige docker0 information

.. code-block:: bash

  $ brctl show
  bridge name     bridge id               STP enabled     interfaces
  docker0         8000.0242d623e618       no              veth6a5ae6f

.. note::

  If you can't find ``brctl`` command, you should install it, for centos, please use ``sudo yum install bridge-utils``.


Veth Pair
---------

Now we create and run a centos7 container:

.. code-block:: bash

  $ docker run -d --name test1 centos:7 /bin/bash -c "while true; do sleep 3600; done"
  $ docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
  4fea95f2e979        centos:7            "/bin/bash -c 'while "   6 minutes ago       Up 6 minutes                            test1

After that we can check the ip interface in the docker host.

.. code-block:: bash

  $ ip li
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
      link/ether 06:95:4a:1f:08:7f brd ff:ff:ff:ff:ff:ff
  3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT
      link/ether 02:42:d6:23:e6:18 brd ff:ff:ff:ff:ff:ff
  15: vethae2abb8@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT
      link/ether e6:97:43:5c:33:a6 brd ff:ff:ff:ff:ff:ff link-netnsid 0

The bridge ``docker0`` is up, and there is a veth pair created, one is in localhost, and another is in container's network namspace.


Network Namespace
------------------

If we add a new network namespace from command line.

.. code-block:: bash

  $ sudo ip netns add demo
  $ ip netns list
  demo
  $ ls /var/run/netns
  demo
  $ sudo ip netns exec demo ip a
  1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

But from the command ``ip netns list``, we can't get the container's network namespace. The reason is because docker deleted all containers network namespaces information from ``/var/run/netns``.

We can get all docker container network namespace from ``/var/run/docker/netns``.


.. code-block:: bash

  $ docker ps -a
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
  4fea95f2e979        centos:7            "/bin/bash -c 'while "   2 hours ago         Up About an hour                        test1
  $ sudo ls -l /var/run/docker/netns
  total 0
  -rw-r--r--. 1 root root 0 Nov 28 05:51 572d8e7abcb2

How to get the detail information (like veth) about the container network namespace?


First we should get the pid of this container process, and get all namespaces about this container.

.. code-block:: bash

  $ docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
  4fea95f2e979        centos:7            "/bin/bash -c 'while "   2 hours ago         Up 2 hours                              test1
  $ docker inspect --format '{{.State.Pid}}' 4f
  3090
  $ sudo ls -l /proc/3090/ns
  total 0
  lrwxrwxrwx. 1 root root 0 Nov 28 05:52 ipc -> ipc:[4026532156]
  lrwxrwxrwx. 1 root root 0 Nov 28 05:52 mnt -> mnt:[4026532154]
  lrwxrwxrwx. 1 root root 0 Nov 28 05:51 net -> net:[4026532159]
  lrwxrwxrwx. 1 root root 0 Nov 28 05:52 pid -> pid:[4026532157]
  lrwxrwxrwx. 1 root root 0 Nov 28 08:02 user -> user:[4026531837]
  lrwxrwxrwx. 1 root root 0 Nov 28 05:52 uts -> uts:[4026532155]

Then restore the network namespace:

.. code-block:: bash


  $ sudo ln -s /proc/3090/ns/net /var/run/netns/3090
  $ ip netns list
  3090
  demo
  $ sudo ip netns exec 3090 ip link
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  26: eth0@if27: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT
      link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0



After all is done, please remove ``/var/run/netns/3090``.


External Communication
----------------------
