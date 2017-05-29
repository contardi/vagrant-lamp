#!/bin/bash
source /vagrant/conf/variables.conf

#Shell loop
if [ ! -d ${GUEST_MIGRATE_PATH} ]; then
    sudo mkdir -p ${GUEST_MIGRATE_PATH};
fi

if [ ! -f ${GUEST_VERSION_FILE} ]; then
    sudo touch  ${GUEST_VERSION_FILE};
fi

for f in $(ls $MIGRATE_PATH) ; do
    if [ -f ${MIGRATE_PATH}${f} ]; then
        if [ ! -f ${GUEST_MIGRATE_PATH}${f} ]; then
            VERSION=$( echo ${f} | sed "s/\.sh//" )
            $( sudo sh -c "echo "${VERSION}" > ${GUEST_VERSION_FILE}" )
            /bin/bash ${MIGRATE_PATH}${f}
            sudo cp ${MIGRATE_PATH}${f} ${GUEST_MIGRATE_PATH}${f}
        fi
    fi
done


#SQL loop
if [ ! -d ${GUEST_SQL_PATH} ]; then
    sudo mkdir -p ${GUEST_SQL_PATH};
fi

if [ ! -f ${GUEST_SQL_FILE} ]; then
    sudo touch  ${GUEST_SQL_FILE};
fi


for f in $(ls $SQL_PATH) ; do
    if [ -f ${SQL_PATH}${f} ]; then
        if [ ! -f ${GUEST_SQL_PATH}${f} ]; then
            VERSION=$( echo ${f} | sed "s/\.sql//" )
            $( sudo sh -c "echo "${VERSION}" > ${GUEST_SQL_FILE}" )
            /bin/bash ${SQL_PATH}${f}
            sudo mysql -h localhost -u root -p$MYSQL_PASSWORD -e "source ${SQL_PATH}${f}"
            sudo cp ${SQL_PATH}${f} ${GUEST_SQL_PATH}${f}
        fi
    fi
done

exit 0;
