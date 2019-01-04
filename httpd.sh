#!/bin/bash

echo "Installing httpd"
sleep 10

yum -y install httpd


if [ -d /etc/httpd/modules ];then
grep -r "mod_proxy_ajp\|mod_proxy_connect\|mod_rewrite\|mod_proxy_httpa\|mod_ssl\|mod_ldap" /etc/httpd/modules
sleep 5
else
echo "Modules folder is missing. Exiting..."
exit 1
fi


# Check apache version (2.2 or 2.4)
echo "Checking for Apache version"
sleep 1

APACHE=`/usr/sbin/httpd -v | grep Apache/2.2`


if [ -z $APACHE ]; then
echo "Apache/httpd is 2.4"
systemctl enable httpd
systemctl start httpd
systemctl stop httpd
#yum install mod_php -y
else
echo "Apache/httpd is 2.2"
chkconfig httpd on
service httpd start
service httpd stop
#yum install -y mod_php
fi


# Install and enable all required modules and configurations regarding SSL

echo "Installing mod_ssl"
sleep 2
yum -y install mod_ssl
cp -r $CONFDIR/ssl/* /etc/ssl


/bin/cp $CONFDIR/virtualhosts.conf /etc/httpd/conf.d
sed -i "s/example.com/$HOSTNAME/g" /etc/httpd/conf.d/virtualhosts.conf
ipaddress=`hostname -I`

# Clean all whitespaces that command "hostname -I" produce
ipaddr2=`echo $ipaddress | tr -d " \t\n\r"`

sed -i "s/ipexample/$ipaddr2/g" /etc/httpd/conf.d/virtualhosts.conf

# Delete VirtualHost part from ssl.conf and make a copy of the config
cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.backup
sed -i '/^<Vir.*/Q' /etc/httpd/conf.d/ssl.conf 2>&1 /dev/null


# Selinux setting for bamboo
#/usr/sbin/setsebool -P httpd_can_network_connect 1
#/usr/sbin/setsebool -P httpd_can_connect_ldap 1

service httpd start
