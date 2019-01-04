#!/bin/bash

yum update -y
yum install vim net-tools -y

# Install java

yum install java-1.8.0-openjdk-headless.x86_64 -y

# Install MongoDB

if [ -f /etc/yum.repos.d/mongodb-org-3.2.repo ]; then
echo "MongoDB is installed. Skiping..."
else
echo "Installing MongoDB"
sleep 3
touch /etc/yum.repos.d/mongodb-org-3.2.repo
cat > /etc/yum.repos.d/mongodb-org-3.2.repo << 'EOF'
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
EOF
yum install mongodb-org -y
fi

systemctl enable mongod
systemctl start mongod

# Install Elasticsearch

if [ -f /etc/yum.repos.d/elasticsearch.repo ]; then
echo "Elasticsearch is installed. Skiping..."
else
echo "Installing Elasticsearch"
sleep 3
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/elasticsearch.repo << 'EOF'
[elasticsearch-2.x]
name=Elasticsearch repository for 2.x packages
baseurl=https://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF
yum install elasticsearch -y
fi

systemctl enable elasticsearch
systemctl start elasticsearch

# Change cluster name
sed -i 's/# cluster.name: my-application/cluster.name: graylog/g' /etc/elasticsearch/elasticsearch.yml
systemctl restart elasticsearch

# Install Graylog
sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-2.1-repository_latest.rpm
yum install graylog-server -y
systemctl enable graylog-server
systemctl start graylog-server

# Configure Graylog

echo "Installing epel repo for pwgen program"
yum install epel-release -y
yum install pwgen -y
sed -i "s/password_secret =/password_secret = `pwgen -N 1 -s 96`/g" /etc/graylog/server/server.conf
sed -i "s/root_password_sha2 =/root_password_sha2 = `echo -n Uran1234 | sha256sum | rev | cut -c 4- | rev`/g" /etc/graylog/server/server.conf
sed -i "s/#web_listen_uri = http:\/\/127.0.0.1:9000\//web_listen_uri = http:\/\/127.0.0.1:9000\//g" /etc/graylog/server/server.conf
sed -i "s/127.0.0.1/`hostname -I | rev | cut -c 2- | rev`/g" /etc/graylog/server/server.conf 


systemctl restart graylog-server

# SElinux settings
yum install policycoreutils-python -y
setsebool -P httpd_can_network_connect 1
semanage port -a -t mongod_port_t -p tcp 27017

# Manage Firewall Rules
firewall-cmd --permanent --zone=public --add-port=9000/tcp
firewall-cmd --reload
