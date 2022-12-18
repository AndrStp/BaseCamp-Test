#!/bin/bash
add-apt-repository -y ppa:ondrej/php
apt update -y
apt-get install -y php8.1 php8.1-cli php8.1-common php8.1-mysql php8.1-fpm php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath php8.1-intl lphp8.1-soap ibapache2-mod-fcgid
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.rackspace.com/mariadb/repo/10.4/ubuntu focal main'
apt install mariadb-server
# Apache
a2enmod proxy_fcgi setenvif
a2enconf php8.1-fpm
rm -f /var/www/html/index.html
systemctl start apache2
systemctl enable apache2
wget https://download.moodle.org/download.php/direct/stable401/moodle-latest-401.tgz -O /tmp/moodle.tgz
tar -xf /tmp/moodle.tgz -C /var/www/html/ --strip-components=1
# rm /tmp/moodle.tgz
# DB
systemctl start mariadb
systemctl enable mariadb
export DBNAME=moodle_db
export DBUSER=moodle
export DBHOST=localhost
export DBPASS=pa3539w0rd
sudo mysql -u root -e "create user '${DBUSER}'@'${DBHOST}' identified by '${DBPASS}'"
sudo mysql -u root -e "create database ${DBNAME}"
sudo mysql -u root -e "grant all on ${DBNAME}.* to '${DBUSER}'@'${DBHOST}'"
sudo mysql -u root -e "flush privileges"
# Moodle
export DATADIR=/var/moodle-data
mkdir ${DATADIR} && chmod 0664 ${DATADIR}
sed -i 's/;max_input_vars = 1000/max_input_vars = 5500/' /etc/php/8.1/apache2/php.ini
sed -i 's/;max_input_vars = 1000/max_input_vars = 5500/' /etc/php/8.1/fpm/php.ini
sed -i 's/;max_input_vars = 1000/max_input_vars = 5500/' /etc/php/8.1/cli/php.ini
# export TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
# export PUBLIC_IP=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4`
# php /var/www/html/admin/cli/install.php \
#   --wwwroot="http://${PUBLIC_IP}" \
#   --dataroot=${DATADIR} \
#   --dbtype=mariadb \
#   --dbhost=${DBHOST} \
#   --dbname=${DBNAME} \
#   --dbuser=${DBUSER} \
#   --dbpass=${DBPASS} \
#   --fullname=my-moodle \
#   --shortname=my-moodle \
#   --summary='Andriy Stepanenko' \
#   --adminuser=andrey \
#   --adminpass=myverysecurepass \
#   --agree-license \
#   --non-interactive
