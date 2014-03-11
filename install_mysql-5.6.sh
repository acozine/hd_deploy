#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

#install mysql version not available in yum repo
mkdir -p /opt/install && cd /opt/install
wget -c http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
rpm -ivh mysql-community-release-el6-5.noarch.rpm 
yum install mysql-server -y

# set mysql to start automatically on reboot
chkconfig mysqld on
 
# move mysql to /opt
cp -a /var/lib/mysql/ /opt/
ls -la /opt

# Use SED to update my.cnf defaults
sed '
/datadir\s*=/ d
/character_set_server\s*=/ d
/default-storage-engine\s*=/ d
/\[mysqld\]/ a\
datadir = /opt/mysql \
character_set_server = utf8 \
default-storage-engine = InnoDB' -i.bak /etc/my.cnf

# start mysql and run through the secure installation
service mysqld start
/usr/bin/mysql_secure_installation < /vagrant/mysql_secure_non-secure_defaults.txt
mysql -u root -ppassword < /vagrant/mysql_fedora_tables.txt
mysql -u root -ppassword < /vagrant/mysql_production_tables.txt

