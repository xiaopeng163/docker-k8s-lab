Docker Command Line Step by Step
================================

docker pull
------------

``docker pull`` will pull a docker image from image registry, it's docker hub by default.

.. code-block:: bash

  $ docker pull ubuntu:14.04
  14.04: Pulling from library/ubuntu

  04cf3f0e25b6: Pull complete
  d5b45e963ba0: Pull complete
  a5c78fda4e14: Pull complete
  193d4969ca79: Pull complete
  d709551f9630: Pull complete
  Digest: sha256:edb984703bd3e8981ff541a5b9297ca1b81fde6e6e8094d86e390a38ebc30b4d
  Status: Downloaded newer image for ubuntu:14.04

If the image has already on you host.

.. code-block:: bash

  $ docker pull ubuntu:14.04
  14.04: Pulling from library/ubuntu

  Digest: sha256:edb984703bd3e8981ff541a5b9297ca1b81fde6e6e8094d86e390a38ebc30b4d
  Status: Image is up to date for ubuntu:14.04


docker images
-------------

``docker images`` will list all avaiable images on your local host.

.. code-block:: bash

  $ docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  ubuntu              14.04               aae2b63c4946        12 hours ago        187.9 MB
  ubuntu              latest              e4415b714b62        13 days ago         128.1 MB
  centos              7                   0584b3d2cf6d        3 weeks ago         196.5 MB
  centos              latest              0584b3d2cf6d        3 weeks ago         196.5 MB
  hello-world         latest              c54a2cc56cbb        5 months ago        1.848 kB

Delete images

.. code-block:: bash

  $ docker rmi aae2b63c4946
  Untagged: ubuntu:14.04
  Deleted: sha256:aae2b63c49461fcae4962e4a8043f66acf8e3af7e62f5ebceb70b181d8ca01e0
  Deleted: sha256:50a2a0443efd0936b13eebb86f52b85551ad7883e093ba0b5bad14fec6ccf2ee
  Deleted: sha256:9f0ca687b5937f9ac2c9675065b2daf1a6592e8a1e96bce9de46e94f70fbf418
  Deleted: sha256:6e85e9fb34e94d299bb156252c89dfb4dcec65deca5e2471f7e8ba206eba8f8d
  Deleted: sha256:cc4264e967e293d5cc16e5def86a0b3160b7a3d09e7a458f781326cd2cecedb1
  Deleted: sha256:3181634137c4df95685d73bfbc029c47f6b37eb8a80e74f82e01cd746d0b4b66

docker run
----------


Start a container in interactive mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  $ docker run -i --name test3  ubuntu:14.04
  pwd
  /
  ls -l
  total 20
  drwxr-xr-x.   2 root root 4096 Nov 30 08:51 bin
  drwxr-xr-x.   2 root root    6 Apr 10  2014 boot
  drwxr-xr-x.   5 root root  360 Nov 30 09:00 dev
  drwxr-xr-x.   1 root root   62 Nov 30 09:00 etc
  drwxr-xr-x.   2 root root    6 Apr 10  2014 home
  drwxr-xr-x.  12 root root 4096 Nov 30 08:51 lib
  drwxr-xr-x.   2 root root   33 Nov 30 08:51 lib64
  drwxr-xr-x.   2 root root    6 Nov 23 01:30 media
  drwxr-xr-x.   2 root root    6 Apr 10  2014 mnt
  drwxr-xr-x.   2 root root    6 Nov 23 01:30 opt
  dr-xr-xr-x. 131 root root    0 Nov 30 09:00 proc
  drwx------.   2 root root   35 Nov 30 08:51 root
  drwxr-xr-x.   8 root root 4096 Nov 29 20:04 run
  drwxr-xr-x.   2 root root 4096 Nov 30 08:51 sbin
  drwxr-xr-x.   2 root root    6 Nov 23 01:30 srv
  dr-xr-xr-x.  13 root root    0 Sep  4 08:43 sys
  drwxrwxrwt.   2 root root    6 Nov 23 01:32 tmp
  drwxr-xr-x.  10 root root   97 Nov 30 08:51 usr
  drwxr-xr-x.  11 root root 4096 Nov 30 08:51 var

  ifconfig
  eth0      Link encap:Ethernet  HWaddr 02:42:ac:11:00:04
            inet addr:172.17.0.4  Bcast:0.0.0.0  Mask:255.255.0.0
            inet6 addr: fe80::42:acff:fe11:4/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
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
            collisions:0 txqueuelen:0
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

  exit
  $

Start a container in background
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  $ docker run -d --name test3 ubuntu:14.04
  92848c122db630178f85ad29abc560c13b260cc0a8c63d4cbdaa01de5e3d1b42
  $ docker ps -a
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
  92848c122db6        ubuntu:14.04        "/bin/bash"              13 seconds ago      Exited (0) 12 seconds ago                       test3
  8975cb01d142        centos:7            "/bin/bash -c 'while "   24 hours ago        Up 24 hours                                     test2
  4fea95f2e979        centos:7            "/bin/bash -c 'while "   2 days ago          Up 2 days                                       test1
