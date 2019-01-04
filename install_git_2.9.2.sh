#!/bin/bash

yum install wget perl-ExtUtils-MakeMaker perl-ExtUtils wget curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc  -y
wget https://www.kernel.org/pub/software/scm/git/git-2.9.2.tar.gz -P /root 
tar xvf /root/git-2.9.2.tar.gz -C /root
cd /root/git*
make prefix=/opt/git all
make prefix=/opt/git install
echo 'export PATH=/opt/git/bin:$PATH' > /etc/profile.d/git.sh
source /etc/profile
rm -irf /root/git-2.9.2.tar.gz /root/git*
