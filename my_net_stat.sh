#!/bin/bash

OLD_INFO=`cat /dev/shm/netstatold || netstat -i -e`
OLD_TIME=`cat /dev/shm/uptimeold | awk '{print $1}' || cat /proc/uptime | awk '{print $1}'`

netstat -i -e > /dev/shm/netstatold
cat /proc/uptime > /dev/shm/uptimeold

#for GW in `ip r|grep default|awk '{print $3}'`; do
    #echo -e "GW:			$GW"
#done

#NUM=0
#for DNS in `cat /etc/resolv.conf | grep -v \# | grep nameserver | awk '{print $2}'`; do
    #NUM=$(($NUM+1))
    #echo -e "DNS $NUM: 		$DNS"
#done

NET_DEV=`echo -e "$OLD_INFO" | grep UP | grep RUNNING | grep -v lo | awk -F: '{print $1}'`
for DEV in $NET_DEV; do
     IP_DEV=`echo -e "$OLD_INFO" | grep -A8 $DEV | grep "inet " | awk '{print $2}'`
     GW=`ip r|grep default| grep $DEV| awk '{print $3}'`
     # Speed test
     OLD_BIT_RX=`echo -e "$OLD_INFO" | grep -A8 $DEV | grep "RX packets" | awk '{print $5}'`
     OLD_BIT_TX=`echo -e "$OLD_INFO" | grep -A8 $DEV | grep "TX packets" | awk '{print $5}'`     
     NEW_INFO=`netstat -i -e`
     NEW_TIME=`cat /proc/uptime | awk '{print $1}'`
     NEW_BIT_RX=`echo -e "$NEW_INFO" | grep -A8 $DEV | grep "RX packets" | awk '{print $5}'`
     NEW_BIT_TX=`echo -e "$NEW_INFO" | grep -A8 $DEV | grep "TX packets" | awk '{print $5}'`
     SPEED_RX=$(echo "scale=1; ($NEW_BIT_RX - $OLD_BIT_RX)/($NEW_TIME-$OLD_TIME)/1000" | bc)
     SPEED_TX=$(echo "scale=1; ($NEW_BIT_TX - $OLD_BIT_TX)/($NEW_TIME-$OLD_TIME)/1000" | bc)
     # Total rx/tx
     RX_DEV=`echo -e "$NEW_INFO" | grep -A8 $DEV | grep "RX packets" | awk -F"(" '{print $2}' | awk -F")" '{print $1}'`
     TX_DEV=`echo -e "$NEW_INFO" | grep -A8 $DEV | grep "TX packets" | awk -F"(" '{print $2}' | awk -F")" '{print $1}'`
     # Print net info
     echo -e "IP $DEV: 		$IP_DEV
GW: 			$GW
RX: 			$SPEED_RX kBps/ $RX_DEV
TX: 			 $SPEED_TX kBps/ $TX_DEV
"
done

exit 0
