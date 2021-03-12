#/bin/sh

# install some tools
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install -y git vim gcc telnet psmisc jq

# install docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh

# if [ ! $(getent group docker) ]; then
#     sudo groupadd docker
# else
#     echo "docker user group already exists"
# fi

# sudo gpasswd -a $USER docker
# sudo systemctl start docker

rm -rf get-docker.sh
