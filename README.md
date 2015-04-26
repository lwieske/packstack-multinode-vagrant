## OpenStack/Juno Multinode Setup based on Packstack

### Prerequisite: Vagrant

[Vagrant](http://www.vagrantup.org) uses [VirtualBox](http://www.virtualbox.org) to create virtual machines.

### Create OpenStack Cluster (1xController/1xNetwork/3xCompute)

    git clone http://github.com/lwieske/packstack-multinode-vagrant.git

    cd packstack-multinode-vagrant

    vagrant up

### Cloud Provider - Enable Packstack

    vagrant ssh controller -c /vagrant/01-cloud-provider-enable-packstack.sh

### Cloud Provider - Execute Packstack

    vagrant ssh controller -c /vagrant/02-cloud-provider-execute-packstack.sh

### Cloud Admin - Create Projects (dev,tst,ops)

    vagrant ssh controller -c /vagrant/03-cloud-admin-create-projects.sh

### Cloud User - Create Web App for DEV Tenant

    vagrant ssh controller -c /vagrant/04-cloud-user-create-prj-001-dev.sh

### Cloud User - Create Web App for TST Tenant

    vagrant ssh controller -c /vagrant/05-cloud-user-create-prj-001-tst.sh
