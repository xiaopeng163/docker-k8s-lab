Get Started with Kubeadm
========================

We will create a three nodes kubernetes cluster with ``kubeadm``.

Prepare three vagrant hosts
---------------------------

.. code-block:: bash

  $ git clone https://github.com/xiaopeng163/docker-k8s-lab
  $ cd docker-k8s-lab/lab/k8s/multi-node/vagrant
  $ vagrant up
  $ vagrant status
  Current machine states:

  k8s-master                running (virtualbox)
  k8s-worker1               running (virtualbox)
  k8s-worker2               running (virtualbox)

``docker`` ``kubelet`` ``kubeadm`` ``kubectl`` ``kubernetes-cni`` are already installed on each host.


Initialize master node
--------------------------

Use ``kubeadm init`` command to initialize the master node just like ``docker swarm``.

.. code-block:: bash

  ubuntu@k8s-master:~$ sudo kubeadm init --api-advertise-addresses=192.168.205.10
  [kubeadm] WARNING: kubeadm is in alpha, please do not use it for production clusters.
  [preflight] Running pre-flight checks
  [init] Using Kubernetes version: v1.5.1
  [tokens] Generated token: "af6b44.f383a4116ef0d028"
  [certificates] Generated Certificate Authority key and certificate.
  [certificates] Generated API Server key and certificate
  [certificates] Generated Service Account signing keys
  [certificates] Created keys and certificates in "/etc/kubernetes/pki"
  [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
  [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
  [apiclient] Created API client, waiting for the control plane to become ready
  [apiclient] All control plane components are healthy after 61.784561 seconds
  [apiclient] Waiting for at least one node to register and become ready
  [apiclient] First node is ready after 3.004480 seconds
  [apiclient] Creating a test deployment
  [apiclient] Test deployment succeeded
  [token-discovery] Created the kube-discovery deployment, waiting for it to become ready
  [token-discovery] kube-discovery is ready after 21.503085 seconds
  [addons] Created essential addon: kube-proxy
  [addons] Created essential addon: kube-dns

  Your Kubernetes master has initialized successfully!

  You should now deploy a pod network to the cluster.
  Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
      http://kubernetes.io/docs/admin/addons/

  You can now join any number of machines by running the following on each node:

  kubeadm join --token=af6b44.f383a4116ef0d028 192.168.205.10

Join worker nodes
------------------

Run ``kubeadm join`` on each worker node to join the kubernetes cluster.

.. code-block:: bash

  ubuntu@k8s-worker1:~$ kubeadm join --token=af6b44.f383a4116ef0d028 192.168.205.10
  ubuntu@k8s-worker2:~$ kubeadm join --token=af6b44.f383a4116ef0d028 192.168.205.10

Use ``kubectl get nodes`` to check the cluster information.

.. code-block:: bash

  ubuntu@k8s-master:~$ kubectl get nodes
  NAME          STATUS         AGE
  k8s-master    Ready,master   10m
  k8s-worker1   Ready          1m
  k8s-worker2   Ready          3s
