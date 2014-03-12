#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

# if which puppet > /dev/null ; then
#         echo "Puppet is already installed"
#         exit 0
# fi

# Environment variables
/vagrant/set_variables.sh

# Package prerequisites
/vagrant/install_packages.sh

# Ruby
# posted version /vagrant/install_ruby-2.0.0-p353.sh
# most recent update
/vagrant/install_ruby-2.0.0-p451.sh

# RubyGems
/vagrant/install_rubygems-2.2.2.sh

# Java
/vagrant/install_java-1.7.sh

# Tomcat
/vagrant/install_tomcat.sh 

# MySQL
/vagrant/install_mysql-5.6.sh

# Fedora
/vagrant/install_fedora.sh

# Solr
/vagrant/install_solr.sh

# Redis
/vagrant/install_redis.sh

# FFmpeg
/vagrant/install_ffmpeg.sh

# FITS
/vagrant/install_fits.sh

# clone code
/vagrant/clone_code.sh

# install apache & passenger
/vagrant/install_passenger.sh

# configure apache
/vagrant/configure_apache.sh

# configuration
/vagrant/configure_code.sh

