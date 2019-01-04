#!/bin/bash

# Install esential repositories and packages
yum install yum-utils -y
yum install https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm -y
yum install centos-release-scl -y && yum-config-manager --enable rhel-server-rhscl-7-rpms
yum install epel-release -y
yum update -y
yum install nfs-utils vim net-tools -y

# Check if scripts do exist
if [ -f /root/bin/NLS ]; then
echo "NLS scripts are in order."
else
mkdir /root/bin && mount nfs.betware.com:/nfs /root/bin
fi

yum install  rh-php71-php-cli php-Icinga rh-php71-php-common rh-php71-php-fpm rh-php71-php-pgsql rh-php71-php-ldap rh-php71-php-intl rh-php71-php-xml rh-php71-php-gd rh-php71-php-pdo rh-php71-php-mbstring -y

# Install and enable icinga2
yum install icinga2 -y
systemctl enable icinga2
systemctl start icinga2

# Install standard plugins 
yum install nagios-plugins-all -y
yum install vim-icinga2 -y
yum install icingaweb2-selinux  -y

# Setting up Icinga-Web

# Install Postgresql
yum install postgresql-server postgresql -y
postgresql-setup initdb
systemctl enable postgresql
systemctl start postgresql

yum install icinga2-ido-pgsql -y


# Create icinga user and database. Configure pg_hba.
cd /tmp
sudo -u postgres psql -c "CREATE ROLE icinga WITH LOGIN PASSWORD 'icinga'"
sudo -u postgres createdb -O icinga -E UTF8 icinga
sudo -u postgres createlang plpgsql icinga > /dev/null 2>&1

sed -i "79i # icinga\n\n\n\n\n\n\n"                                              /var/lib/pgsql/data/pg_hba.conf
sed -i "81i local   icinga          icinga                                  md5" /var/lib/pgsql/data/pg_hba.conf
sed -i "82i host    icinga          icinga        127.0.0.1/32              md5" /var/lib/pgsql/data/pg_hba.conf
sed -i "83i host    icinga          icinga        ::1/128                   md5" /var/lib/pgsql/data/pg_hba.conf

# Create icinga web user and database. Configure pg_hba.
cd /tmp
sudo -u postgres psql -c "CREATE ROLE icingaweb WITH LOGIN PASSWORD 'icingaweb'"
sudo -u postgres createdb -O icingaweb -E UTF8 icingaweb
sudo -u postgres createlang plpgsql icingaweb > /dev/null 2>&1

sed -i "83i # icinga web"                                                        /var/lib/pgsql/data/pg_hba.conf
sed -i "85i local   icingaweb       icingaweb                               md5" /var/lib/pgsql/data/pg_hba.conf
sed -i "86i host    icingaweb       icingaweb     127.0.0.1/32              md5" /var/lib/pgsql/data/pg_hba.conf
sed -i "87i host    icingaweb       icingaweb     ::1/128                   md5" /var/lib/pgsql/data/pg_hba.conf

# Apply configuration changes
echo -e "\n Please verify pg_hba.conf file\n"
sleep 3
systemctl restart postgresql

# Enabling IDO (Icinga Database Output) Postgresql module
PGPASSWORD=icinga  psql -U icinga -d icinga < /usr/share/icinga2-ido-pgsql/schema/pgsql.sql
echo -e "\nCheck if /etc/icinga2/features-available/ido-pgsql.conf file is updated with proper database credentials\n"
sleep 3
icinga2 feature enable ido-pgsql
systemctl restart icinga2

# Install httpd and autofs
#NLS init autofs   
#NLS init httpd

# Firewall rules
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

# Enable external pipe module
icinga2 feature enable command
systemctl restart icinga2

# Add httpd user to icingacmd group
usermod -a -G icingacmd apache

# Install icinga web
yum install icingaweb2 icingacli -y

yum install sclo-php71-php-pecl-imagick-devel.x86_64 -y
yum install sclo-php71-php-pecl-imagick.x86_64 -y


systemctl restart httpd.service
systemctl start icinga2.service
systemctl enable icinga2.service
systemctl start rh-php71-php-fpm.service
sudo systemctl enable rh-php71-php-fpm.service


# Selinux configuration
setsebool -P httpd_can_connect_ldap 1
setsebool -P httpd_can_network_connect_db 1


# Fix Icinga start-up requirements

# 1 Fix timezone warning
sed -i 's/;date.timezone =/date.timezone = Europe\/Vienna/g' /etc/opt/rh/rh-php71/php.ini
systemctl restart rh-php71-php-fpm.service

# 2 Fix php-ldap warning
#yum install php-ldap -y

# 3 Fix /et/icingaweb2 permissions 
#chcon -R -t httpd_sys_rw_content_t /etc/icingaweb2/
#systemctl restart httpd


