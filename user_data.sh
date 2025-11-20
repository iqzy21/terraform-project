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

sudo sed -i "/^define( 'AUTH_KEY'/c\define( 'AUTH_KEY',         '#GG9y}4w^u-2k!_j|h}kn3Oi?catiDGD-i({n%K[o*a<T%U@yLIMu{W-[@Oajz?{' );" /srv/www/wordpress/wp-config.php
sudo sed -i "/^define( 'SECURE_AUTH_KEY'/c\define( 'SECURE_AUTH_KEY',  ' B92,[+:KJk9lI/{jBkMDQZ8@4m;o^vNI-X+X^3u=wAsS,?%.D3<IEXc} aqsjQ=' );" /srv/www/wordpress/wp-config.php
sudo sed -i "/^define( 'LOGGED_IN_KEY'/c\define( 'LOGGED_IN_KEY',    'qo+8>ov5$kzkD2MJo.r?Q<rY_P:l3KM!a^ /q/P1#42-?zN\`xW*J3M_|vhj>#+n ' );" /srv/www/wordpress/wp-config.php
sudo sed -i "/^define( 'NONCE_KEY'/c\define( 'NONCE_KEY',        'Y5gytl )m/NJiS;>nDL/8|V!`3Bc-+2=v~-;OBvK]Fp=Y8yp&`$:#fntV.`Ks[!g' );" /srv/www/wordpress/wp-config.php
sudo sed -i "/^define( 'AUTH_SALT'/c\define( 'AUTH_SALT',        '7Qj=>CvCw,QB6VKpX$Q CG}BRR$+K#WV<oJ}#flK&Y$+t{mzDS}fuz/6V7<$|*5A' );" /srv/www/wordpress/wp-config.php
sudo sed -i "/^define( 'SECURE_AUTH_SALT'/c\define( 'SECURE_AUTH_SALT', 'Q)B+m|*9grvwbVr?|SQDJ8NY3SX7c_FM,_`LGU-E{R|VOROKg-8lKWFkd^V!!=G2' );" /srv/www/wordpress/wp-config.php
sudo sed -i "/^define( 'LOGGED_IN_SALT'/c\define( 'LOGGED_IN_SALT',   'hAdad|1Q{Ku<c=`#>a+H-ZagNA->aoz(wy1NfK+WlsA5g0m`0k|5hC?H#!c~;V^g' );" /srv/www/wordpress/wp-config.php
sudo sed -i "/^define( 'NONCE_SALT'/c\define( 'NONCE_SALT',       'O*dh+sbq@FJ=+~5{z((>oVnq G$Txt7m SM/y]6y~%QBSj_em(e.uZ1JS[k~CaY(' );" /srv/www/wordpress/wp-config.php





