#!/bin/bash

#pt_BR
sudo locale-gen pt_BR.UTF-8

source /vagrant/conf/variables.conf
source /vagrant/conf/functions.sh

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

installEssencials

installApache

installPHP

installXDebug

installComposer

installPHPUnit

installMySQL

installPHPMyAdmin

installPostfix

installNodeJS

installMemcache

installRedis #TODO
installMongoDB #TODO
installSonarQube #TODO

# enable mod_rewrite
sudo a2enmod rewrite suexec ssl actions include cgi

# restart apache
sudo service apache2 restart
# restart mysql
sudo service mysql restart

echo "[VAGRANT] Cleaning up"
#Autoremove
sudo apt -y autoremove


#Echo first version to file
if [ ! -f ${GUEST_VERSION_FILE} ]; then
    sudo touch  ${GUEST_VERSION_FILE};
    $( sudo sh -c "echo '${VERSION}' > ${GUEST_VERSION_FILE}" )
fi

exit 0;
