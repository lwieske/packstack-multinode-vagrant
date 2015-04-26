#!/bin/sh
set -x

sudo yum install -y epel-release
sudo yum install -y sshpass

ssh-keygen -t rsa -N '' -f /home/vagrant/.ssh/id_rsa

sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no 'root@10.10.10.10' date
sshpass -p 'vagrant' ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub 'root@10.10.10.10'
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no 'root@10.10.10.20' date
sshpass -p 'vagrant' ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub 'root@10.10.10.20'
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no 'root@10.10.10.101' date
sshpass -p 'vagrant' ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub 'root@10.10.10.101'
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no 'root@10.10.10.102' date
sshpass -p 'vagrant' ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub 'root@10.10.10.102'
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no 'root@10.10.10.103' date
sshpass -p 'vagrant' ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub 'root@10.10.10.103'

sudo yum install -q -y http://rdo.fedorapeople.org/rdo-release.rpm
sudo yum install -q -y openstack-packstack
