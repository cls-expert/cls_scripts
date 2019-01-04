#!/bin/bash

BWINSTALLTMP=/tmp/bwinstalltmp
IDEAVER="idea-IU-141.178.9"
CENTRIFY="centrifydc-5.1.3-deb5-x86_64.deb"
SQLDEV="sqldeveloper-4.0.3.16.84-1-all.deb"
VBOXVER="virtualbox-4.3"
VAGRANT="vagrant_1.7.2_x86_64.deb"

# Read in username for the user that the computer is designated for
echo "Please type in the username that will using the computer, followed by [ENTER]:"
read USERNAME

# Create directories and download all needed software
mkdir $BWINSTALLTMP
cd $BWINSTALLTMP
wget http://192.168.80.15/deployment/$CENTRIFY
wget http://192.168.80.15/deployment/$IDEAVER.tar.gz
wget http://192.168.80.15/deployment/$SQLDEV
wget https://dl.bintray.com/mitchellh/vagrant/$VAGRANT

# Install CURL
apt-get install -y curl

# Add Oracle VirtualBox secure key
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -

# Install needed repositories and update source lists
curl -sL https://deb.nodesource.com/setup | bash -
add-apt-repository ppa:webupd8team/java
echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" >> /etc/apt/sources.list
apt-get update

#Install Java 1.6
echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install -y oracle-java6-installer

#Install Java 1.7
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install -y oracle-java7-installer

#Install Java 1.8
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install -y oracle-java8-installer

# Make Java 1.7 default
update-java-alternatives -s java-7-oracle
apt-get install -y oracle-java7-set-default

# Install required packages
apt-get install -y scite vim shutter eclipse unity-lens-vm python-software-properties subversion nodejs build-essential $VBOXVER
dpkg -i $BWINSTALLTMP/$CENTRIFY
dpkg -i $BWINSTALLTMP/$SQLDEV
dpkg -i $BWINSTALLTMP/$VAGRANT

# Purge OpenJDK if it's installed via dependency
apt-get purge -y openjdk*

# Install IntelliJ
cd /opt
echo "Extracting IntelliJ IDEA $IDEAVER"
tar -zxf $BWINSTALLTMP/$IDEAVER.tar.gz
ln -s /opt/$IDEAVER idea-IU
mkdir -p /usr/local/share/applications
cat > /usr/local/share/applications/idea.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA
Icon=/opt/idea-IU/bin/idea.png
Exec=bash -elop with pleasure!
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
EOi /opt/idea-IU/bin/idea.sh
Comment=DevF

# Fix Oracle SQLDeveloper startup script
cat > /opt/sqldeveloper/sqldeveloper.sh << 'EOF'
#!/bin/bash
unset GNOME_DESKTOP_SESSION_ID
cd "`dirname $0`"/sqldeveloper/bin && bash sqldeveloper $*
EOF

# Creating local user to map to
useradd -s /bin/bash $USERNAME

#Adding user to various groups
usermod -a -G sudo,lpadmin,cdrom $USERNAME

# CentrifyDC.conf editing.
echo "pam.allow.users: file:/etc/centrifydc/users.allow" >> /etc/centrifydc/centrifydc.conf
echo "pam.allow.groups: file:/etc/centrifydc/groups.allow" >> /etc/centrifydc/centrifydc.conf
echo "pam.mapuser.$USERNAME = $USERNAME" >> /etc/centrifydc/centrifydc.conf

# Adding user and admin group to centrify allow lists
echo $USERNAME >> /etc/centrifydc/users.allow
echo "unixadminserver" >> /etc/centrifydc/groups.allow

# Configuring Centrify version and joining domain
adlicense -e
adjoin -w betware.com -u bwcompman -p St0dvarfjordur

# Restarting Centrify.
service centrifydc restart

# Clean up after ourselves
rm -rf $BWINSTALLTMP

# Update all packages
apt-get upgrade -y
