Docker Machine with Amazon AWS
==============================

Sign up for AWS and configure credentials [#f1]_
------------------------------------------------

Get AWS Access Key ID and Secret Access Key from ``IAM``. Please reference AWS documentation. Then chose a Region and Available Zone,
in this lab, we chose ``region=us-west-1`` which means North California, and Avaiable zone is ``a``, please create a subnet in this zone [#f2]_.

Create a docker machine
-----------------------

.. code-block:: bash

  ➜  ~ docker-machine create --driver amazonec2 --amazonec2-region us-west-1 \
                             --amazonec2-zone a --amazonec2-vpc-id vpc-32c73756 \
                             --amazonec2-subnet-id subnet-16c84872 \
                             --amazonec2-ami ami-7790c617 \
                             --amazonec2-access-key $AWS_ACCESS_KEY_ID \
                             --amazonec2-secret-key $AWS_SECRET_ACCESS_KEY \
                             aws-swarm-manager
  Running pre-create checks...
  Creating machine...
  (aws-swarm-manager) Launching instance...
  Waiting for machine to be running, this may take a few minutes...
  Detecting operating system of created instance...
  Waiting for SSH to be available...
  Detecting the provisioner...
  Provisioning with ubuntu(upstart)...
  Installing Docker...
  Copying certs to the local machine directory...
  Copying certs to the remote machine...
  Setting Docker configuration on the remote daemon...
  Checking connection to Docker...
  Docker is up and running!
  To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env aws-swarm-manager
  ➜  ~ docker-machine ls
  NAME                ACTIVE   DRIVER      STATE     URL                         SWARM   DOCKER    ERRORS
  aws-swarm-manager   -        amazonec2   Running   tcp://54.183.145.111:2376           v1.12.5
  ➜  ~

Please pay attention to ``amazonec2-ami``, please chose a ``Ubuntu 14:04``.

After created, We can use ``docker-machine ssh`` to access the host.

.. code-block:: bash

  ➜  ~ docker-machine ssh aws-swarm-manager
  Welcome to Ubuntu 14.04.5 LTS (GNU/Linux 3.13.0-105-generic x86_64)

   * Documentation:  https://help.ubuntu.com/

    System information as of Sun Dec 18 15:45:47 UTC 2016

    System load:  0.56              Processes:              109
    Usage of /:   8.4% of 15.61GB   Users logged in:        0
    Memory usage: 11%               IP address for eth0:    172.31.25.235
    Swap usage:   0%                IP address for docker0: 172.17.0.1

    Graph this data and manage this system at:
      https://landscape.canonical.com/

    Get cloud support with Ubuntu Advantage Cloud Guest:
      http://www.ubuntu.com/business/services/cloud

  New release '16.04.1 LTS' available.
  Run 'do-release-upgrade' to upgrade to it.


  *** System restart required ***
  ubuntu@aws-swarm-manager:~$ sudo docker version
  Client:
   Version:      1.12.5
   API version:  1.24
   Go version:   go1.6.4
   Git commit:   7392c3b
   Built:        Fri Dec 16 02:30:42 2016
   OS/Arch:      linux/amd64

  Server:
   Version:      1.12.5
   API version:  1.24
   Go version:   go1.6.4
   Git commit:   7392c3b
   Built:        Fri Dec 16 02:30:42 2016
   OS/Arch:      linux/amd64
  ubuntu@aws-swarm-manager:~$

You can also use ``docker-machine ip`` to get the ip address of the docker host.

docker local client connect with remote aws docker host
--------------------------------------------------------

Set the docker environment in local host.

.. code-block:: bash

  ➜  ~ docker-machine env aws-swarm-manager
  export DOCKER_TLS_VERIFY="1"
  export DOCKER_HOST="tcp://xx.xx.xx.xx:2376"
  export DOCKER_CERT_PATH="/Users/penxiao/.docker/machine/machines/aws-swarm-manager"
  export DOCKER_MACHINE_NAME="aws-swarm-manager"
  # Run this command to configure your shell:
  # eval $(docker-machine env aws-swarm-manager)
  ➜  ~ eval $(docker-machine env aws-swarm-manager)
  ➜  ~ docker version
  Client:
   Version:      1.12.3
   API version:  1.24
   Go version:   go1.6.3
   Git commit:   6b644ec
   Built:        Thu Oct 27 00:09:21 2016
   OS/Arch:      darwin/amd64
   Experimental: true

  Server:
   Version:      1.12.5
   API version:  1.24
   Go version:   go1.6.4
   Git commit:   7392c3b
   Built:        Fri Dec 16 02:30:42 2016
   OS/Arch:      linux/amd64
  ➜  ~


Reference
---------


.. [#f1] https://docs.docker.com/machine/examples/aws/#/step-1-sign-up-for-aws-and-configure-credentials
.. [#f2] http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/get-set-up-for-amazon-ec2.html
