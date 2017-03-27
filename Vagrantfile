# -*- mode: ruby -*-
# vi: set ft=ruby :

##
# Customize VARS below
##
NODES = 3
DISKS = 3

ENV['VAGRANT_NO_PARALLEL'] = 'yes'
PROJECTS_GIT_HOME= File.expand_path "../"

PROJECTS = {
  :ansible_service_broker  => "#{PROJECTS_GIT_HOME}/ansible-service-broker",
  :ansibleapp           => "#{PROJECTS_GIT_HOME}/ansibleapp"
}

PROJECTS.each do |name, path|
  if !Dir.exists?(path)
    puts "Please ensure you have a #{name} git clone at: #{path}"
    exit
  end
end

##
# OPTIONAL Git Repos
##

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.ssh.insert_key = false

  # skip vagrant-registration
  config.registration.skip = true

  config.vm.provision "shell",
    inline: "hostname --fqdn > /etc/hostname && hostname -F /etc/hostname"
  config.vm.provision "shell",
    inline: "sed -ri 's/127\.0\.0\.1\s.*/127.0.0.1 localhost localhost.localdomain/' /etc/hosts"

  config.vm.box = "centos/7"
  config.vm.provision :shell, :path => "setup.sh", :args => PROJECTS.values.join(' ')

  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  PROJECTS.each do |name, path|
    type = :nfs
    config.vm.synced_folder path, path, type: type
  end

  # master node
  config.vm.define "master" do |master|
    master.vm.hostname="master.example.com"
    master.vm.synced_folder "./deploy", "/deploy", type: "nfs"
    master.vm.network :private_network,
      :ip => "192.168.166.5",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__network_name => "centos_cluster_net",
      :libvirt__dhcp_enabled => false
    master.vm.synced_folder ".", "/vagrant", type: "nfs"
    master.vm.provider :libvirt do |libvirt|
      libvirt.driver = "kvm"
      libvirt.memory = 8192
      libvirt.cpus = 4
    end
  end

  # nodes
  (1..NODES).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.hostname="node#{i}.example.com"
      node.vm.synced_folder ".", "/vagrant", type: "nfs"
      node.vm.network :private_network,
        :ip => "192.168.166.#{5+i}",
        :libvirt__netmask => "255.255.255.0",
        :libvirt__network_name => "centos_cluster_net",
        :libvirt__dhcp_enabled => false
        (0..DISKS-1).each do |d|
          node.vm.provider :libvirt do  |lv|
              driverletters = ('b'..'z').to_a
              lv.storage :file, :device => "vd#{driverletters[d]}", :path => "atomic-disk-#{i}-#{d}.disk", :size => '1024G'
              lv.driver = "kvm"
              lv.memory = 4096
              lv.cpus =2
          end
        end

        if i == (NODES)
        node.vm.provision :ansible do |ansible|
            ansible.verbose = true
            ansible.limit = "all"
            ansible.playbook = "site.yml"
            ansible.groups = {
              "nodes" => (1..NODES).map {|j| "node#{j}.example.com"},
            }
        end
      end
    end
  end
end
