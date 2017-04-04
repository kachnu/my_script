#!/bin/bash
# Set time and date
# author: kachnu
# email: ya.kachnu@yandex.ua

if ! [ `which yad` ]; then echo "Need yad"; exit 1; fi
if ! [ `which timedatectl` ]; then echo "Need timedatectl"; exit 1; fi
if [ $(id -u) -ne 0 ]; then echo "Start $0 with root"; exit 1; fi

Sync=$(timedatectl status | grep "Network" | awk '{print $4}')
TZ=$(timedatectl status | grep "Time zone" | awk '{print $3}')
TZ_list=$(timedatectl list-timezones | tr '\n' !)
Hour=$(date +%H)
Minute=$(date +%M)
Second=$(date +%S)
Date=$(date +%d.%m.%Y)

yad --window-icon=time-admin --title="Time and date" \
--form --separator="," \
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
    if [ $Hour -lt 10 ]; then Hour=0$Hour; fi
    if [ $Minute -lt 10 ]; then Minute=0$Minute; fi
    if [ $Second -lt 10 ]; then Second=0$Second; fi
    Date=`echo $Date| awk -F'.' '{print $3"-"$2"-"$1}'`
    Set_time=$Date" "$Hour":"$Minute":"$Second

    timedatectl set-ntp false 
    timedatectl set-timezone "$TZ"
    timedatectl set-time "$Set_time"
    timedatectl set-ntp "$Sync"
done

exit 0
