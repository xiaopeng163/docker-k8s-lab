Build a Base Image from Scratch
================================

we will build a ``hello world`` base image from Scratch.


System Environment
-------------------

Docker running on centos 7 and the version

.. code-block:: sh

    $ docker version
    Client:
    Version:	17.12.0-ce
    API version:	1.35
    Go version:	go1.9.2
    Git commit:	c97c6d6
    Built:	Wed Dec 27 20:10:14 2017
    OS/Arch:	linux/amd64

    Server:
    Engine:
    Version:	17.12.0-ce
    API version:	1.35 (minimum version 1.12)
    Go version:	go1.9.2
    Git commit:	c97c6d6
    Built:	Wed Dec 27 20:12:46 2017
    OS/Arch:	linux/amd64
    Experimental:	false

install requirements:

.. code-block:: sh

    $ sudo yum install -y gcc glibc-static


Create a Hello world
---------------------


create a ``hello.c`` and save

.. code-block:: bash

    $ pwd
    /home/vagrant/hello-world
    [vagrant@localhost hello-world]$ more hello.c
    #include<stdio.h>

    int main()
    {
    printf("hello docker\n");
    }
    [vagrant@localhost hello-world]$

Compile the ``hello.c`` source file to an binary file, and run it.

.. code-block:: bash

    $ gcc -o hello -static  hello.c
    $ ls
    Dockerfile  hello  hello.c
    $ ./hello
    hello docker


Build Docker image
-------------------

Create a Dockerfile like this:

.. code-block:: bash

    $ more Dockerfile
    FROM scratch
    ADD hello /
    CMD ["/hello"]

build image through:

.. code-block:: bash

    $ docker build -t xiaopeng163/hello-world .
    $ docker image ls
    REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
    xiaopeng163/hello-world      latest              78d57d4588e3        4 seconds ago       844kB

Run the hello world container
------------------------------

.. code-block:: bash

    $ docker run xiaopeng163/hello-world
    hello docker

Done!