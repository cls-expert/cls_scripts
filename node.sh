#!/bin/bash

# Install nodejs and packages

echo "Installing nodejs 6.11.0 as bamboo user and npm packages"
sleep 5

yum groupinstall 'Development Tools' -y
cd $BAMBOOHOME

# Create .npmrc (npm configuration file) and fill it with required content. This is npm setup for bamboo user only! It should NOT run by root user!

touch .npmrc

cat > .npmrc << 'EOF'

root = /home/bamboo/.local/lib/node_modules
binroot = /home/bamboo/.local/bin
manroot = /home/bamboo/.local/share/man
registry=https://sinopia.betware.com
@nls:registry=https://sinopa.betware.com
@myco:registry=https://sinopa.betware.com
@types:registry=https://registry.npmjs.org

EOF


# Extract nodejs from backup server

yum install wget -y
wget https://nodejs.org/dist/v6.11.0/node-v6.11.0.tar.gz                                           
tar -xzvf node-v6.11.0.tar.gz

cd node-*
# Sets your node installation under ".local" directory, thus making functional only to bamboo user.
$BAMBOOHOME/node-v6.11.0/configure --prefix=$BAMBOOHOME/.local
make
make install
ln -s $BAMBOOHOME/.local/lib/node_modules $BAMBOOHOME/.node_modules
chown bamboo:bamboo -R $BAMBOOHOME

# Installing necessary npm modules
echo "Installing bower,grunt,grunt-cli,phantomjs,phantomjs-prebuilt and newman"
sleep 5
su - bamboo -c "npm install bower -g"
su - bamboo -c "npm install grunt -g"
su - bamboo -c "npm install grunt-cli -g"
su - bamboo -c "npm install phantomjs -g"
su - bamboo -c "npm install phantomjs-prebuilt -g"
su - bamboo -c "npm install newman -g"
su - bamboo -c "npm install jasmine jasmine-node jasmine-reporters -g"
su - bamboo -c "npm install istanbul -g"
su - bamboo -c "npm install mocha -g"
su - bamboo -c "npm install mocha-bamboo-reporter -g"

# Install PhantomJS dependency

echo "Installing fontconfig which is required for phantomjs"
sleep 5
yum install fontconfig -y

# Installs nvm (Node Version Manager)
echo "Installing nvm"
sleep 5
su - bamboo -c "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.4/install.sh | bash"

# Install node versions via nvm
su - bamboo -c "nvm install 0.10.40"
su - bamboo -c "nvm install 4.4.7"
su - bamboo -c "nvm install 4.5.0"
su - bamboo -c "nvm install 5.4.1"
su - bamboo -c "nvm install 6.11.0"
su - bamboo -c "nvm install 6.2.2"
