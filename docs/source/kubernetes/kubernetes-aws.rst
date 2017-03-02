Create a Kubernetes Cluster on AWS
==================================

In this tutorial, we will create a Kubernetes Cluster on AWS different A-Zone, and will reference this https://kubernetes.io/docs/admin/multiple-zones/

Please make sure you have installed ``awscli`` (https://aws.amazon.com/cli/)

Create the cluster
-------------------

.. code-block:: bash

    curl -sS https://get.k8s.io | MULTIZONE=true KUBERNETES_PROVIDER=aws KUBE_AWS_ZONE=us-west-2a NUM_NODES=1 bash

This command will create a k8s cluster which include one master node and one worker node.

Add more nodes to the cluster
------------------------------

.. code-block:: bash

    KUBE_USE_EXISTING_MASTER=true MULTIZONE=true KUBERNETES_PROVIDER=aws KUBE_AWS_ZONE=us-west-2b NUM_NODES=2 KUBE_SUBNET_CIDR=172.20.1.0/24 MASTER_INTERNAL_IP=172.20.0.9 kubernetes/cluster/kube-up.sh

This will create two worker nodes in another zone ``us-west-2b``.

Check our cluster
-----------------

.. code-block:: bash

    ➜  ~ kubectl get nodes --show-labels
    NAME                                         STATUS    AGE       LABELS
    ip-172-20-0-157.us-west-2.compute.internal   Ready     1h        beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t2.micro,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2a,kubernetes.io/hostname=ip-172-20-0-157.us-west-2.compute.internal
    ip-172-20-1-145.us-west-2.compute.internal   Ready     1h        beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t2.micro,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2b,kubernetes.io/hostname=ip-172-20-1-145.us-west-2.compute.internal
    ip-172-20-1-194.us-west-2.compute.internal   Ready     1h        beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t2.micro,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2b,kubernetes.io/hostname=ip-172-20-1-194.us-west-2.compute.internal
    ➜  ~

If you want to know what happened during these shell command, please go to https://medium.com/@canthefason/kube-up-i-know-what-you-did-on-aws-93e728d3f56a#.r3ynj2ooe