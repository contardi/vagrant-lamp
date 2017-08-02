#!/bin/bash
source $(dirname $0)/conf/variables.conf

ETC_HOSTS="/etc/hosts"

if [ -f "$ETC_HOSTS" ]; then
  if [ ! -n "$(grep $LOCAL_HOSTNAME /etc/hosts)" ]; then
    echo "Adding the $LOCAL_HOSTNAME in $ETC_HOSTS"
    $( sudo sh -c "echo '${SERVER_IP} ${LOCAL_HOSTNAME}' >> ${ETC_HOSTS}" )
	  if [ -n "$(grep $HOST_LINE /etc/hosts)" ]; then
      echo "$LOCAL_HOSTNAME was added: $(grep $LOCAL_HOSTNAME $ETC_HOSTS)"
    else
			echo "Wasn't possible to add $LOCAL_HOSTNAME, an error occurred!"
    fi
  fi
fi

exit 0;
