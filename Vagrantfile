# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

NUM_WORKER_NODE = 5
IP_NW = "192.168.20."
MANAGED_IP_START = 10

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility).

Vagrant.configure("2") do |config|
  
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_check_update = false
  config.ssh.insert_key = false
  config.vm.provision "shell", path: "commun.sh"

# Provision k8s master Node
    
    config.vm.define "master" do |master|
    master.vm.hostname = "master.emdc.local"
		master.vm.network :private_network, ip: "192.168.20.10", dev: "virbr2", mode: "open"
    master.vm.synced_folder ".", "/vagrant", disabled: true
	  master.vm.provision "shell", path: "master.sh"
    master.vm.provider "libvirt" do |libvirt|
          libvirt.memory = 4096
          libvirt.cpus = 2
      end
	end
 

  # Provision ansible managed Nodes
  
  (1..NUM_WORKER_NODE).each do |i|
    
	config.vm.define "node#{i}" do |node|
	    node.vm.hostname = "node#{i}.emdc.local"
      node.vm.network :private_network, ip: IP_NW + "#{MANAGED_IP_START + i}", dev: "virbr2", mode: "open"
      node.vm.synced_folder ".", "/vagrant", disabled: true
	    node.vm.provision "shell", path: "worker.sh"
      node.vm.provider "libvirt" do |libvirt|
            libvirt.memory = 2048
            libvirt.cpus = 1
        end                
    end
  end

end
