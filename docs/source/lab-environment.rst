Lab Environment Quick Setup
===========================

Please install vagrant before using vagrant files to quick start.

Download link: https://www.vagrantup.com/downloads.html

For what vagrant is and how to use it with virtualbox and vmware fusion, please reference https://www.vagrantup.com/docs/

And please install git if you don't have one on your machine(https://git-scm.com/)

Vagrant with one node docker engine
-----------------------------------

we will use vagrant to create one linux virtual machine and install docker automatically.

.. code-block:: bash

  $ git clone https://github.com/xiaopeng163/docker-k8s-lab
  $ cd docker-k8s-lab/lab/docker/single-node

There are two kinds of Linux, one is Ubuntu16.04, and one is CentOS7, please chose one, for example

.. code-block:: bash

  $ git clone https://github.com/xiaopeng163/docker-k8s-lab
  $ cd docker-k8s-lab/lab/docker/single-node
  $ cd vagrant-centos7
  $ vagrant up

``vagrant up`` will take some time to create a virtual machine, after finished, you can use ``vagrant ssh`` ssh into
this machine. like

.. code-block:: bash

  $ vagrant status
  Current machine states:

  docker-host               running (virtualbox)

  The VM is running. To stop this VM, you can run `vagrant halt` to
  shut it down forcefully, or you can run `vagrant suspend` to simply
  suspend the virtual machine. In either case, to restart it again,
  simply run `vagrant up`.
  $ vagrant ssh
  Last login: Wed Jan 24 14:53:38 2018 from 10.0.2.2
  [vagrant@docker-host ~]$ docker version
  Client:
  Version:	18.01.0-ce
  API version:	1.35
  Go version:	go1.9.2
  Git commit:	03596f5
  Built:	Wed Jan 10 20:07:19 2018
  OS/Arch:	linux/amd64
  Experimental:	false
  Orchestrator:	swarm

  Server:
  Engine:
    Version:	18.01.0-ce
    API version:	1.35 (minimum version 1.12)
    Go version:	go1.9.2
    Git commit:	03596f5
    Built:	Wed Jan 10 20:10:58 2018
    OS/Arch:	linux/amd64
    Experimental:	false


Vagrant with two node docker engine
-----------------------------------

.. code-block:: bash

  $ git clone https://github.com/xiaopeng163/docker-k8s-lab
  $ cd docker-k8s-lab/lab/docker/multi-node/vagrant
  $ vagrant up
  Bringing machine 'docker-node1' up with 'virtualbox' provider...
  Bringing machine 'docker-node2' up with 'virtualbox' provider...
  ==> docker-node1: Importing base box 'ubuntu/xenial64'...
  ==> docker-node1: Matching MAC address for NAT networking...
  ==> docker-node1: Checking if box 'ubuntu/xenial64' is up to date...
  ......

The first time you run ``vagrant up`` will take some time to finished creating the virtual machine, and the time will depend on
your network connection situation.

It will create two ubuntu 16.04 VMs based on the base box from the internet, and provision them.

We can use ``vagrant ssh`` to access each node:

.. code-block:: bash

  $ vagrant status
  Current machine states:

  docker-node1              running (virtualbox)
  docker-node2              running (virtualbox)

  This environment represents multiple VMs. The VMs are all listed
  above with their current state. For more information about a specific
  VM, run `vagrant status NAME`.
  $ vagrant ssh docker-node1
  Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-51-generic x86_64)

   * Documentation:  https://help.ubuntu.com
   * Management:     https://landscape.canonical.com
   * Support:        https://ubuntu.com/advantage

    Get cloud support with Ubuntu Advantage Cloud Guest:
      http://www.ubuntu.com/business/services/cloud

  0 packages can be updated.
  0 updates are security updates.


  Last login: Mon Dec  5 05:46:16 2016 from 10.0.2.2
  ubuntu@docker-node1:~$ docker run -d --name test2 hello-world
  Unable to find image 'hello-world:latest' locally
  latest: Pulling from library/hello-world
  c04b14da8d14: Pull complete
  Digest: sha256:0256e8a36e2070f7bf2d0b0763dbabdd67798512411de4cdcf9431a1feb60fd9
  Status: Downloaded newer image for hello-world:latest
  52af64b1a65e3270cd525095974d70538fa9cf382a16123972312b72e858f57e
  ubuntu@docker-node1:~$


You can play with docker now ~~

If you want to recovery your environment, just:

.. code-block:: bash

  $ vagrant halt
  $ vagrant destroy
  $ vagrant up
