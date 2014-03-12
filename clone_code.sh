#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

# clone the hydraDAM code
source /etc/environment
cd /opt
git clone git://github.com/curationexperts/hydradam.git ${HYDRA_NAME}
cd $HYDRA_NAME

# install bundler, rails, rake, and passenger
gem install bundler -N
gem install rails -N
gem install rake -N --force
gem install daemon_controller -N
gem install passenger -v 4.0.37 -N
gem install resque-pool -N

# bundle install & give the install user ownership of the gem directory
bundle --deployment
chown -R $INSTALL_USER:$INSTALL_USER /usr/local/lib/ruby/gems/2.0.0/

