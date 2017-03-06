#!/bin/bash
NET_DEV=`cat /proc/net/dev | grep : | grep -v lo | cut -d: -f1`
for DEV in $NET_DEV; do
  if [[ `ip a show $DEV | grep state | grep -v DOWN` ]]; then
     echo "----- $DEV"
     IP_DEV=`ip a show $DEV | grep "inet " | awk '{print $2}'`
     echo "----- $IP_DEV"
  fi
done

exit 0
