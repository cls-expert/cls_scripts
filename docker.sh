#!/bin/bash
# Install deps
yum clean all
yum install epel-release -y

# Install docker
yum install docker -y
systemctl enable docker
systemctl start docker
groupadd docker
usermod -aG docker bamboo
systemctl restart docker

if [ ! -d /home/bamboo/.docker ]; then
mkdir /home/bamboo/.docker
touch /home/bamboo/.docker/config.json

cat > /home/bamboo/.docker/config.json << 'EOF'
{

      "auths":  {
        "https://nimbus.betware.com:5000": {
        "auth": "dHJvZ2RvcjpBUDZDR255VVExV3htMlhWejFFQXVxMTdtWTM=",
        "email": "trogdor@burninate.io"
   }
 }
}

EOF
else
cat > /home/bamboo/.docker/config.json << 'EOF'
{

      "auths":  {
        "https://nimbus.betware.com:5000": {
        "auth": "dHJvZ2RvcjpBUDZDR255VVExV3htMlhWejFFQXVxMTdtWTM=",
        "email": "trogdor@burninate.io"
   }
 }
}
EOF
fi
chown bamboo:bamboo -R /home/bamboo/.docker
systemctl restart docker


