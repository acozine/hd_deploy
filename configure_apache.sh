#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

# create and populate the passenger config
tee -a /etc/httpd/conf.d/passenger.conf <<EOF
   LoadModule passenger_module /usr/local/lib/ruby/gems/2.0.0/gems/passenger-4.0.37/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /usr/local/lib/ruby/gems/2.0.0/gems/passenger-4.0.37
     PassengerDefaultRuby /usr/local/bin/ruby
     PassengerTempDir /opt/passenger_temp
   </IfModule>
EOF

# create the apache config
tee -a /etc/httpd/conf.d/$HYDRA_NAME.conf <<EOF
<VirtualHost *:80>
 ServerName hydra.local
   DocumentRoot /opt/$HYDRA_NAME/public
   XSendFile on
   XSendFilePath /opt/xsendfile
 <Directory /opt/hydradam/public>
   AllowOverride all
   Options -MultiViews
 </Directory>
</VirtualHost>
EOF

#restart apache
service httpd restart
