#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "Restart $0 with root"
  gksudo $0 
  exit 0
fi

Sync=$(timedatectl status | grep "Network" | awk '{print $4}')
TZ=$(timedatectl status | grep "Time zone" | awk '{print $3}')
Hour=$(date +%H)
Minute=$(date +%M)
Second=$(date +%S)
Date=$(date +%d.%m.%Y)

TZ_list=$(timedatectl list-timezones | tr '\n' !)

yad --title="Time and date" --form --separator="," \
--field="Sync time::CB" "$Sync!yes!no" \
--field="Time zone::CB" "$TZ!$TZ_list" \
--field="Hour::NUM" $Hour!0..23!1!0 \
--field="Minute::NUM" $Minute!0..59!1!0 \
--field="Second::NUM" $Second!0..59!1!0 \
--field="Date::DT" $Date | while read line; do
    Sync=`echo $line | awk -F',' '{print $1}'`
    TZ=`echo $line | awk -F',' '{print $2}'`
    Hour=`echo $line | awk -F',' '{print $3}'`
    Minute=`echo $line | awk -F',' '{print $4}'`
    Second=`echo $line | awk -F',' '{print $5}'`
    Date=`echo $line | awk -F',' '{print $6}'`

    if [ `echo $Sync| grep yes` ]; then
         Sync="true"
    else Sync="false"
    fi
    if [ $Hour -lt 10 ]; then Hour=0$Hour;fi
    if [ $Minute -lt 10 ]; then Minute=0$Minute;fi
    if [ $Second -lt 10 ]; then Second=0$Second;fi
    Date=`echo $Date| awk -F'.' '{print $3"-"$2"-"$1}'`
    Set_time=$Date" "$Hour":"$Minute":"$Second

    echo $Sync $TZ $Hour $Minute $Second $Date
    echo $Set_time
    
    sudo timedatectl set-ntp false 
    sudo timedatectl set-timezone "$TZ"
    sudo timedatectl set-time "$Set_time"
    sudo timedatectl set-ntp "$Sync"

#sudo /bin/bash - << usercodeblock
#timedatectl set-ntp false 
#timedatectl set-timezone "$TZ"
#timedatectl set-time "$Set_time"
#timedatectl set-ntp "$Sync"
#usercodeblock
    
done

exit 0
