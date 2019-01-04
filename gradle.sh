#!/bin/bash

# Install gradle and gradle properties

echo "Install gradle and gradle.properties file"
sleep 5

yum install epel-release wget unzip -y

# Exit if /opt/gradle exists
if [ -d /opt/gradle ];then
echo "Gradle is present. Exiting.."
exit 1
fi

# Start gradle installation
wget https://services.gradle.org/distributions/gradle-3.4.1-bin.zip -P $BAMBOOHOME
unzip -d /opt $BAMBOOHOME/gradle-3.4.1-bin.zip
ln -s /opt/gradle-3.4.1 /opt/gradle

# Create gradle.properties and fill with required content (auth info with ivy and artifactory server).
echo "Creating gradle.properties"
sleep 5
mkdir $BAMBOOHOME/.gradle
touch $BAMBOOHOME/.gradle/gradle.properties

cat > $BAMBOOHOME/.gradle/gradle.properties << 'EOF'
artifactory_user=trogdor
artifactory_password=AP6CGnyUQ1Wxm2XVz1EAuq17mY3
artifactory_contextUrl=https://isjfrog02.betware.com/artifactory
ivy_user_name=svcgradlepub
ivy_user_password=Uran1234
clover.license.path=/opt/clover/lib/clover.license
systemProp.java.awt.headless=true
EOF

chown bamboo:bamboo -R $BAMBOOHOME/.gradle

# Delete gradle.sh env if exist
if [ -f /etc/profile.d/gradle.sh ];then
rm -f /etc/profile.d/gradle.sh
fi

# Export gradle and path variable
echo 'export GRADLE_HOME=/opt/gradle' >> /etc/profile.d/gradle.sh
echo 'export PATH=$GRADLE_HOME/bin:$PATH' >> /etc/profile.d/gradle.sh

. /etc/profile.d/gradle.sh
hash -r ; sync

echo "Gradle installation finished"
sleep 2


