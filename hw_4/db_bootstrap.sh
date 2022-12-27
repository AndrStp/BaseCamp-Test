#!/bin/bash

# install DB
apt update
apt install -y mariadb-server

# start DB
systemctl start mariadb
systemctl enable mariadb

export DBHOST=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
export DBNAME=wordpress
export DBUSER=wordpressuser
export DBPASS=pa3539w0rd

sed -i "s/.*bind-address.*/bind-address = ${DBHOST}/" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb

# Create DB abd User for WORDPRESS
mysql -e "CREATE DATABASE ${DBNAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"
mysql -e "create user '${DBUSER}'@'%' identified by '${DBPASS}'"
mysql -e "grant all on ${DBNAME}.* to '${DBUSER}'@'%'; flush privileges"
