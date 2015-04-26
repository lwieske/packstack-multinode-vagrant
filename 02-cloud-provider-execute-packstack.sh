#!/bin/sh
set -x

packstack --install-hosts=10.10.10.10,10.10.10.20,10.10.10.101,10.10.10.102,10.10.10.103 \
              --ssh-public-key=/home/vagrant/.ssh/id_rsa.pub                             \
              --keystone-admin-passwd=openstack                                          \
              --keystone-demo-passwd=openstack                                           \
              --os-ceilometer-install=n                                                  \
              --os-cinder-install=n                                                      \
              --os-heat-install=n                                                        \
              --os-swift-install=n                                                       \
              --nagios-install=n                                                         \
              --provision-tempest=n                                                      \
              --os-controller-host=10.10.10.10                                           \
              --os-network-hosts=10.10.10.20                                             \
              --os-compute-hosts=10.10.10.101,10.10.10.102,10.10.10.103
