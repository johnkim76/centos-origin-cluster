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


if [ $1 == "master" ]; then
  yum -y install httpd-tools
  git clone https://www.github.com/ansible/ansible.git; cd ansible; python setup.py install; cd ..
  git clone https://www.github.com/openshift/openshift-ansible.git; cd openshift-ansible
  cp /vagrant/hosts /etc/ansible/hosts
  ansible-playbook playbooks/byo/config.yml
  htpasswd -cb /etc/origin/master/htpasswd ansibleapp changeme
  htpasswd -cb /etc/origin/master/htpasswd admin admin
  oadm policy add-cluster-role-to-user cluster-admin admin
  oadm policy add-scc-to-user privileged admin
  oadm policy add-scc-to-group anyuid system:authenticated
  oadm manage-node master.example.com --schedulable
  oc label node master.example.com region=infra --overwrite
  oc login -u admin -p admin
  oc create -f /vagrant/files/pv.yaml
else
  mkdir -p /var/pv/{1,2,3,4}
  chmod 777 /var/pv/{1,2,3,4}
fi
