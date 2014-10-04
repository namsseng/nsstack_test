#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi
./nsstack_setuprc

# get horizon
apt-get install -y apache2 memcached libapache2-mod-wsgi openstack-dashboard

# remove the ubuntu theme - seriously this is fucking stupid it's still broken
apt-get remove -y --purge openstack-dashboard-ubuntu-theme
sed -e "
/^OPENSTACK_HOST  =.*$/s/^.*$/OPENSTACK_HOST = \"$managementip\"/

" -i /etc/openstack-dashboard/local_settings.py

# restart apache
service apache2 restart; service memcached restart

source demo-openrc.sh

ssh-keygen
nova keypair-add --pub-key ~/.ssh/id_rsa.pub demo-key
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0