Docker Compose Load Blancing and Scaling
=========================================

Please finish :doc:`docker-compose` firstly.

In this lab, we will create a web service, try to scale this service, and add load blancer.

``docker-compose.yml`` file, we just use two images.

.. code-block:: bash

  web:
    image: 'dockercloud/hello-world:latest'
  lb:
    image: 'dockercloud/haproxy:latest'
    links:
      - web
    ports:
      - '80:80'
