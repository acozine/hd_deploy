#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

yum install tomcat6 tomcat6-webapps tomcat6-admin-webapps -y
chkconfig tomcat6 on
service tomcat6 restart

