# -*- mode: ruby -*-
# vi: set ft=ruby :

PREFIXES=["10.10.10" , "172.16.10" , "192.168.10" ]

machines = {
#   Name         CPU, RAM, NETs
'controller' => [  1,   1, {1 => "10" , 2 => "10" , 3 => "10" }],
'network'    => [  1,   1, {1 => "20" , 2 => "20"             }],
'compute01'  => [  4,   2, {1 => "101", 2 => "101", 3 => "101"}],
'compute02'  => [  4,   2, {1 => "102", 2 => "102", 3 => "102"}],
'compute03'  => [  4,   2, {1 => "103", 2 => "103", 3 => "103"}],
}

$script = <<INLINE
yum install -q -y deltarpm &>/dev/null
yum update  -q -y -d 0     &>/dev/null

systemctl stop NetworkManager
systemctl -q disable NetworkManager
chkconfig network on
systemctl restart network
INLINE

Vagrant.configure("2") do |config|

	config.vm.box = "chef-centos-7.1"

	machines.each do |name, (cpu, ram, nets, hdds)|

		hostname = "%s" % [name]

		config.vm.define "#{hostname}" do |box|

			box.vm.hostname = "#{hostname}.local"

			nets.each {|key, suffix|
				box.vm.network :private_network,
									ip: PREFIXES[key-1] + "." + suffix
			}

			box.vm.provider "vmware_fusion" do |fusion|
				fusion.vmx["numvcpus"] = cpu
				fusion.vmx["memsize"]  = ram * 1024
			end

			box.vm.provider :virtualbox do |vbox|
				vbox.customize ["modifyvm", :id, "--cpus",   cpu]
				vbox.customize ["modifyvm", :id, "--memory", ram * 1024]
			end

      box.vm.provision :shell, :inline => $script

		end
	end
end
