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
                             --amazonec2-ami ami-1b17257b \
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
  aws-swarm-manager   -        amazonec2   Running   tcp://54.183.145.111:2376           v17.10.0-ce 
  ➜  ~

Please pay attention to ``amazonec2-ami``, please chose a ``Ubuntu 16:04``.

After created, We can use ``docker-machine ssh`` to access the host.

.. code-block:: bash

  ➜  ~ docker-machine ssh aws-swarm-manager

  Welcome to Ubuntu 16.04.3 LTS (GNU/Linux 4.4.0-1038-aws x86_64)

  * Documentation:  https://help.ubuntu.com
  * Management:     https://landscape.canonical.com
  * Support:        https://ubuntu.com/advantage

    Get cloud support with Ubuntu Advantage Cloud Guest:
      http://www.ubuntu.com/business/services/cloud

  4 packages can be updated.
  1 update is a security update.
  
  ubuntu@aws-swarm-manager:~$ sudo docker version
  Client:
   Version:      17.10.0-ce
   API version:  1.33
   Go version:   go1.8.3
   Git commit:   f4ffd25
   Built:        Tue Oct 17 19:04:16 2017
   OS/Arch:      linux/amd64
  
  Server:
   Version:      17.10.0-ce
   API version:  1.33 (minimum version 1.12)
   Go version:   go1.8.3
   Git commit:   f4ffd25
   Built:        Tue Oct 17 19:02:56 2017
   OS/Arch:      linux/amd64
   Experimental: false
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
   Version:      17.10.0-ce
   API version:  1.33
   Go version:   go1.8.3
   Git commit:   f4ffd25
   Built:        Tue Oct 17 19:02:56 2017
   OS/Arch:      linux/amd64
  ➜  ~


Reference
---------


.. [#f1] https://docs.docker.com/machine/examples/aws/#/step-1-sign-up-for-aws-and-configure-credentials
.. [#f2] http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/get-set-up-for-amazon-ec2.html
