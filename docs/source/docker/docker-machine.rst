Docker Machine on LocalHost
===========================

On macOS and Windows, docker machine is installed along with other Docker products when you install the Docker Toolbox. For example if you
are using Mac:

.. code-block:: bash

  $ docker-machine -v
  docker-machine version 0.9.0, build 15fd4c7


If you are using other OS and want to install docker machine, please go to https://docs.docker.com/machine/install-machine/ for more details.

For what is docker machine and what docker machine can do, please go to https://docs.docker.com/machine/overview/

Create a machine
-----------------

Docker Machine is a tool for provisioning and managing your Dockerized hosts (hosts with Docker Engine on them).
Typically, you install Docker Machine on your local system. Docker Machine has its own command line client docker-machine and
the Docker Engine client, docker. You can use Machine to install Docker Engine on one or more virtual systems.
These virtual systems can be local (as when you use Machine to install and run Docker Engine in VirtualBox on Mac or Windows)
or remote (as when you use Machine to provision Dockerized hosts on cloud providers). The Dockerized hosts themselves can be
thought of, and are sometimes referred to as, managed “machines” [#f1]_.


For this lab, we will use docker machine on Mac system, and create a docker host with virtualbox dirver.

Before we start, we can use ``ls`` command to check if there is any machine already in our host.

.. code-block:: bash

  $ docker-machine ls
  NAME   ACTIVE   DRIVER   STATE   URL   SWARM   DOCKER   ERRORS

Then create a machine called ``default``.

.. code-block:: bash

  $ docker-machine create -d virtualbox default
  Running pre-create checks...
  Creating machine...
  (default) Copying /Users/penxiao/.docker/machine/cache/boot2docker.iso to /Users/penxiao/.docker/machine/machines/default/boot2docker.iso...
  (default) Creating VirtualBox VM...
  (default) Creating SSH key...
  (default) Starting the VM...
  (default) Check network to re-create if needed...
  (default) Waiting for an IP...
  Waiting for machine to be running, this may take a few minutes...
  Detecting operating system of created instance...
  Waiting for SSH to be available...
  Detecting the provisioner...
  Provisioning with boot2docker...
  Copying certs to the local machine directory...
  Copying certs to the remote machine...
  Setting Docker configuration on the remote daemon...
  Checking connection to Docker...
  Docker is up and running!
  To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env default
  $ docker-machine ls
  NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
  default   -        virtualbox   Running   tcp://192.168.99.100:2376           v1.12.3

How to use the docker host
--------------------------

There are two ways to access the docker host

- ssh into the docker host directly, then paly with docker inside
- use docker client on localhost (outside the docker host) to access the docker engine inside the docker host.

1. SSH into the docker host
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  $ docker-machine ssh default
                         ##         .
                   ## ## ##        ==
                ## ## ## ## ##    ===
            /"""""""""""""""""\___/ ===
       ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
            \______ o           __/
              \    \         __/
               \____\_______/
  _                 _   ____     _            _
  | |__   ___   ___ | |_|___ \ __| | ___   ___| | _____ _ __
  | '_ \ / _ \ / _ \| __| __) / _` |/ _ \ / __| |/ / _ \ '__|
  | |_) | (_) | (_) | |_ / __/ (_| | (_) | (__|   <  __/ |
  |_.__/ \___/ \___/ \__|_____\__,_|\___/ \___|_|\_\___|_|
  Boot2Docker version 1.12.3, build HEAD : 7fc7575 - Thu Oct 27 17:23:17 UTC 2016
  Docker version 1.12.3, build 6b644ec
  docker@default:~$ docker ps
  CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
  docker@default:~$
  docker@default:~$ docker run --rm hello-world
  Unable to find image 'hello-world:latest' locally
  latest: Pulling from library/hello-world
  c04b14da8d14: Pull complete
  Digest: sha256:0256e8a36e2070f7bf2d0b0763dbabdd67798512411de4cdcf9431a1feb60fd9
  Status: Downloaded newer image for hello-world:latest

2. docker client connect with remote docker engine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get the environment commands for your new VM.

.. code-block:: bash

  $ docker-machine env default
  export DOCKER_TLS_VERIFY="1"
  export DOCKER_HOST="tcp://192.168.99.100:2376"
  export DOCKER_CERT_PATH="/Users/penxiao/.docker/machine/machines/default"
  export DOCKER_MACHINE_NAME="default"
  # Run this command to configure your

Connect your docker client CLI to the new machine.

Before and after we run ``eval "$(docker-machine env default)"`` on localhost:

.. code-block:: bash

  $ docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  ubuntu              14.04               aae2b63c4946        5 days ago          188 MB
  mongo               2.6                 1999482cb0a5        6 weeks ago         391 MB
  python              2.7                 6b494b5f019c        3 months ago        676.1 MB
  tutum/nginx         latest              a2e9b71ed366        8 months ago        206.1 MB
  $ eval "$(docker-machine env default)"
  $ docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  hello-world         latest              c54a2cc56cbb        5 months ago        1.848 kB

This sets environment variables for the current shell that the Docker client will read which specify
the TLS settings. You need to do this each time you open a new shell or restart your machine.
You can now run Docker commands on this host.


Reference
----------

.. [#f1] https://docs.docker.com/machine/overview/
