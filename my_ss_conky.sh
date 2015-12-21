#!/bin/bash
#check if conky is running

if pidof conky > /dev/null
 then killall conky
 else sh ~/.conky/conky-startup.sh
fi

exit 0
