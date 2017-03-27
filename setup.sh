#!/bin/sh --login

yum -y install epel-release
yum -y install deltarpm wget git net-tools bind-utils bridge-utils gcc docker vim ansible

yum -y update

groupadd docker
gpasswd -a vagrant docker

sed -i "s/OPTIONS='--selinux-enabled/OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0\/16/g" /etc/sysconfig/docker  
systemctl enable docker; systemctl start docker
cp /vagrant/id_rsa* /home/vagrant/.ssh/
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
cp -R /home/vagrant/.ssh /root/.ssh
chmod 600 /root/.ssh/*

wget https://github.com/openshift/origin/releases/download/v1.5.0-alpha.3/openshift-origin-client-tools-v1.5.0-alpha.3-cf7e336-linux-64bit.tar.gz -O /tmp/oc.tar.gz

tar -xzf /tmp/oc.tar.gz -C /tmp
mv /tmp/openshift-origin-client-tools-v1.5.0-alpha.3-cf7e336-linux-64bit/oc /usr/local/bin/

ifdown eth1
ifup eth1

