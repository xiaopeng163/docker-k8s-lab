Docker Command Line Step by Step
================================

Docker Images
-------------

Docker images can be pulled from the docker hub, or build from ``Dockerfile``.

docker pull
~~~~~~~~~~~~

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

docker build
~~~~~~~~~~~~

Create a ``Dockerfile`` in current folder.

.. code-block:: bash

  $ more Dockerfile
  FROM        ubuntu:14.04
  MAINTAINER  xiaoquwl@gmail.com
  RUN         apt-get update && apt-get install -y redis-server
  EXPOSE      6379
  ENTRYPOINT  ["/usr/bin/redis-server"]

Use ``docker build`` to create a image.

.. code-block:: bash

  $ docker build -t xiaopeng163/redis:0.1 .
  $ docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  xiaopeng163/redis   0.1                 ccbca61a8ed4        7 seconds ago       212.4 MB
  ubuntu              14.04               3f755ca42730        2 days ago          187.9 MB

docker history
~~~~~~~~~~~~~~

.. code-block:: bash

  $ docker history xiaopeng163/redis:0.1
  IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
  ccbca61a8ed4        2 minutes ago       /bin/sh -c #(nop) ENTRYPOINT ["/usr/bin/redis   0 B
  13d13c016420        2 minutes ago       /bin/sh -c #(nop) EXPOSE 6379/tcp               0 B
  c2675d891098        2 minutes ago       /bin/sh -c apt-get update && apt-get install    24.42 MB
  c3035660ff0c        2 minutes ago       /bin/sh -c #(nop) MAINTAINER xiaoquwl@gmail.c   0 B
  3f755ca42730        2 days ago          /bin/sh -c #(nop)  CMD ["/bin/bash"]            0 B
  <missing>           2 days ago          /bin/sh -c mkdir -p /run/systemd && echo 'doc   7 B
  <missing>           2 days ago          /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$/   1.895 kB
  <missing>           2 days ago          /bin/sh -c rm -rf /var/lib/apt/lists/*          0 B
  <missing>           2 days ago          /bin/sh -c set -xe   && echo '#!/bin/sh' > /u   194.6 kB
  <missing>           2 days ago          /bin/sh -c #(nop) ADD file:b2236d49147fe14d8d   187.7 MB


docker images
~~~~~~~~~~~~~

``docker images`` will list all avaiable images on your local host.

.. code-block:: bash

  $ docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  ubuntu              14.04               aae2b63c4946        12 hours ago        187.9 MB

docker rmi
~~~~~~~~~~

Remove docker images.

.. code-block:: bash

  $ docker rmi aae2b63c4946
  Untagged: ubuntu:14.04
  Deleted: sha256:aae2b63c49461fcae4962e4a8043f66acf8e3af7e62f5ebceb70b181d8ca01e0
  Deleted: sha256:50a2a0443efd0936b13eebb86f52b85551ad7883e093ba0b5bad14fec6ccf2ee
  Deleted: sha256:9f0ca687b5937f9ac2c9675065b2daf1a6592e8a1e96bce9de46e94f70fbf418
  Deleted: sha256:6e85e9fb34e94d299bb156252c89dfb4dcec65deca5e2471f7e8ba206eba8f8d
  Deleted: sha256:cc4264e967e293d5cc16e5def86a0b3160b7a3d09e7a458f781326cd2cecedb1
  Deleted: sha256:3181634137c4df95685d73bfbc029c47f6b37eb8a80e74f82e01cd746d0b4b66


Docker Containers
-----------------


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

Start a container in background using ``xiaopeng163/redis:0.1`` image, and the name of the container is ``demo``.
Through ``docker ps`` we can see all running Containers

.. code-block:: bash

  $ docker run -d --name demo xiaopeng163/redis:0.1
  4791db4ff0ef5a1ad9ff7c405bd7705d95779b2e9209967ffbef66cbaee80f3a
  $ docker ps
  CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS               NAMES
  4791db4ff0ef        xiaopeng163/redis:0.1   "/usr/bin/redis-serve"   5 seconds ago       Up 4 seconds        6379/tcp            demo

stop/remove containers
~~~~~~~~~~~~~~~~~~~~~~

Sometime, we want to manage multiple containers each time,  like ``start``, ``stop``, ``rm``.

Firstly, we can use ``--filter`` to filter out the containers we want to manage.

.. code-block:: bash

  $ docker ps -a --filter "status=exited"
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
  c05d6d379459        centos:7            "/bin/bash -c 'while "   3 days ago          Exited (137) 11 hours ago                       test3
  8975cb01d142        centos:7            "/bin/bash -c 'while "   5 days ago          Exited (137) 3 days ago                         test2

Secondly, we can use ``-q`` option to list only containers ids

.. code-block:: bash

  $ docker ps -aq --filter "status=exited"
  c05d6d379459
  8975cb01d142

At last, we can batch processing these containers, like remove them all or start them all:

.. code-block:: bash

  $ docker rm $(docker ps -aq --filter "status=exited")
  c05d6d379459
  8975cb01d142
