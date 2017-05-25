#!/bin/bash
source /vagrant/shell/conf/variables.conf

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

exit 0;
