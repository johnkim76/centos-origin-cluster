#!/bin/sh --login

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
oadm policy add-scc-to-user privileged admin
oc label node master.example.com region=infra --overwrite
oc login -u admin -p admin
oc create -f /vagrant/files/pv.yaml
