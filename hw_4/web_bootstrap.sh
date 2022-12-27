#!/bin/bash

# install nginx and php
apt update
apt install -y nginx
apt install -y \
            php-curl \
            php-gd \
            php-intl \
            php-mbstring \
            php-soap \
            php-xml \
            php-xmlrpc \
            php-zip \
            php-fpm \
            php-mysqlnd

# restart php-fpm
systemctl restart php7.4-fpm

# configure nginx
mkdir -p /var/www/html/wordpress
cat <<EOF | sudo tee /etc/nginx/sites-available/wordpress
server {
    listen 80;
    server_name _;
    root /var/www/html/wordpress;

    index index.html index.htm index.php;

    location /wordpress {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
     }

    location  /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default
systemctl reload nginx

# install & configure wordpress
wget https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz
tar -zxf /tmp/latest.tar.gz -C /var/www/html/wordpress/ --strip-components=1
chown -R www-data:www-data /var/www/html/wordpress
rm -f /tmp/latest.tar.gz

chown -R www-data:www-data /var/www/html/wordpress/

sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

sed -i 's/database_name_here/wordpress/' /var/www/html/wordpress/wp-config.php
sed -i 's/username_here/wordpressuser/' /var/www/html/wordpress/wp-config.php
sed -i 's/password_here/pa3539w0rd/' /var/www/html/wordpress/wp-config.php
sed -i 's/localhost/192.168.1.2/' /var/www/html/wordpress/wp-config.php
