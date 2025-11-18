#!/bin/bash

sudo apt update
sudo apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip

# Create web root and set permissions
sudo mkdir -p /srv/www
sudo chown -R www-data:www-data /srv/www

# Download and extract WordPress
curl -fsSL https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

# WordPress should now be: /srv/www/wordpress

# Create Apache site config
sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null << 'EOF'
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2ensite wordpress
sudo systemctl reload apache2
sudo a2enmod rewrite
sudo systemctl reload apache2
sudo a2dissite 000-default
sudo systemctl reload apache2

sudo service apache2 reload

sudo mysql -u root <<EOF 

CREATE DATABASE wordpress;

CREATE USER wordpress@localhost IDENTIFIED BY 'wordpass';

GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER 
ON wordpress.* 
TO wordpress@localhost;

FLUSH PRIVILEGES;

quit
EOF

sudo service mysql start

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/wordpass/' /srv/www/wordpress/wp-config.php



