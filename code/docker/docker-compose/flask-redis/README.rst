# Setup with no Docker

.. code-block:: bash

    $ sh install.sh
    $ nohup python app.py

Then check the app by:

.. code-block:: bash

    ubuntu@docker-host-aws:~/docker-k8s-lab/code/docker/flask-redis$ curl http://0.0.0.0:5000
    Hello Container World! I have been seen 1 times and my hostname is docker-host-aws.
    ubuntu@docker-host-aws:~/docker-k8s-lab/code/docker/flask-redis$ curl http://0.0.0.0:5000
    Hello Container World! I have been seen 2 times and my hostname is docker-host-aws.
    ubuntu@docker-host-aws:~/docker-k8s-lab/code/docker/flask-redis$ curl http://0.0.0.0:5000
    Hello Container World! I have been seen 3 times and my hostname is docker-host-aws.

