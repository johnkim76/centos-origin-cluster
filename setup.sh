#!/bin/sh --login

if [ ! -f /etc/yum.repos.d/rhel7_3beta.repo ]; then
cat << EOF > /etc/yum.repos.d/rhel7_3beta.repo
[rhel7.3Beta]
name=RHEL7.3Beta
baseurl=http://download.devel.redhat.com/rel-eng/RHEL-7.3-RC-3.0/compose/Server/x86_64/os/
enabled=1
gpgcheck=0
sslverify=0
EOF
fi
yum -y install epel-release
yum -y install deltarpm wget git net-tools bind-utils bridge-utils gcc docker vim ansible

yum -y install subscription-manager
yum -y update

subscription-manager register --username="qa@redhat.com" --password="CZvGMy7TwJpVKW9t"

subscription-manager attach --pool=8a85f9823e3d5e43013e3ddd4e2a0977

subscription-manager repos --disable *

subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-optional-rpms" \
    --enable="rhel-7-server-ose-3.4-rpms"

groupadd docker
gpasswd -a vagrant docker

sed -i "s/OPTIONS='--selinux-enabled/OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0\/16/g" /etc/sysconfig/docker  
systemctl enable docker; systemctl start docker
cp /vagrant/id_rsa* /home/vagrant/.ssh/
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
cp -R /home/vagrant/.ssh /root/.ssh

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
