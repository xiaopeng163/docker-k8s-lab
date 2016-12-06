Create a new bridge network and connect with container
=======================================================

Use ``docker network`` command to createa a new bridge network [#f1]_.

.. code-block:: bash

  ubuntu@docker-node2:~$ docker network create -d bridge my-bridge-network
  ca804768e02dd33910116c6fa138f1483e7ff2a2b0e019c440393fa5aa92e6c7
  ubuntu@docker-node2:~$ docker network list
  NETWORK ID          NAME                DRIVER              SCOPE
  bf6bef29b25d        bridge              bridge              local
  8cafd7004f4e        host                host                local
  ca804768e02d        my-bridge-network   bridge              local
  c774e1ac44bb        none                null                local
  ubuntu@docker-node2:~$ ifconfig
  br-ca804768e02d Link encap:Ethernet  HWaddr 02:42:fa:18:d8:a3
            inet addr:172.18.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
            UP BROADCAST MULTICAST  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

  docker0   Link encap:Ethernet  HWaddr 02:42:0e:ae:08:37
            inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
            UP BROADCAST MULTICAST  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
  ubuntu@docker-node2:~$ brctl show
  bridge name	bridge id		STP enabled	interfaces
  br-ca804768e02d		8000.0242fa18d8a3	no
  docker0		8000.02420eae0837	no


Reference
----------

.. [#f1] https://docs.docker.com/engine/reference/commandline/network_create/
