# Setup with docker-compose

.. code-block:: bash

    $ docker-compose build
    $ docker-compose up

Then check the app by:

.. code-block:: bash

    ubuntu@docker-host-aws:~/docker-k8s-lab/code/docker/flask-redis$ curl http://127.0.0.1
    Hello Container World! I have been seen 1 times and my hostname is docker-host-aws.
    ubuntu@docker-host-aws:~/docker-k8s-lab/code/docker/flask-redis$ curl http://127.0.0.1
