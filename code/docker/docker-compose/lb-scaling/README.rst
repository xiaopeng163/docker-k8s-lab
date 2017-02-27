# Setup with docker-compose

.. code-block:: bash

    $ docker-compose build
    $ docker-compose up

Then check the app by:

.. code-block:: bash

    $ curl http://127.0.0.1
    Hello Container World! I have been seen 1 times and my hostname is docker-host-aws.
    $ curl http://127.0.0.1


Auto scale and load blancing

.. code-block:: bash

    $ docker-compose scale web=3
    $ curl 127.0.0.1
    Hello Container World! I have been seen 9 times and my hostname is 6f71b2798411.
    $ curl 127.0.0.1
    Hello Container World! I have been seen 10 times and my hostname is ca279e7dda99.
    $ curl 127.0.0.1
    Hello Container World! I have been seen 11 times and my hostname is 0895f7205c8f.
