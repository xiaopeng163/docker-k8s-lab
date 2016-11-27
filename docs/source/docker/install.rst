Installation
=============

Most of the time, we talk about Docker, it means Docker Engine. It's a lightweight and powerful
open source containerization technology combined with a work flow for building and containerizing your applications.


Install Docker Engine on Linux
------------------------------

Host information:

.. code-block:: bash

  $ cat /etc/redhat-release
  CentOS Linux release 7.2.1511 (Core)
  $ uname -a
  Linux ip-172-31-43-155 3.10.0-327.28.2.el7.x86_64 #1 SMP Wed Aug 3 11:11:39 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

Install with scripts [#f1]_:

1. Log into your machine as a user with sudo or root privileges.
Make sure your existing packages are up-to-date.

.. code-block:: bash

  $ sudo yum update


2. Run the Docker installation script.

.. code-block:: bash

  $ curl -fsSL https://get.docker.com/ | sh

This script adds the docker.repo repository and installs Docker.

3. Enable the service.

.. code-block:: bash

  $ sudo systemctl enable docker.service

4. Start the Docker daemon.

.. code-block:: bash

  $ sudo systemctl start docker

5. Verify docker is installed correctly by running a test image in a container.

.. code-block:: bash

  $ sudo docker run --rm hello-world


Install Docker Engine on Mac
----------------------------


Install Docker Engine on Windows
--------------------------------


Docker Version
--------------

.. code-block:: bash

  $ sudo docker version
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


Docker without sudo
--------------------

Because the docker daemon always runs as the root user, so it needs sudo or root to run some docker commands, like:
docker command need sudo

.. code-block:: bash

  $ docker images
  Cannot connect to the Docker daemon. Is the docker daemon running on this host?
  $ sudo docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  hello-world         latest              c54a2cc56cbb        4 months ago        1.848 kB

But you can add your current user to docker group [#f2]_.

.. code-block:: bash

  $ sudo groupadd docker
  groupadd: group 'docker' already exists
  $ sudo gpasswd -a ${USER} docker
  Adding user centos to group docker
  $ sudo service docker restart
  Redirecting to /bin/systemctl restart  docker.service

Then logout current user, and login again. You can use docker command from your current user without sudo now.

.. code-block:: bash

  $ docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  hello-world         latest              c54a2cc56cbb        4 months ago        1.848 kB



.. rubric:: Reference


.. [#f1] https://docs.docker.com/engine/installation/linux/centos/
.. [#f2] http://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo
