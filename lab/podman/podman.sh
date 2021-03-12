sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_7/devel:kubic:libcontainers:stable.repo
sudo yum -y install podman
sudo echo 'vagrant:100000:65536' >>/etc/subuid
sudo echo 'vagrant:100000:65536' >>/etc/subgid
