#!/bin/bash
#start conky in conky-manager

#if pidof conky > /dev/null
 #then killall conky
 #else sh ~/.conky/conky-startup.sh
#fi

#kill $(ps -ela | grep $UID | grep conky | awk '{print $4}')

sh ~/.conky/conky-startup.sh

exit 0
