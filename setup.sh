#!/bin/sh --login

yum -y install epel-release

yum -y install deltarpm wget git net-tools bind-utils bridge-utils gcc docker vim ansible

groupadd docker
gpasswd -a vagrant docker

sed -i "s/OPTIONS='--selinux-enabled/OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0\/16/g" /etc/sysconfig/docker  
systemctl enable docker; systemctl start docker


wget https://github.com/openshift/origin/releases/download/v1.5.0-alpha.3/openshift-origin-client-tools-v1.5.0-alpha.3-cf7e336-linux-64bit.tar.gz -O /tmp/oc.tar.gz

tar -xzf /tmp/oc.tar.gz -C /tmp
mv /tmp/openshift-origin-client-tools-v1.5.0-alpha.3-cf7e336-linux-64bit/oc /usr/local/bin/

ifdown eth1
ifup eth1


if [ $1 == "master" ]; then
  yum -y install httpd-tools
  git clone https://www.github.com/ansible/ansible.git; cd ansible; python setup.py install; cd ..
  git clone https://www.github.com/openshift/openshift-ansible.git; cd openshift-ansible
  cp /vagrant/hosts /etc/ansible/hosts
  ansible-playbook playbooks/byo/config.yml
fi
