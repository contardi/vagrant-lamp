#!/bin/bash

installEssencials() {
    # Essesntials
    echo "[VAGRANT] Installing essenciall"
    sudo apt -y install binutils-doc vim htop ntp ntpdate curl make openssl unzip zip imagemagick bc
}

installApache() {
    # INIT APACHE2
    # setup host file
    echo "[VAGRANT] Installing Apache2 with default HOST..."

    if [ ! -d $APACHE_WWW_DIR ]; then
        sudo mkdir -p $APACHE_WWW_DIR;
    fi;

    # create project folder
    sudo mkdir -p "/var/www/${PROJECT_ROOT}/public"

    sudo apt install -y apache2

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
}

installPHP() {
    # PHP
    echo "[VAGRANT] Installing PHP"
    sudo apt install -y php libapache2-mod-php
    # install cURL and Mcrypt
    sudo apt install -y php-curl php-mcrypt php-xdebug php-pear php-mysql php-curl php-zip php-gd php-intl php-pear php-imagick php-imap php-mcrypt php-memcache php-pspell php-recode php-sqlite3 php-tidy php-xmlrpc php-xsl php-mbstring php-gettext php-opcache php-apcu

    sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" ${PHP_CONFIG_FILE}
    sed -i "s/display_errors = Off/display_errors = On/g" ${PHP_CONFIG_FILE}
    sed -i "s/memory_limit 128/memory_limit = 512/g" ${PHP_CONFIG_FILE}
}

installXDebug() {
    echo "[VAGRANT] Installing PHP XDebug"
cat << EOF > "${XDEBUG_CONFIG_FILE}"
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_host=10.0.2.2
EOF
}

installComposer() {
    # Composer
    echo "[VAGRANT] Installing composer..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --filename=composer  --install-dir=/usr/bin
    php -r "unlink('composer-setup.php');"
}

installPHPUnit() {
    # Install PHP Unity
    echo "[VAGRANT] Installing PHP Unity..."
    if [ ! -f "/usr/local/bin/phpunit" ]; then
        wget https://phar.phpunit.de/phpunit-6.2.phar
        chmod +x phpunit-6.2.phar
        sudo mv phpunit-6.2.phar /usr/local/bin/phpunit
    fi
}

installMySQL() {
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
}

installPHPMyAdmin() {
    # INIT PHPMyAdmin
    sudo echo "[VAGRANT] Installing PHPMyAdmin..."
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $MYSQL_PASSWORD"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_PASSWORD"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_PASSWORD"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
    sudo apt install -y phpmyadmin
    # END PHPMyAdmin
}

installPostfix() {
    # Postfix
    echo "[VAGRANT] Installing postfix"
    sudo debconf-set-selections <<< "postfix postfix/mailname string ${LOCAL_HOSTNAME}"
    sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

    sudo apt -y install mailutils
    service postfix reload

    #postfix, send only
    sudo sed -i 's/inet_interfaces = all/inet_interfaces = loopback-only/gi' /etc/postfix/main.cf

cat << EOF >> /etc/aliases
root:          ${SERVER_ADMIN}
EOF

    sudo newaliases
}

installNodeJS() {
    #Install Node
    echo "[VAGRANT] Installing Node js,"
    sudo apt -y install build-essential libssl-dev tcl python-software-properties
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt -y install nodejs
}

installMemcache() {
    # Redis Cache
    echo "[VAGRANT] Installing Memcached"
    sudo apt -y install memcached php-memcached
}

installMongoDB() {
    # Redis Cache
    echo "[VAGRANT] Installing Mongo"

    # Import the MongoDB public GPG Key and create a list file - https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
    sudo echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

    # Update package lists
    sudo apt -y update

    # Install MongoDB
    sudo apt install -y mongodb-org

    # Start MondoDB
    sudo service mongod start
    sudo systemctl enable mongod.service
}


#@TODO
installRedis() {
    # Redis Cache
    echo "[VAGRANT] Installing Redis"
}


#@TODO
installSonarQube() {
    # Redis Cache
    echo "[VAGRANT] Installing Sonar"
}
