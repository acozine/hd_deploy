#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

# source env and move to /opt/$HYDRA_NAME to access rake tasks
source /etc/environment
cd /opt/$HYDRA_NAME

# copy initializers for secret token & devise
cp -p /opt/$HYDRA_NAME/config/initializers/secret_token.rb.sample /opt/$HYDRA_NAME/config/initializers/secret_token.rb
cp -p /opt/$HYDRA_NAME/config/initializers/devise.rb.sample /opt/$HYDRA_NAME/config/initializers/devise.rb

# generate and insert secret keys for code & devise
export SECRET=$(rake secret) && sed -i.bak s/=\ \'.*\'/=\ \'$SECRET\'/g /opt/$HYDRA_NAME/config/initializers/secret_token.rb
export DEVISE_SECRET=$(rake secret) && sed -i.bak s/key\ =\ \'.*\'/key\ =\ \'$DEVISE_SECRET\'/g /opt/$HYDRA_NAME/config/initializers/devise.rb

# symlink the solr xml files
sudo ln -sf /opt/$HYDRA_NAME/solr_conf/conf/schema.xml /opt/solr/$HYDRA_NAME/collection1/conf/schema.xml 
sudo ln -sf /opt/$HYDRA_NAME/solr_conf/conf/solrconfig.xml /opt/solr/$HYDRA_NAME/collection1/conf/solrconfig.xml

# set the fits path for sufia
sed -i.bak "s/\/home\/ubuntu\/fits-0\.6\.1\/fits\.sh/\/usr\/local\/bin\/fits\.sh/g" /opt/$HYDRA_NAME/config/initializers/sufia.rb

# Create temporary transcoding directory for hydraDAM
mkdir -p /opt/${HYDRA_NAME}_tmp

# mysql production db is created in the install_mysql script

# create database.yml file
cat > /opt/$HYDRA_NAME/config/database.yml <<EOF
production:  
 adapter: mysql2
 host: localhost
 database: hd_production
 username: hdProd
 password: hdProd
 pool: 5
 timeout: 5000
EOF

# create production fedora.yml file
cat > /opt/$HYDRA_NAME/config/fedora.yml <<EOF
production:
 user: fedoraAdmin
 password: fedoraAdmin
 url: http://127.0.0.1:8080/fedora
EOF

# create production redis.yml file
cat > /opt/$HYDRA_NAME/config/redis.yml <<EOF
production:
 host: localhost
 port: 6379
EOF

# create production solr.yml file
cat > /opt/$HYDRA_NAME/config/solr.yml << EOF
production:
 url: http://127.0.0.1:8080/hydradam/
EOF

# Prepare the database and assets 
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile

# set proper ownership for everything
chown -R apache:apache /opt/passenger_temp /opt/xsendfile
chown $INSTALL_USER:$INSTALL_USER /opt/$HYDRA_NAME_tmp
chown -R $INSTALL_USER:$INSTALL_USER /opt/$HYDRA_NAME

# restart services
service tomcat6 restart
service httpd restart

# configure pool_q & start a pool
cp /opt/hydradam/script/pool_q /etc/rc.d/init.d/
chown root:root /etc/init.d/pool_q
chmod 0755 /etc/init.d/pool_q
chkconfig --add pool_q
service pool_q start

