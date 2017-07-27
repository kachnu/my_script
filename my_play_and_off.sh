#!/bin/bash

if [ -z ${1// /} ] 
   then echo "no play"; exit 1
   else echo "Play $1"; FILE_PLAY=$1
fi

TIMER=20
vlc --play-and-exit "$FILE_PLAY"
(
while [ $COUNT? != 110 ]
 do
   echo $COUNT
   echo "# Shutdown after $TIMER s"
   COUNT=`expr $COUNT + 5`
   TIMER=`expr $TIMER - 1`
   sleep 1
 done
) |
zenity --auto-close --progress --title "Play is complete" \
--text "Power off"

if [ $? = 0 ];
   then xfce4-session-logout --halt --fast
   #dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop
fi

exit 0
