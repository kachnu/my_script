#!/bin/bash

KEY_INFO=`xset -q | grep -m1 "00:" | sed "s/ //g"`

case $1 in
    -s) NL="Num"
        CL="Caps"
        SL="Scr"
        SPASE=" ";;
    -S) NL="NUM"
        CL="CAPS"
        SL="SCR"
        SPASE=" ";;
    -h|--help) clear
echo -e "Script `basename $0` designed to display key NumLock, CapsLock, ScrollLock

Options
    -s 		to display shot value, like Num, Caps, Scr
    -S 		to display shot value, like NUM, CAPS, SCR
    -h, --help 	to help ";;
    *)  NL="NumLock"
        CL="CapsLock"
        SL="ScrollLock"
        SPASE=" 	 ";;
esac

if [[ `echo "$KEY_INFO"| grep "CapsLock:off"` ]]; then CL=`echo $CL | sed "s/[a-zA-Z]/  /g"`; fi
if [[ `echo "$KEY_INFO"| grep "NumLock:off"` ]]; then NL=`echo $NL | sed "s/[a-zA-Z]/  /g"`; fi
if [[ `echo "$KEY_INFO"| grep "ScrollLock:off"` ]]; then SL=`echo $SL | sed "s/[a-zA-Z]/  /g"`; fi

echo -e "$NL$SPASE$CL$SPASE$SL"

exit 0
