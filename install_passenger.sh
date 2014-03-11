#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

# set apache to start automatically on reboot
chkconfig httpd on

# install xsendfile
cd /opt/install  
git clone https://github.com/nmaier/mod_xsendfile.git  
cd mod_xsendfile  
sudo apxs -cia mod_xsendfile.c 

# create the temp and xsendfile directories
mkdir /opt/passenger_temp /opt/xsendfile

# call the expect script to install the apache2-module 
expect /vagrant/install_passenger.exp

