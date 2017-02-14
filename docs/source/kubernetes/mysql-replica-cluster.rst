Setup MySQL Replication Cluster in Kuberntes
============================================

In this tutorial, we will setup a MySQL replication cluster in Kubernetes. MySQL Replication is one of the solutions supported
by MySQL for high availability. 

"Replication enables data from one MySQL database server (the master) to be copied to one or more MySQL database servers (the slaves).
Replication is asynchronous by default; slaves do not need to be connected permanently to receive updates from the master.
Depending on the configuration, you can replicate all databases, selected databases, or even selected tables within a database." [#f1]_
For more information or technical details, please reference the MySQL documentation.


1. Before We Start
-------------------

Because we will use Vagrant [#f2]_ to setup the Kubernetes environment, so please you have installed Vagrant on your host machine, and at
least one virtualization tools such as Oracle VirtualBox or VMware Fusion.

In this tutorial, we will use Vagrant and VirtualBox on Mac OSX.

2. Setup Kubernetes Environment
--------------------------------

There are many ways to setup a Kubernetes cluster, here we chose Vagrant(https://www.vagrantup.com/), and the ``Vagrantfile`` is provided
by CoreOS(https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant.html). Please follow this guide and setup a kubernetes environment
with ``one controller node`` and ``three worker nodes``.

After ``vagrant up``, you can check the environment by these commands:

.. code-block:: bash

    ➜  vagrant git:(master) ✗ vagrant status
    Current machine states:

    e1                        running (virtualbox)
    c1                        running (virtualbox)
    w1                        running (virtualbox)
    w2                        running (virtualbox)
    w3                        running (virtualbox)

    This environment represents multiple VMs. The VMs are all listed
    above with their current state. For more information about a specific
    VM, run `vagrant status NAME`.
    ➜  vagrant git:(master) ✗ kubectl get nodes
    NAME           STATUS                     AGE
    172.17.4.101   Ready,SchedulingDisabled   23m
    172.17.4.201   Ready                      23m
    172.17.4.202   Ready                      23m
    172.17.4.203   Ready                      21m
    ➜  vagrant git:(master) ✗

``e1`` is etcd node, ``c1`` is controller node, and ``w1``, ``w2``, ``w3`` are worker nodes.


3. Prepare MySQL Docker Image
------------------------------

In the tuturial, we will use two Docker images from the Docker Hub, they are ``paulliu/mysql-master:0.1`` for master node and
``paulliu/mysql-slave:0.1`` for slave node.

4. Deploy to Kubernetes
-----------------------

We will deploy a MySQL replication cluster to kubernetes through ``kubectl`` command.

4.1 Deploy MySQL Master
~~~~~~~~~~~~~~~~~~~~~~~

Create replication controller and service for MySQL Master node. The ``yaml`` file we use to create replication controller
and service are:

.. code-block:: yaml
    
    $ more mysql-master-rc.yaml
    apiVersion: v1
    kind: ReplicationController
    metadata:
      name: mysql-master
      labels:
        name: mysql-master
    spec:
      replicas: 1
      selector:
        name: mysql-master
      template:
        metadata:
          labels:
            name: mysql-master
        spec:
          containers:
            - name: master
              image: paulliu/mysql-master:0.1
              ports:
                - containerPort: 3306
              env:
                - name: MYSQL_ROOT_PASSWORD
                  value: "test"
                - name: MYSQL_REPLICATION_USER
                  value: 'demo'
                - name: MYSQL_REPLICATION_PASSWORD
                  value: 'demo'

.. code-block:: bash

    $ more mysql-master-service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: mysql-master
      labels:
        name: mysql-master
    spec:
      ports:
        - port: 3306
          targetPort: 3306
      selector:
          name: mysql-master

Now, we will use ``kubectl`` to create the controller and service

.. code-block:: bash

    $ kubectl create -f mysql-master-rc.yaml
    $ kubectl create -f mysql-master-service.yaml

It will take some time to create the ``pod`` because it need to download the docker image. 

.. code-block:: bash

    $ kubectl get pods
    NAME                 READY     STATUS    RESTARTS   AGE
    mysql-master-95j7d   1/1       Running   0          29m
    $ kubectl get svc
    NAME           CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
    kubernetes     10.3.0.1     <none>        443/TCP    23h
    mysql-master   10.3.0.29    <none>        3306/TCP   25m

4.2 Deploy MySQL Slave
~~~~~~~~~~~~~~~~~~~~~~~

Just like the master node, we will use two yaml files to create replication controller and service for MySQL slave.

.. code-block:: bash

    $ more mysql-slave-rc.yaml
    apiVersion: v1
    kind: ReplicationController
    metadata:
      name: mysql-slave
      labels:
        name: mysql-slave
    spec:
      replicas: 1
      selector:
        name: mysql-slave
      template:
        metadata:
          labels:
            name: mysql-slave
        spec:
          containers:
            - name: slave
              image: paulliu/mysql-slave:0.1
              ports:
                - containerPort: 3306
              env:
                - name: MYSQL_ROOT_PASSWORD
                  value: "test"
                - name: MYSQL_REPLICATION_USER
                  value: 'demo'
                - name: MYSQL_REPLICATION_PASSWORD
                  value: 'demo'

.. code-block:: bash

    $ more mysql-slave-service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: mysql-slave
      labels:
        name: mysql-slave
    spec:
      ports:
        - port: 3306
          targetPort: 3306
      selector:
          name: mysql-slave

After it's done, let's check the status through ``kubectl``.

.. code-block:: bash

    $ kubectl get pods -o wide
    NAME                 READY     STATUS    RESTARTS   AGE       IP          NODE
    mysql-master-95j7d   1/1       Running   0          33m       10.2.64.5   172.17.4.201
    mysql-slave-gr41w    1/1       Running   0          23m       10.2.45.3   172.17.4.202
    $ kubectl get svc
    NAME           CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
    kubernetes     10.3.0.1     <none>        443/TCP    23h
    mysql-master   10.3.0.29    <none>        3306/TCP   28m
    mysql-slave    10.3.0.5     <none>        3306/TCP   22m

5. Test
--------

5.1 Create database on Master
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First, we will check the MySQL status both on master and slave. Let's go to master pod and enter that container to check the status
of MySQL (we can do the same thing to salve node).

.. code-block:: bash

    $ kubectl exec -it mysql-master-95j7d /bin/bash
    root@mysql-master-95j7d:/# mysql -u root -p
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 9
    Server version: 8.0.0-dmr-log MySQL Community Server (GPL)

    Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | mysql              |
    | performance_schema |
    | sys                |
    +--------------------+
    4 rows in set (0.00 sec)

    mysql>

.. note::

    ``mysql-master-95j7d`` is the name of master pod and the root password of MySQL is ``test``.

Then, we will create a database and insert some data into it on MySQL master node.

on master node, we do:

.. code-block:: bash

    mysql> create database demo;
    Query OK, 1 row affected (0.02 sec)

    mysql> use demo;
    Database changed
    mysql> create table user(id int(10), name char(20));
    Query OK, 0 rows affected (0.03 sec)

    mysql> insert into user values(100, 'user1');
    Query OK, 1 row affected (0.00 sec)

    mysql> select * from user;
    +------+-------+
    | id   | name  |
    +------+-------+
    |  100 | user1 |
    +------+-------+
    1 row in set (0.00 sec)

    mysql>


5.1 Check Synchronization on Slave
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to slave node ``kubectl exec -it mysql-slave-gr41w /bin/bash`` and check the data:

.. code-block:: bash

    mysql> show slave status\G;
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 10.3.0.29
                      Master_User: demo
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-master-95j7d-bin.000003
              Read_Master_Log_Pos: 760
                   Relay_Log_File: mysql-slave-gr41w-relay-bin.000005
                    Relay_Log_Pos: 999
            Relay_Master_Log_File: mysql-master-95j7d-bin.000003
                 Slave_IO_Running: Yes
                Slave_SQL_Running: Yes
                  Replicate_Do_DB:
              Replicate_Ignore_DB:
               Replicate_Do_Table:
           Replicate_Ignore_Table:
          Replicate_Wild_Do_Table:
      Replicate_Wild_Ignore_Table:
                       Last_Errno: 0
                       Last_Error:
                     Skip_Counter: 0
              Exec_Master_Log_Pos: 760
                  Relay_Log_Space: 2997386
                  Until_Condition: None
                   Until_Log_File:
                    Until_Log_Pos: 0
               Master_SSL_Allowed: No
               Master_SSL_CA_File:
               Master_SSL_CA_Path:
                  Master_SSL_Cert:
                Master_SSL_Cipher:
                   Master_SSL_Key:
            Seconds_Behind_Master: 0
    Master_SSL_Verify_Server_Cert: No
                    Last_IO_Errno: 0
                    Last_IO_Error:
                   Last_SQL_Errno: 0
                   Last_SQL_Error:
      Replicate_Ignore_Server_Ids:
                 Master_Server_Id: 1
                      Master_UUID: 4e174462-f27d-11e6-b9eb-0a580a024005
                 Master_Info_File: /var/lib/mysql/master.info
                        SQL_Delay: 0
              SQL_Remaining_Delay: NULL
          Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
               Master_Retry_Count: 86400
                      Master_Bind:
          Last_IO_Error_Timestamp:
         Last_SQL_Error_Timestamp:
                   Master_SSL_Crl:
               Master_SSL_Crlpath:
               Retrieved_Gtid_Set:
                Executed_Gtid_Set:
                    Auto_Position: 0
             Replicate_Rewrite_DB:
                     Channel_Name:
               Master_TLS_Version:
    1 row in set (0.00 sec)

    ERROR:
    No query specified

    mysql>
    mysql>
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | demo               |
    | information_schema |
    | mysql              |
    | performance_schema |
    | sys                |
    +--------------------+
    5 rows in set (0.00 sec)

    mysql> use demo;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    Database changed
    mysql> select * from user;
    +------+-------+
    | id   | name  |
    +------+-------+
    |  100 | user1 |
    +------+-------+
    1 row in set (0.00 sec)

    mysql>

We can see that all data are synchronized.


5.3 Replication Controller Scaling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now we have one MySQL master pod and one MySQL slave pod. we can do some scaling, for example, let set MySQL slave node to three.

.. code-block:: bash

    kubectl get pods -o wide
    NAME                 READY     STATUS              RESTARTS   AGE       IP          NODE
    mysql-master-95j7d   1/1       Running             0          1h        10.2.64.5   172.17.4.201
    mysql-slave-4rk62    0/1       ContainerCreating   0          2s        <none>      172.17.4.203
    mysql-slave-9fjkl    0/1       ContainerCreating   0          2s        <none>      172.17.4.201
    mysql-slave-gr41w    1/1       Running             0          50m       10.2.45.3   172.17.4.202

You can see it's creating now, after few time, the nodes will be ready and we can enter one of them to check the MySQL data synchronization.

6. Reference
-------------

.. [#f1] https://dev.mysql.com/doc/refman/5.7/en/replication.html
.. [#f2] https://www.vagrantup.com/
