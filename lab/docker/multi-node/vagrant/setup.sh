#/bin/sh

# install some tools
sudo apt-get install -y git vim gcc build-essential telnet

# install docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh

# start docker service
sudo groupadd docker
sudo gpasswd -a ubuntu docker
sudo service docker restart

rm -rf get-docker.sh