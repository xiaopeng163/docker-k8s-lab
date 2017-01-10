Kubernetes Architecture Step by Step
====================================

We will have a overview of k8s architecture through this lab step by step.


Prepare Lab Enviroment
-----------------------

We will install kubernetes with Vagrant & CoreOS reference by https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant.html.

.. code-block:: bash

  ➜  vagrant git:(master) vagrant status
  Current machine states:

  e1                        running (virtualbox)
  c1                        running (virtualbox)
  w1                        running (virtualbox)
  w2                        running (virtualbox)
  w3                        running (virtualbox)

  This environment represents multiple VMs. The VMs are all listed
  above with their current state. For more information about a specific
  VM, run `vagrant status NAME`.

One etcd node, one controller node and three worker nodes.

Kubectl version and cluster information

.. code-block:: bash

  ➜  vagrant git:(master) kubectl version
  Client Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.1", GitCommit:"82450d03cb057bab0950214ef122b67c83fb11df", GitTreeState:"clean", BuildDate:"2016-12-14T00:57:05Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"darwin/amd64"}
  Server Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.1+coreos.0", GitCommit:"cc65f5321f9230bf9a3fa171155c1213d6e3480e", GitTreeState:"clean", BuildDate:"2016-12-14T04:08:28Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"linux/amd64"}
  ➜  vagrant git:(master)
  ➜  vagrant git:(master) kubectl get nodes
  NAME           STATUS                     AGE
  172.17.4.101   Ready,SchedulingDisabled   32m
  172.17.4.201   Ready                      32m
  172.17.4.202   Ready                      32m
  172.17.4.203   Ready                      32m
  ➜  vagrant git:(master)
  ➜  kubernetes-101 git:(master) ✗ kubectl cluster-info
  Kubernetes master is running at https://172.17.4.101:443
  Heapster is running at https://172.17.4.101:443/api/v1/proxy/namespaces/kube-system/services/heapster
  KubeDNS is running at https://172.17.4.101:443/api/v1/proxy/namespaces/kube-system/services/kube-dns
  kubernetes-dashboard is running at https://172.17.4.101:443/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard

  To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
  ➜  kubernetes-101 git:(master) ✗

Get the application we will deploy from github:

.. code-block:: bash

  $ git clone https://github.com/xiaopeng163/kubernetes-101

This application is a simple python flask web app with a redis server as backend.

Create Pods
-----------

Use cmd ``kubectl create`` to create a pod through a yml file. Firstly, create a redis server pod.

.. code-block:: bash

  ➜  kubernetes-101 git:(master) ✗ cd Kubernetes
  ➜  Kubernetes git:(master) ✗ ls
  db-pod.yml  db-svc.yml  set.sh      web-pod.yml web-rc.yml  web-svc.yml
  ➜  Kubernetes git:(master) ✗
  ➜  Kubernetes git:(master) ✗ kubectl create -f db-pod.yml
  pod "redis" created
  ➜  Kubernetes git:(master) ✗ kubectl get pods -o wide
  NAME      READY     STATUS    RESTARTS   AGE       IP          NODE
  redis     1/1       Running   0          1m        10.2.26.2   172.17.4.201

It created a pod which running redis, and the pod is on node ``w1``. We can SSH to this node and check the exactly container created
by kubernetes.

.. code-block:: bash

  ➜  vagrant git:(master) vagrant ssh w1
  CoreOS alpha (1164.1.0)
  Last login: Mon Jan  9 06:33:50 2017 from 10.0.2.2
  core@w1 ~ $ docker ps
  CONTAINER ID    IMAGE           COMMAND                  CREATED          STATUS         PORTS    NAMES
  7df09a520c43    redis:latest    "docker-entrypoint.sh"   19 minutes ago   Up 19 minutes           k8s_redis.afd331f6_redis_default_b6c27624-d632-11e6-b809-0800274503e1_fb526620

Next, create a web server pod.

.. code-block:: bash

  ➜  Kubernetes git:(master) ✗ kubectl create -f web-pod.yml
  pod "web" created
  ➜  Kubernetes git:(master) ✗ kubectl get pods -o wide
  NAME      READY     STATUS    RESTARTS   AGE       IP          NODE
  redis     1/1       Running   0          2h        10.2.26.2   172.17.4.201
  web       1/1       Running   0          6m        10.2.14.6   172.17.4.203
  ➜  Kubernetes git:(master) ✗

The web pod is running on node ``w3``.

Create Services
---------------

Now we have two pods, but they do not know each other. If you SSH to the ``w3`` node which ``web`` located on, and access the flask web, it will
return a error.

.. code-block:: bash

  core@w3 ~ $ curl 10.2.14.6:5000
  .....
  .....
  ConnectionError: Error -2 connecting to redis:6379. Name or service not known.

  -->
  core@w3 ~ $

The reason is the ``web`` pod can not resolve the ``redis`` name. We need to create a service.

.. code-block:: bash

  ➜  Kubernetes git:(master) ✗ kubectl create -f db-svc.yml
  service "redis" created
  ➜  Kubernetes git:(master) ✗ kubectl get svc
  NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
  kubernetes   10.3.0.1     <none>        443/TCP    3h
  redis        10.3.0.201   <none>        6379/TCP   42s

After that, go to ``w3`` and access the flask web again, it works!

.. code-block:: bash

  core@w3 ~ $ curl 10.2.14.6:5000
  Hello Container World! I have been seen 1 times.
  core@w3 ~ $ curl 10.2.14.6:5000
  Hello Container World! I have been seen 2 times.
  core@w3 ~ $

At last, we need to access the flask web service from the outside of the kubernetes cluster, that need to create another
service.

.. code-block:: bash

  ➜  Kubernetes git:(master) ✗ kubectl create -f web-svc.yml
  service "web" created
  ➜  Kubernetes git:(master) ✗
  ➜  Kubernetes git:(master) ✗ kubectl get svc
  NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
  kubernetes   10.3.0.1     <none>        443/TCP        3h
  redis        10.3.0.201   <none>        6379/TCP       11m
  web          10.3.0.51    <nodes>       80:32204/TCP   5s
  ➜  Kubernetes git:(master) ✗ curl 172.17.4.203:32204
  Hello Container World! I have been seen 3 times.
  ➜  Kubernetes git:(master) ✗
  ➜  Kubernetes git:(master) ✗ curl 172.17.4.201:32204
  Hello Container World! I have been seen 4 times.
  ➜  Kubernetes git:(master) ✗ curl 172.17.4.202:32204
  Hello Container World! I have been seen 5 times.
  ➜  Kubernetes git:(master) ✗

Now we can access the flask web from the outside, actually from any node.


Scaling Pods with Replication Controller
----------------------------------------

.. code-block:: bash

  ➜  Kubernetes git:(master) ✗ kubectl create -f web-rc.yml
  replicationcontroller "web" created
  ➜  Kubernetes git:(master) ✗ kubectl get pods -o wide
  NAME        READY     STATUS    RESTARTS   AGE       IP          NODE
  redis       1/1       Running   0          3h        10.2.26.2   172.17.4.201
  web         1/1       Running   0          57m       10.2.14.6   172.17.4.203
  web-jlzm4   1/1       Running   0          3m        10.2.71.3   172.17.4.202
  web-sz150   1/1       Running   0          3m        10.2.26.3   172.17.4.201
  ➜  Kubernetes git:(master) ✗

Rolling Update
--------------

To update a service without an outage through rolling update. We will update our flask web container image from 1.0 to 2.0.

.. code-block:: bash

  ➜  kubernetes-101 git:(master) ✗ kubectl get pods
  NAME        READY     STATUS    RESTARTS   AGE
  redis       1/1       Running   0          6h
  web         1/1       Running   0          4h
  web-jlzm4   1/1       Running   0          3h
  web-sz150   1/1       Running   0          3h
  ➜  kubernetes-101 git:(master) ✗ kubectl rolling-update web --image=xiaopeng163/docker-flask-demo:2.0
  Created web-db65f4ce913c452364a2075625221bec
  Scaling up web-db65f4ce913c452364a2075625221bec from 0 to 3, scaling down web from 3 to 0 (keep 3 pods available, do not exceed 4 pods)
  Scaling web-db65f4ce913c452364a2075625221bec up to 1
  Scaling web down to 2
  Scaling web-db65f4ce913c452364a2075625221bec up to 2
  Scaling web down to 1
  Scaling web-db65f4ce913c452364a2075625221bec up to 3
  Scaling web down to 0
  Update succeeded. Deleting old controller: web
  Renaming web to web-db65f4ce913c452364a2075625221bec
  replicationcontroller "web" rolling updated
  ➜  kubernetes-101 git:(master) ✗ kubectl get pods
  NAME                                         READY     STATUS    RESTARTS   AGE
  redis                                        1/1       Running   0          6h
  web-db65f4ce913c452364a2075625221bec-130ll   1/1       Running   0          3m
  web-db65f4ce913c452364a2075625221bec-85365   1/1       Running   0          4m
  web-db65f4ce913c452364a2075625221bec-tsr41   1/1       Running   0          2m
  ➜  kubernetes-101 git:(master) ✗

After update, check the service.

.. code-block:: bash

  ➜  kubernetes-101 git:(master) ✗ for i in `seq 4`; do curl 172.17.4.203:32204; done
  Hello Container World! I have been seen 26 times and my hostname is web-db65f4ce913c452364a2075625221bec-130ll.
  Hello Container World! I have been seen 27 times and my hostname is web-db65f4ce913c452364a2075625221bec-85365.
  Hello Container World! I have been seen 28 times and my hostname is web-db65f4ce913c452364a2075625221bec-130ll.
  Hello Container World! I have been seen 29 times and my hostname is web-db65f4ce913c452364a2075625221bec-130ll.
  ➜  kubernetes-101 git:(master) ✗

We can see it automatically load balanced.


Clear Environment
------------------

.. code-block:: bash

  $ kubectl delete services web
  $ kubectl delete services redis
  $ kubectl delete rc web
  $ kubectl delete pod redis
  $ kubectl delete pod web
