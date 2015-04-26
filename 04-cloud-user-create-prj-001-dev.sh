#!/bin/sh -x

HOST_IP=10.10.10.10

export OS_TENANT_NAME=prj-001-dev
export OS_USERNAME=${OS_TENANT_NAME}-usr
export OS_PASSWORD=openstack

export OS_AUTH_URL=http://${HOST_IP}:35357/v2.0/

##########
# networks
##########

neutron router-create                               \
                  ${OS_TENANT_NAME}-external-router

PUBLIC_ID=`neutron net-external-list --name=public | sed -n 4,4p | awk '{print $2;}'`

ROUTER_ID=`neutron router-list --name=${OS_TENANT_NAME}-external-router | sed -n 4,4p | awk '{print $2;}'`

neutron router-gateway-set              \
                  $ROUTER_ID $PUBLIC_ID

neutron net-create                                                          \
                  ${OS_TENANT_NAME}-internal-network
neutron subnet-create                                                       \
                  ${OS_TENANT_NAME}-internal-network                        \
                  --name ${OS_TENANT_NAME}-internal-subnet 192.168.100.0/24

neutron router-interface-add                                   \
                  $ROUTER_ID ${OS_TENANT_NAME}-internal-subnet

neutron net-create                                                           \
                  ${OS_TENANT_NAME}-asingress-network
neutron subnet-create                                                        \
                  ${OS_TENANT_NAME}-asingress-network                        \
                  --name ${OS_TENANT_NAME}-asingress-subnet 192.168.110.0/24

neutron net-create                                                           \
                  ${OS_TENANT_NAME}-dbingress-network
neutron subnet-create                                                        \
                  ${OS_TENANT_NAME}-dbingress-network                        \
                  --name ${OS_TENANT_NAME}-dbingress-subnet 192.168.120.0/24

neutron net-create                                                            \
                  ${OS_TENANT_NAME}-sshingress-network
neutron subnet-create                                                         \
                  ${OS_TENANT_NAME}-sshingress-network                        \
                  --name ${OS_TENANT_NAME}-sshingress-subnet 192.168.200.0/24

###########
# secgroups
###########

neutron security-group-create lb
neutron security-group-create as
neutron security-group-create db
neutron security-group-create ssh

neutron security-group-rule-create                        \
                  --direction ingress --protocol TCP      \
                  --port-range-min 80 --port-range-max 80 \
                  lb

neutron security-group-rule-create                        \
                  --direction ingress --protocol TCP      \
                  --port-range-min 80 --port-range-max 80 \
                  as

neutron security-group-rule-create                            \
                  --direction ingress --protocol TCP          \
                  --port-range-min 3306 --port-range-max 3306 \
                  --remote-group-id as                        \
                  db

neutron security-group-rule-create                        \
                  --direction ingress --protocol TCP      \
                  --port-range-min 22 --port-range-max 22 \
                  --remote-group-id ssh                   \
                  lb

neutron security-group-rule-create                        \
                  --direction ingress --protocol TCP      \
                  --port-range-min 22 --port-range-max 22 \
                  --remote-group-id ssh                   \
                  as

neutron security-group-rule-create                        \
                  --direction ingress --protocol TCP      \
                  --port-range-min 22 --port-range-max 22 \
                  --remote-group-id ssh                   \
                  db

neutron security-group-rule-create                        \
                  --direction ingress --protocol tcp      \
                  --port-range-min 22 --port-range-max 22 \
                  ssh

#########
# compute
#########

INTERNAL_NET_ID=`neutron net-list --name=${OS_TENANT_NAME}-internal-network | sed -n 4,4p | awk '{print $2;}'`
ASINGRESS_NET_ID=`neutron net-list --name=${OS_TENANT_NAME}-asingress-network | sed -n 4,4p | awk '{print $2;}'`
DBINGRESS_NET_ID=`neutron net-list --name=${OS_TENANT_NAME}-dbingress-network | sed -n 4,4p | awk '{print $2;}'`
SSHINGRESS_NET_ID=`neutron net-list --name=${OS_TENANT_NAME}-sshingress-network | sed -n 4,4p | awk '{print $2;}'`

nova boot                            \
     --image cirros                  \
     --flavor m1.micro               \
     --security_groups lb            \
     --nic net-id=$INTERNAL_NET_ID   \
     --nic net-id=$ASINGRESS_NET_ID  \
     --nic net-id=$SSHINGRESS_NET_ID \
     lb

nova boot                            \
     --image cirros                  \
     --flavor m1.micro               \
     --security_groups as            \
     --nic net-id=$ASINGRESS_NET_ID  \
     --nic net-id=$DBINGRESS_NET_ID  \
     --nic net-id=$SSHINGRESS_NET_ID \
     as1

nova boot                            \
     --image cirros                  \
     --flavor m1.micro               \
     --security_groups as            \
     --nic net-id=$ASINGRESS_NET_ID  \
     --nic net-id=$DBINGRESS_NET_ID  \
     --nic net-id=$SSHINGRESS_NET_ID \
     as2

nova boot                            \
     --image cirros                  \
     --flavor m1.micro               \
     --security_groups db            \
     --nic net-id=$DBINGRESS_NET_ID  \
     --nic net-id=$SSHINGRESS_NET_ID \
     db

nova boot                            \
     --image cirros                  \
     --flavor m1.micro               \
     --security_groups as            \
     --nic net-id=$INTERNAL_NET_ID   \
     --nic net-id=$SSHINGRESS_NET_ID \
     bastion

##############
# connectivity
##############

sleep 60

LB_IP_ADDRESS=`nova show lb | grep ${OS_TENANT_NAME}-internal-network | awk '{print $5;}'`
BASTION_IP_ADDRESS=`nova show bastion | grep ${OS_TENANT_NAME}-internal-network | awk '{print $5;}'`

LB_PORT_ID=`neutron port-list | grep $LB_IP_ADDRESS | awk '{print $2;}'`
BASTION_PORT_ID=`neutron port-list | grep $BASTION_IP_ADDRESS | awk '{print $2;}'`

neutron floatingip-create --port-id $LB_PORT_ID      public
neutron floatingip-create --port-id $BASTION_PORT_ID public
