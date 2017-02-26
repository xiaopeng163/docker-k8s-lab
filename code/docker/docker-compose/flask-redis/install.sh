#!/bin/bash

sudo apt-get install gcc python-pip
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make MALLOC=libc
sudo make install
nohup redis-server &

sudo pip install -r requirements.txt
