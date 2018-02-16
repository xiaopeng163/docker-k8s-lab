Multi-Host Networking Overlay with Flannel
==========================================

In the Lab :doc:`docker-etcd`, we use ``etcd`` as management plane and docker build-in overlay network as data plane to show
how containers in different host connect with each other.

This time we will use ``flannel`` to do almost the same thing.

``Flannel`` is created by CoreOS and it is a network fabric for containers, designed for Kubernetes.

Theory of Operation [#f1]_
---------------------------

flannel runs an agent, ``flanneld``, on each host and is responsible for allocating a subnet lease out of a preconfigured address space.
flannel uses ``etcd`` to store the network configuration, allocated subnets, and auxiliary data (such as host's IP).
The forwarding of packets is achieved using one of several strategies that are known as backends.
The simplest backend is udp and uses a TUN device to encapsulate every IP fragment in a UDP packet, forming an overlay network.
The following diagram demonstrates the path a packet takes as it traverses the overlay network:

.. image:: _image/docker-flannel.png

Lab Environment
---------------

Follow :doc:`../lab-environment` and setup two nodes of docker host.


============  ==============  ==============
Hostname      IP              Docker version
============  ==============  ==============
docker-node1  192.168.205.10  1.12.1
docker-node2  192.168.205.11  1.12.1
============  ==============  ==============

Etcd Cluster Setup
-------------------

Just follow :doc:`docker-etcd` to setup two nodes etcd cluster.

When setup is ready, you should see the etcd cluster status as:

.. code-block:: bash

  ubuntu@docker-node2:~/etcd-v3.0.12-linux-amd64$ ./etcdctl cluster-health
  member 21eca106efe4caee is healthy: got healthy result from http://192.168.205.10:2379
  member 8614974c83d1cc6d is healthy: got healthy result from http://192.168.205.11:2379
  cluster is healthy


Install & Configure & Run flannel
---------------------------------

Download flannel both on node1 and node2

.. code-block:: bash

  $ wget https://github.com/coreos/flannel/releases/download/v0.6.2/flanneld-amd64 -O flanneld && chmod 755 flanneld

flannel will read the configuration from etcd ``/coreos.com/network/config`` by default. We will use ``etcdctl`` to set our
configuration to etcd cluster, the configuration is JSON format like that:

.. code-block:: json

  ubuntu@docker-node1:~$ cat > flannel-network-config.json
  {
      "Network": "10.0.0.0/8",
      "SubnetLen": 20,
      "SubnetMin": "10.10.0.0",
      "SubnetMax": "10.99.0.0",
      "Backend": {
          "Type": "vxlan",
          "VNI": 100,
          "Port": 8472
      }
  }
  EOF

For the configuration keys meaning, please go to https://github.com/coreos/flannel for more information. Set the configuration
on host1:

.. code-block:: bash

  ubuntu@docker-node1:~$ cd etcd-v3.0.12-linux-amd64/
  ubuntu@docker-node1:~/etcd-v3.0.12-linux-amd64$ ./etcdctl set /coreos.com/network/config < ../flannel-network-config.json
  {
      "Network": "10.0.0.0/8",
      "SubnetLen": 20,
      "SubnetMin": "10.10.0.0",
      "SubnetMax": "10.99.0.0",
      "Backend": {
          "Type": "vxlan",
          "VNI": 100,
          "Port": 8472
      }
  }

Check the configuration on host2:

.. code-block:: bash

  ubuntu@docker-node2:~/etcd-v3.0.12-linux-amd64$ ./etcdctl get /coreos.com/network/config | jq .
  {
    "Network": "10.0.0.0/8",
    "SubnetLen": 20,
    "SubnetMin": "10.10.0.0",
    "SubnetMax": "10.99.0.0",
    "Backend": {
      "Type": "vxlan",
      "VNI": 100,
      "Port": 8472
    }
  }
  
Start flannel on host1:

.. code-block:: bash

  ubuntu@docker-node1:~$ cd
  ubuntu@docker-node1:~$ nohup sudo ./flanneld -iface=192.168.205.10 &

After that a new interface ``flannel.100`` will be list on the host:

.. code-block:: bash

  flannel.100 Link encap:Ethernet  HWaddr 82:53:2e:6a:a9:43
            inet addr:10.15.64.0  Bcast:0.0.0.0  Mask:255.0.0.0
            inet6 addr: fe80::8053:2eff:fe6a:a943/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:8 overruns:0 carrier:0
            collisions:0 txqueuelen:0
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Before we start flannel on host2, we can check etcd configuration on host2:

.. code-block:: bash

  ubuntu@docker-node2:~/etcd-v3.0.12-linux-amd64$ ./etcdctl ls /coreos.com/network/subnets
  /coreos.com/network/subnets/10.15.64.0-20
  ubuntu@docker-node2:~/etcd-v3.0.12-linux-amd64$ ./etcdctl get /coreos.com/network/subnets/10.15.64.0-20 | jq .
  {
    "PublicIP": "192.168.205.10",
    "BackendType": "vxlan",
    "BackendData": {
      "VtepMAC": "82:53:2e:6a:a9:43"
    }
  }
  
This is the flannel backend information on host1.

Start flannel on host2

.. code-block:: bash

  ubuntu@docker-node2:~$ nohup sudo ./flanneld -iface=192.168.205.11 &

Check the etcd configuration

.. code-block:: bash

  ubuntu@docker-node2:~/etcd-v3.0.12-linux-amd64$ ./etcdctl ls /coreos.com/network/subnets/
  /coreos.com/network/subnets/10.15.64.0-20
  /coreos.com/network/subnets/10.13.48.0-20
  ubuntu@docker-node2:~/etcd-v3.0.12-linux-amd64$ ./etcdctl get /coreos.com/network/subnets/10.13.48.0-20
  {"PublicIP":"192.168.205.11","BackendType":"vxlan","BackendData":{"VtepMAC":"9e:e7:65:f3:9d:31"}}

This also has a new interface created by flannel ``flannel.100``

Restart docker daemon with flannel network
------------------------------------------

Restart docker daemon with Flannel network configuration, execute commands as follows on node1 and node2:

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo service docker stop
  ubuntu@docker-node1:~$ sudo docker ps
  Cannot connect to the Docker daemon. Is the docker daemon running on this host?
  ubuntu@docker-node1:~$ source /run/flannel/subnet.env
  ubuntu@docker-node1:~$ sudo ifconfig docker0 ${FLANNEL_SUBNET}
  ubuntu@docker-node1:~$ sudo docker daemon --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} &

After restarting, the docker daemon will bind docker0 which has a new address. We can check the new configuration with ``sudo docker network inspect bridge``.

Adjust iptables
---------------

Starting from Docker 1.13 default iptables policy for FORWARDING is DROP, so to make sure that containers will receive traffic from another hosts we need to adjust it:

On host1:

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo iptables -P FORWARD ACCEPT

On host2:

.. code-block:: bash

  ubuntu@docker-node2:~$ sudo iptables -P FORWARD ACCEPT

Start Containers
----------------

On host1:

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo docker run -d --name test1  busybox sh -c "while true; do sleep 3600; done"
  ubuntu@docker-node1:~$ sudo docker exec test1 ifconfig
  eth0      Link encap:Ethernet  HWaddr 02:42:0A:0F:40:02
            inet addr:10.15.64.2  Bcast:0.0.0.0  Mask:255.255.240.0
            inet6 addr: fe80::42:aff:fe0f:4002/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
            RX packets:16 errors:0 dropped:0 overruns:0 frame:0
            TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0
            RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)

  lo        Link encap:Local Loopback
            inet addr:127.0.0.1  Mask:255.0.0.0
            inet6 addr: ::1/128 Scope:Host
            UP LOOPBACK RUNNING  MTU:65536  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Oh host2:

.. code-block:: bash

  ubuntu@docker-node2:~$ sudo docker run -d --name test2  busybox sh -c "while true; do sleep 3600; done"
  ubuntu@docker-node2:~$ sudo docker exec test2 ifconfig
  eth0      Link encap:Ethernet  HWaddr 02:42:0A:0D:30:02
            inet addr:10.13.48.2  Bcast:0.0.0.0  Mask:255.255.240.0
            inet6 addr: fe80::42:aff:fe0d:3002/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
            RX packets:8 errors:0 dropped:0 overruns:0 frame:0
            TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0
            RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

  lo        Link encap:Local Loopback
            inet addr:127.0.0.1  Mask:255.0.0.0
            inet6 addr: ::1/128 Scope:Host
            UP LOOPBACK RUNNING  MTU:65536  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Container test1 on host1 ping container test2 on host2

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo docker exec test1 ping google.com
  PING google.com (74.125.68.102): 56 data bytes
  64 bytes from 74.125.68.102: seq=0 ttl=61 time=123.295 ms
  64 bytes from 74.125.68.102: seq=1 ttl=61 time=127.646 ms
  ubuntu@docker-node1:~$ sudo docker exec test1 ping 10.13.48.2
  PING 10.13.48.2 (10.13.48.2): 56 data bytes
  64 bytes from 10.13.48.2: seq=0 ttl=62 time=1.347 ms
  64 bytes from 10.13.48.2: seq=1 ttl=62 time=0.430 ms

Through ``sudo tcpdump -i enp0s8 -n not port 2380`` we can confirm the vxlan tunnel.

.. code-block:: bash

  05:54:43.824182 IP 192.168.205.10.36214 > 192.168.205.11.8472: OTV, flags [I] (0x08), overlay 0, instance 100
  IP 10.15.64.0 > 10.13.48.2: ICMP echo request, id 9728, seq 462, length 64
  05:54:43.880055 IP 192.168.205.10.36214 > 192.168.205.11.8472: OTV, flags [I] (0x08), overlay 0, instance 100
  IP 10.15.64.0 > 10.13.48.2: ICMP echo request, id 11264, seq 245, length 64
  05:54:44.179703 IP 192.168.205.10.36214 > 192.168.205.11.8472: OTV, flags [I] (0x08), overlay 0, instance 100
  IP 10.15.64.0 > 10.13.48.2: ICMP echo request, id 12288, seq 206, length 64

Performance test [#f2]_

Reference
---------

.. [#f1] https://github.com/coreos/flannel
.. [#f2] http://chunqi.li/2015/10/10/Flannel-for-Docker-Overlay-Network/
