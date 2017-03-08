#!/bin/bash

#OLD_INFO=`cat /dev/shm/netstatold || netstat -i -e`
#OLD_TIME=`cat /dev/shm/uptimeold | awk '{print $1}' || cat /proc/uptime | awk '{print $1}'`

#netstat -i -e > /dev/shm/netstatold
#cat /proc/uptime > /dev/shm/uptimeold

#for GW in `ip r|grep default|awk '{print $3}'`; do
    #echo -e "GW:			$GW"
#done

#NUM=0
#for DNS in `cat /etc/resolv.conf | grep -v \# | grep nameserver | awk '{print $2}'`; do
    #NUM=$(($NUM+1))
    #echo -e "DNS $NUM: 		$DNS"
#done
###################
#OLD_INFO=`netstat -i -e`
#OLD_TIME=`cat /proc/uptime | awk '{print $1}'`
#sleep 1
#NET_DEV=`echo -e "$OLD_INFO" | grep UP | grep RUNNING | grep -v lo | awk -F: '{print $1}'`
#for DEV in $NET_DEV; do
     #IP_DEV=`echo -e "$OLD_INFO" | grep -A8 $DEV | grep "inet " | awk '{print $2}'`
     #GW=`ip r|grep default| grep $DEV| awk '{print $3}'`
     ## Speed test
     #OLD_BIT_RX=`echo -e "$OLD_INFO" | grep -A8 $DEV | grep "RX packets" | awk '{print $5}'`
     #OLD_BIT_TX=`echo -e "$OLD_INFO" | grep -A8 $DEV | grep "TX packets" | awk '{print $5}'`     
     #NEW_INFO=`netstat -i -e`
     #NEW_TIME=`cat /proc/uptime | awk '{print $1}'`
     #NEW_BIT_RX=`echo -e "$NEW_INFO" | grep -A8 $DEV | grep "RX packets" | awk '{print $5}'`
     #NEW_BIT_TX=`echo -e "$NEW_INFO" | grep -A8 $DEV | grep "TX packets" | awk '{print $5}'`
     #SPEED_RX=$(echo "scale=1; ($NEW_BIT_RX - $OLD_BIT_RX)/($NEW_TIME-$OLD_TIME)/1000" | bc)
     #SPEED_TX=$(echo "scale=1; ($NEW_BIT_TX - $OLD_BIT_TX)/($NEW_TIME-$OLD_TIME)/1000" | bc)
     ## Total rx/tx
     #RX_DEV=`echo -e "$NEW_INFO" | grep -A8 $DEV | grep "RX packets" | awk -F"(" '{print $2}' | awk -F")" '{print $1}'`
     #TX_DEV=`echo -e "$NEW_INFO" | grep -A8 $DEV | grep "TX packets" | awk -F"(" '{print $2}' | awk -F")" '{print $1}'`
     ## Print net info
     #echo -e "IP $DEV: 		$IP_DEV
#GW: 			$GW
#RX: 			$SPEED_RX kBps/ $RX_DEV
#TX: 			 $SPEED_TX kBps/ $TX_DEV
#"
#done
###############################

#OLD_INFO=`cat /dev/shm/netstatold`
#OLD_TIME=`cat /dev/shm/uptimeold | awk '{print $1}'`

#cat /proc/net/dev > /dev/shm/netstatold
#cat /proc/uptime > /dev/shm/uptimeold

OLD_INFO=`cat /proc/net/dev`
OLD_TIME=`cat /proc/uptime | awk '{print $1}'`
NET_DEV=`echo -e "$OLD_INFO" | grep : | grep -v lo | sed "s/ //g" | grep -v ":00"| awk -F: '{print $1}'`
IP_INFO=`ip a`
sleep 1
for DEV in $NET_DEV; do
     IP_DEV=`echo -e "$IP_INFO" | grep -A4 $DEV | grep "inet " | awk '{print $2}'`
     GW=`ip r|grep default| grep $DEV| awk '{print $3}'`
     # Speed test
     OLD_BIT_RX=`echo -e "$OLD_INFO" | grep $DEV | awk '{print $2}'`
     OLD_BIT_TX=`echo -e "$OLD_INFO" | grep $DEV | awk '{print $10}'`     
     NEW_INFO=`cat /proc/net/dev`
     NEW_TIME=`cat /proc/uptime | awk '{print $1}'`
     NEW_BIT_RX=`echo -e "$NEW_INFO" | grep $DEV | awk '{print $2}'`
     NEW_BIT_TX=`echo -e "$NEW_INFO" | grep $DEV | awk '{print $10}'`
     #echo $OLD_BIT_RX $OLD_BIT_TX
     #echo $NEW_BIT_RX $NEW_BIT_TX
     SPEED_RX=$(echo "scale=1; ($NEW_BIT_RX - $OLD_BIT_RX)/($NEW_TIME-$OLD_TIME)/1000" | bc)
     SPEED_TX=$(echo "scale=1; ($NEW_BIT_TX - $OLD_BIT_TX)/($NEW_TIME-$OLD_TIME)/1000" | bc)
     # Total rx/tx
     RX_DEV=$(echo "scale=1; $NEW_BIT_RX/1024/1024" | bc)
     TX_DEV=$(echo "scale=1; $NEW_BIT_TX/1024/1024" | bc)
     # Print net info
     echo -e "IP $DEV: 		$IP_DEV
GW: 			$GW
RX: 			$SPEED_RX kBps/ $RX_DEV MiB
TX: 			 $SPEED_TX kBps/ $TX_DEV MiB
"
done






exit 0
