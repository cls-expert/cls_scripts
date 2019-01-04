#!/bin/bash

# Update repositories!

echo "Updating repositories"
apt-get update &> /dev/null

# Install dependencies 

echo "Installing dependencies"
apt-get install build-essential fakeroot dpkg-dev -y &> /dev/null

# Build git dep

echo "Build git dependencies"
apt-get build-dep git -y &> /dev/null

apt-get install libcurl4-openssl-dev -y &> /dev/null

mkdir ~/git-openssl &> /dev/null
cd ~/git-openssl

apt-get source git &> /dev/null
dpkg-source -x *.dsc &> /dev/null
cd git-1.9.1
sed -i 's/libcurl4-gnutls-dev/libcurl4-openssl-dev/g' debian/control &> /dev/null
sed '/TEST=test/d' debian/rules &> /dev/null
dpkg-buildpackage -rfakeroot -b &> /dev/null
cd ..

echo "Installing ...."
dpkg -i *amd64.deb &> /dev/null

