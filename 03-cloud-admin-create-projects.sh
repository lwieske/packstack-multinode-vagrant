#!/bin/sh -x

HOST_IP=10.10.10.10

export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=openstack

export OS_AUTH_URL=http://${HOST_IP}:35357/v2.0/

##########
# projects
##########

for i in 001 002 003
do
  for j in dev tst ops
    do
      PROJECT_NAME=prj-$i-$j
      USER_NAME=$PROJECT_NAME-usr

      openstack project create                  \
                        --enable                \
                        $PROJECT_NAME
      openstack role add                        \
                        --project $PROJECT_NAME \
                        --user admin            \
                        admin
      openstack user create                     \
                        --project $PROJECT_NAME \
                        --password openstack    \
                        --enable                \
                        $USER_NAME

    done
done

########
# flavor
########

openstack flavor create               \
                    --vcpus 1         \
                    --ram 256         \
                    --ephemeral 1     \
                    --public          \
                    m1.micro

openstack flavor create               \
                    --vcpus 1         \
                    --ram 128         \
                    --ephemeral 1     \
                    --public          \
                    m1.nano





--is-public true m1.extra_tiny auto 256 0 1 --rxtx-factor .1
