Docker Compose Load Blancing and Scaling
=========================================

Please finish :doc:`docker-compose` firstly.

In this lab, we will create a web service, try to scale this service, and add load blancer.

``docker-compose.yml`` file, we just use two images.

.. code-block:: bash

  $ more docker-compose.yml
  web:
    image: 'jwilder/whoami'
  lb:
    image: 'dockercloud/haproxy:latest'
    links:
      - web
    ports:
      - '80:80'

Start and check the service.

.. code-block:: bash

  $ docker-compose up
  $ docker-compose up -d
  Creating ubuntu_web_1
  Creating ubuntu_lb_1
  $ docker-compose ps
      Name                  Command               State                   Ports
  ---------------------------------------------------------------------------------------------
  ubuntu_lb_1    /sbin/tini -- dockercloud- ...   Up      1936/tcp, 443/tcp, 0.0.0.0:80->80/tcp
  ubuntu_web_1   /bin/sh -c php-fpm -d vari ...   Up      80/tcp

Open the browser and check the hostname.

Scale the web service to 2 and check:

.. code-block:: bash

  $ docker-compose scale web=3
  Creating and starting ubuntu_web_2 ... done
  Creating and starting ubuntu_web_3 ... done
  ubuntu@aws-swarm-manager:~$ docker-compose ps
      Name                  Command               State                   Ports
  ---------------------------------------------------------------------------------------------
  ubuntu_lb_1    /sbin/tini -- dockercloud- ...   Up      1936/tcp, 443/tcp, 0.0.0.0:80->80/tcp
  ubuntu_web_1   /bin/sh -c php-fpm -d vari ...   Up      80/tcp
  ubuntu_web_2   /bin/sh -c php-fpm -d vari ...   Up      80/tcp
  ubuntu_web_3   /bin/sh -c php-fpm -d vari ...   Up      80/tcp
