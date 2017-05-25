#!/bin/bash

#pt_BR
sudo locale-gen pt_BR.UTF-8

source /vagrant/shell/conf/variables.conf

# create project folder
sudo mkdir -p "/var/www/${PROJECT_ROOT}/public"

echo "<?php phpinfo(); ?>" > /var/www/${PROJECT_ROOT}/public/info.php

# update / upgrade
echo "[VAGRANT] INIT, update and upgrade"
sudo apt -y update
sudo apt -y upgrade

cat << EOF >> /etc/hosts
192.168.33.10 ${LOCAL_HOSTNAME} ${LOCAL_HOSTNAME}
EOF

echo ${LOCAL_HOSTNAME} > /etc/hostname
hostnamectl set-hostname ${LOCAL_HOSTNAME}

# PHP
echo "[VAGRANT] Installing PHP"
sudo apt install -y apache2
sudo apt install -y php libapache2-mod-php
# install cURL and Mcrypt
sudo apt install -y php-curl php-mcrypt php-xdebug php-pear php-mysql php-curl php-zip php-gd php-intl php-pear php-imagick php-imap php-mcrypt php-memcache php-pspell php-recode php-sqlite3 php-tidy php-xmlrpc php-xsl php-mbstring php-gettext php-opcache php-apcu

sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" ${PHP_CONFIG_FILE}
sed -i "s/display_errors = Off/display_errors = On/g" ${PHP_CONFIG_FILE}



echo "[VAGRANT] Installing PHP XDebug"
cat << EOF > ${XDEBUG_CONFIG_FILE}
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_host=10.0.2.2
EOF



# INIT APACHE2
# setup host file
echo "[VAGRANT] Installing Apache2 with default HOST..."
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin ${SERVER_ADMIN}
    DocumentRoot "/var/www/${PROJECT_ROOT}/public"

	LogLevel debug

	ErrorLog /var/log/apache2/error.log
	CustomLog /var/log/apache2/access.log combined

    <Directory "/var/www/${PROJECT_ROOT}/public">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > ${APACHE_DEFAULT_VHOST}


# Composer
echo "[VAGRANT] Installing composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --filename=composer  --install-dir=/usr/bin
php -r "unlink('composer-setup.php');"



# Install PHP Unity
echo "[VAGRANT] Installing PHP Unity..."
if [ ! -f "/usr/local/bin/phpunit" ]; then
	wget https://phar.phpunit.de/phpunit-6.1.phar
	chmod +x phpunit-6.1.phar
	sudo mv phpunit-6.1.phar /usr/local/bin/phpunit
fi



# INIT MYSQL
echo "[VAGRANT] Installing mysql..."
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
sudo apt install -y mysql-client mysql-server

sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" ${MYSQL_CONFIG_FILE}

# Allow root access from any host
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=${MYSQL_PASSWORD}
echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=${MYSQL_PASSWORD}
# END MYSQL




# INIT PHPMyAdmin
sudo echo "[VAGRANT] Installing PHPMyAdmin..."
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt install -y phpmyadmin
# END PHPMyAdmin


# Postfix
echo "[VAGRANT] Installing postfix"
sudo debconf-set-selections <<< "postfix postfix/mailname string ${HOSTNAME}"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

sudo apt -y install mailutils
service postfix reload

#postfix, send only
sudo sed -i 's/inet_interfaces = all/inet_interfaces = loopback-only/gi' /etc/postfix/main.cf

cat << EOF >> /etc/aliases
root:          ${SERVER_ADMIN}
EOF
sudo newaliases


# enable mod_rewrite
sudo a2enmod rewrite suexec ssl actions include cgi

# restart apache
sudo service apache2 restart
# restart mysql
sudo service mysql restart

# Essesntials
sudo apt -y install build-essential binutils-doc mailutils vim htop ntp ntpdate curl make openssl unzip

#Autoremove
sudo apt -y autoremove



#Echo first version to file
if [ ! -f ${GUEST_VERSION_FILE} ]; then
    sudo touch  ${GUEST_VERSION_FILE};
    $( sudo sh -c "echo "${VERSION}" > ${GUEST_VERSION_FILE}" )
fi

exit 0;
