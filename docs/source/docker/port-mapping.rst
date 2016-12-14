Container Port Mapping in Bridge networking
===========================================

Through :doc:`bridged-network` we know that by default Docker containers can make connections to the outside world,
but the outside world cannot connect to containers. Each outgoing connection will appear to originate from one of
the host machine’s own IP addresses thanks to an iptables masquerading rule on the host machine that the Docker
server creates when it starts: [#f1]_

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo iptables -t nat -L -n
  ...
  Chain POSTROUTING (policy ACCEPT)
  target     prot opt source               destination
  MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
  ...
  ubuntu@docker-node1:~$ ifconfig docker0
  docker0   Link encap:Ethernet  HWaddr 02:42:58:22:4c:30
            inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
            UP BROADCAST MULTICAST  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

  ubuntu@docker-node1:~$

The Docker server creates a ``masquerade`` rule that let containers connect to IP addresses in the outside world.

Bind Container port to the host
--------------------------------

Start a nginx container which export port 80 and 443. we can access the port from inside of the docker host.

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo docker run -d  --name demo nginx
  ubuntu@docker-node1:~$ sudo docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
  b5e53067e12f        nginx               "nginx -g 'daemon off"   8 minutes ago       Up 8 minutes        80/tcp, 443/tcp     demo
  ubuntu@docker-node1:~$ sudo docker inspect --format {{.NetworkSettings.IPAddress}} demo
  172.17.0.2
  ubuntu@docker-node1:~$ curl 172.17.0.2
  <!DOCTYPE html>
  <html>
  <head>
  <title>Welcome to nginx!</title>
  <style>
      body {
          width: 35em;
          margin: 0 auto;
          font-family: Tahoma, Verdana, Arial, sans-serif;
      }
  </style>
  </head>
  <body>
  <h1>Welcome to nginx!</h1>
  <p>If you see this page, the nginx web server is successfully installed and
  working. Further configuration is required.</p>

  <p>For online documentation and support please refer to
  <a href="http://nginx.org/">nginx.org</a>.<br/>
  Commercial support is available at
  <a href="http://nginx.com/">nginx.com</a>.</p>

  <p><em>Thank you for using nginx.</em></p>
  </body>
  </html>

If we want to access the nginx web from outside of the docker host, we must bind the port to docker host like this:

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo docker run -d  -p 80 --name demo nginx
  0fb783dcd5b3010c0ef47e4c929dfe0c9eac8ddec2e5e0470df5529bfd4cb64e
  ubuntu@docker-node1:~$ sudo docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                            NAMES
  0fb783dcd5b3        nginx               "nginx -g 'daemon off"   5 seconds ago       Up 5 seconds        443/tcp, 0.0.0.0:32768->80/tcp   demo
  ubuntu@docker-node1:~$ curl 192.168.205.10:32768
  <!DOCTYPE html>
  <html>
  <head>
  <title>Welcome to nginx!</title>
  <style>
      body {
          width: 35em;
          margin: 0 auto;
          font-family: Tahoma, Verdana, Arial, sans-serif;
      }
  </style>
  </head>
  <body>
  <h1>Welcome to nginx!</h1>
  <p>If you see this page, the nginx web server is successfully installed and
  working. Further configuration is required.</p>

  <p>For online documentation and support please refer to
  <a href="http://nginx.org/">nginx.org</a>.<br/>
  Commercial support is available at
  <a href="http://nginx.com/">nginx.com</a>.</p>

  <p><em>Thank you for using nginx.</em></p>
  </body>
  </html>
  ubuntu@docker-node1:~$ ifconfig enp0s8
  enp0s8    Link encap:Ethernet  HWaddr 08:00:27:7a:ac:d2
            inet addr:192.168.205.10  Bcast:192.168.205.255  Mask:255.255.255.0
            inet6 addr: fe80::a00:27ff:fe7a:acd2/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:0 (0.0 B)  TX bytes:648 (648.0 B)

  ubuntu@docker-node1:~$

If we want to point out which port on host want to bind:

.. code-block:: bash

  ubuntu@docker-node1:~$ sudo docker run -d  -p 80:80 --name demo1 nginx
  4f548139a4be6574e3f9718f99a05e5174bdfb62d229ea656d35a979b5b0507d
  ubuntu@docker-node1:~$ sudo docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                            NAMES
  4f548139a4be        nginx               "nginx -g 'daemon off"   5 seconds ago       Up 4 seconds        0.0.0.0:80->80/tcp, 443/tcp      demo1
  0fb783dcd5b3        nginx               "nginx -g 'daemon off"   2 minutes ago       Up 2 minutes        443/tcp, 0.0.0.0:32768->80/tcp   demo
  ubuntu@docker-node1:~$

What happened
--------------

It's iptables

.. code-block:: bash


  ubuntu@docker-node1:~$ sudo iptables -t nat -L -n
  Chain PREROUTING (policy ACCEPT)
  target     prot opt source               destination
  DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

  Chain INPUT (policy ACCEPT)
  target     prot opt source               destination

  Chain OUTPUT (policy ACCEPT)
  target     prot opt source               destination
  DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

  Chain POSTROUTING (policy ACCEPT)
  target     prot opt source               destination
  MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
  MASQUERADE  tcp  --  172.17.0.2           172.17.0.2           tcp dpt:80
  MASQUERADE  tcp  --  172.17.0.3           172.17.0.3           tcp dpt:80

  Chain DOCKER (2 references)
  target     prot opt source               destination
  RETURN     all  --  0.0.0.0/0            0.0.0.0/0
  DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:32768 to:172.17.0.2:80
  DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:172.17.0.3:80
  ubuntu@docker-node1:~$

  ubuntu@docker-node1:~$ sudo iptables -t nat -nvxL
  Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
      pkts      bytes target     prot opt in     out     source               destination
         1       44 DOCKER     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

  Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
      pkts      bytes target     prot opt in     out     source               destination

  Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
      pkts      bytes target     prot opt in     out     source               destination
         4      240 DOCKER     all  --  *      *       0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

  Chain POSTROUTING (policy ACCEPT 2 packets, 120 bytes)
      pkts      bytes target     prot opt in     out     source               destination
         0        0 MASQUERADE  all  --  *      !docker0  172.17.0.0/16        0.0.0.0/0
         0        0 MASQUERADE  tcp  --  *      *       172.17.0.2           172.17.0.2           tcp dpt:80
         0        0 MASQUERADE  tcp  --  *      *       172.17.0.3           172.17.0.3           tcp dpt:80

  Chain DOCKER (2 references)
      pkts      bytes target     prot opt in     out     source               destination
         0        0 RETURN     all  --  docker0 *       0.0.0.0/0            0.0.0.0/0
         1       60 DNAT       tcp  --  !docker0 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:32768 to:172.17.0.2:80
         2      120 DNAT       tcp  --  !docker0 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:172.17.0.3:80
  ubuntu@docker-node1:~$


References
----------

.. [#f1] https://docs.docker.com/engine/userguide/networking/default_network/binding/
