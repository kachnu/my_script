#!/bin/bash
# xfce 4.12
# Display key NumLock, CapsLock, ScrollLock
# author: kachnu
# email:  ya.kachnu@yandex.ua

OPT=$1
KEY_INFO=`xset -q | grep -m1 "00:" | sed "s/ //g"`

MakePlugin ()
{
# find panel
PANEL=`xfconf-query -c xfce4-panel -p /panels -v | awk '{print $1}' | grep [0-9]`

# select panel
PANEL=`echo "$PANEL" | sed "s/^ //g" | sed "s/ /\\\n/g" | zenity --list --title="Add lock-key plugin" \
                --text="select panel" --column="" --separator="\n"`

if [ $? != 0 ]; then
   exit 0
fi

#find max id
max_id=0
for id in `xfconf-query -c xfce4-panel -p /plugins -l -v | awk '{print $1}'| awk -F/ '{print $3}'| awk -F- '{print $2}'`; do
  if [ "$id" -gt "$max_id" ]; then
     max_id=$id
  fi
done

# new id for plugin
let new_id=$max_id+1

#create file-plugin
echo -e "Command=my_lockkey_stat.sh -S
UseLabel=0
Text=(genmon)
UpdatePeriod=1000
Font=(default)" > ~/.config/xfce4/panel/genmon-$new_id.rc

# add plugin to xfconf
xfconf-query -c xfce4-panel -p /plugins/plugin-$new_id -t string -s "genmon" --create

# add new id to plugin-ids
new_id_list=""

if [[ `xfconf-query -c xfce4-panel -p /panels/$PANEL/plugin-ids` ]]; then
      for id in `xfconf-query -c xfce4-panel -p /panels/$PANEL/plugin-ids| grep -v "Value is an\|^$" | grep -v :`; do
          new_id_list=$new_id_list" -t int -s "$id
      done
      new_id_list=$new_id_list" -t int -s "$new_id
      echo $new_id_list
      xfconf-query -c xfce4-panel -p /panels/$PANEL/plugin-ids -rR
      xfconf-query -c xfce4-panel -p /panels/$PANEL/plugin-ids $new_id_list --create
else  xfconf-query -c xfce4-panel -p /panels/$PANEL/plugin-ids --force-array -t int -s $new_id --create
fi

# restart panel
xfce4-panel -r
}

case $OPT in
    -s) NL="Num"
        CL="Caps"
        SL="Scr"
        SPASE=" ";;
    -S) NL="NUM"
        CL="CAPS"
        SL="SCR"
        SPASE=" ";;
    -p) MakePlugin;;
    -h|--help) clear
echo -e "Script `basename $0` designed to display key NumLock, CapsLock, ScrollLock

Options
    -s 		to display short value, like Num, Caps, Scr
    -S 		to display short value, like NUM, CAPS, SCR
    -p 		make plugin in xfce4-panel 
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
