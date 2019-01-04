#!/bin/bash

yum install wget epel-release -y

wget https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm -P /root/
wget https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-7-ppc64le/pgdg-centos95-9.5-3.noarch.rpm -P /root/

rpm -Uvh /root/pgdg*

yum clean all

yum install pgadmin4-v1
systemctl enable pgadmin4-v1 && systemctl start pgadmin4-v1


sed -i "s/DEFAULT_SERVER\s=\s'localhost'/DEFAULT_SERVER='0.0.0.0'/g"  /usr/lib/python2.7/site-packages/pgadmin4-web/config.py
systemctl restart pgadmin4-v1

