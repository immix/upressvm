#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

# Make sure helpful packages have been installed
apt-get install -y htop dstat nmap p7zip-full rpm

# Update composer
composer self-update

cd /tmp
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xfvz ioncube_loaders_lin_x86-64.tar.gz

# Copy .screenrc to vagrant's home folder
cp /vagrant/.screenrc /home/vagrant

# Fix short openers =(
sed -i 's/short_open_tag = Off/short_open_tags = On/' /etc/php5/fpm/php.ini

printf "zend_extension=/tmp/ioncube/ioncube_loader_lin_5.6.so\n" > /tmp/php.ini
cat /etc/php5/fpm/php.ini >> /tmp/php.ini
cp -f /tmp/php.ini /etc/php5/fpm/php.ini

#sed -i '1s/^/zend_extension=/tmp/ioncube/ioncube_loader_lin_5.6.so /' /etc/php5/fpm/php.ini

service php5-fpm restart