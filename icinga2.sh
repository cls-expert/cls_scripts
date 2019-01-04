#!/bin/bash

# install jq json parser
yum install epel-release -y
yum makecache
yum install jq -y

pki_dir=/etc/icinga2/pki
icinga2_master=icinga.betware.com
fqdn=`echo $HOSTNAME`
fetch_ticket=$(curl -k -s -u svcicinga:Uran1234 -H 'Accept: application/json' -X POST 'https://icinga.betware.com:5665/v1/actions/generate-ticket' -d '{ "cn": "'$HOSTNAME'" }' | jq '.results[0].ticket')
ticket=$(echo $fetch_ticket | tr -d '"')
icinga2_master_port=5665

# Install prerequisites
yum install nagios-plugins-all icinga2-selinux -y

#install remote icinga repo
yum install https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm -y

# Install icinga
yum install icinga2 -y

# Start icinga service
systemctl start icinga2 && systemctl enable icinga2

# Open firewall icinga port
firewall-cmd --permanent --zone=public --add-port=5665/tcp
firewall-cmd --reload


# Disable configuration and running checks on hosts
sed -i 's/include_recursive "conf.d"/\/\/include_recursive "conf.d"/g' /etc/icinga2/icinga2.conf


mkdir $pki_dir && chown icinga. $pki_dir && chmod 700 $pki_dir
icinga2 pki new-cert --cn $fqdn --key $pki_dir/$fqdn.key --cert $pki_dir/$fqdn.crt
icinga2 pki save-cert --key $pki_dir/$fqdn.key --cert $pki_dir/$fqdn.crt --trustedcert $pki_dir/trusted-master.crt --host $icinga2_master
icinga2 pki request --host $icinga2_master --port $icinga2_master_port --ticket $ticket --key $pki_dir/$fqdn.key --cert $pki_dir/$fqdn.crt --trustedcert $pki_dir/trusted-master.crt --ca $pki_dir/ca.key
icinga2 node setup --ticket $ticket --endpoint $icinga2_master --zone $fqdn --master_host $icinga2_master --trustedcert $pki_dir/trusted-master.crt

# Make configuration changes to accepts commands from the master
sed -i 's/false/true/g' /etc/icinga2/features-enabled/api.conf

systemctl restart icinga2
