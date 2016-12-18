Docker Swarm: Create and Scale a Service
=========================================

In this lab we will create a new docker swarm cluster: one manger node and three worker nodes, then
create a service and try to scale it.


Create a Swarm Cluster
----------------------

Based on the lab :doc:`docker-swarm`, create four docker machines and init a swarm cluster.

.. code-block:: bash

  ➜  ~ docker-machine ls
  NAME            ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
  swarm-manager   -        virtualbox   Running   tcp://192.168.99.103:2376           v1.12.5
  swarm-worker1   -        virtualbox   Running   tcp://192.168.99.104:2376           v1.12.5
  swarm-worker2   -        virtualbox   Running   tcp://192.168.99.105:2376           v1.12.5
  swarm-worker3   -        virtualbox   Running   tcp://192.168.99.106:2376           v1.12.5
  ➜  ~

  docker@swarm-manager:~$ docker node ls
  ID                           HOSTNAME       STATUS  AVAILABILITY  MANAGER STATUS
  0skz2g68hb76efq4xknhwsjt9    swarm-worker2  Ready   Active
  2q015a61bl879o6adtlb7kxkl    swarm-worker3  Ready   Active
  2sph1ezrnr5q9vy0683ah3b90 *  swarm-manager  Ready   Active        Leader
  59rzjt0kqbcgw4cz7zsfflk8z    swarm-worker1  Ready   Active
  docker@swarm-manager:~$


Create a Service
----------------

Use ``docker service create`` command on manager node to create a service

.. code-block:: bash

  docker@swarm-manager:~$ docker service create --name myapp --publish 80:80/tcp nginx
  7bb8pgwjky3pg1nfpu44aoyti
  docker@swarm-manager:~$ docker service inspect myapp --pretty
  ID:		7bb8pgwjky3pg1nfpu44aoyti
  Name:		myapp
  Mode:		Replicated
   Replicas:	1
  Placement:
  UpdateConfig:
   Parallelism:	1
   On failure:	pause
  ContainerSpec:
   Image:		nginx
  Resources:
  Ports:
   Protocol = tcp
   TargetPort = 80
   PublishedPort = 80
  docker@swarm-manager:~$

Open the web browser, you will see the nginx page http://192.168.99.103/

Scale a Service
---------------

We can use ``docker service scale`` to scale a service.

.. code-block:: bash

  docker@swarm-manager:~$ docker service scale myapp=2
  myapp scaled to 2
  docker@swarm-manager:~$ docker service inspect myapp --pretty
  ID:		7bb8pgwjky3pg1nfpu44aoyti
  Name:		myapp
  Mode:		Replicated
   Replicas:	2
  Placement:
  UpdateConfig:
   Parallelism:	1
   On failure:	pause
  ContainerSpec:
   Image:		nginx
  Resources:
  Ports:
   Protocol = tcp
   TargetPort = 80
   PublishedPort = 80

In this example, we scale the service to 2 replicas.
