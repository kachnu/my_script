#!/bin/bash
# xfce 4.12
# Display moc info
# author: kachnu
# email:  ya.kachnu@yandex.ua

OPT=$1

SCRIPT_WAY=`readlink -e "$0"`

# display moc info
ReadTag ()
{
# separators in the output of information
separ1=" "
separ2=" "

# we sort out the output of the mocp -i command and lay out all the variables
IFS="
"
for line in `mocp -i`
 do
    case $line in
      State*) state=`echo $line|cut -d : -f2`
              case $line in
                   *PLAY*) state='▶';;
                   *PAUSE*) state='❚❚';;
                   *STOP*) state='■ moc'
                           separ1=''
                           separ2='';;
              esac  ;;
      File*) file=`echo $line|cut -d : -f2`;;
      Title*) title=`echo $line|cut -d : -f2`;;
      Artist*) artist=`echo $line|cut -d : -f2`;;
      SongTitle*) songtitle=`echo $line|cut -d : -f2`;;
      Album*) album=`echo $line|cut -d : -f2`;;
      TotalTime*) totaltime=`echo $line|cut -d : -f2-`;;
      TimeLeft*) timeleft=`echo $line|cut -d : -f2-`;;
      CurrentTime*) currenttime=`echo $line|cut -d : -f2-`;;
      Bitrate*) bitrate=`echo $line|cut -d : -f2`;;
      Rate*) rate=`echo $line|cut -d : -f2`;;
    esac
done

# if the tags are empty - we do the substitution of fields, in extreme cases we insert the name of the file
if [ -z ${artist// /} ]
 then separ1=''
fi
if [ -z ${songtitle// /} ]
 then songtitle=${title}
      if [ -z ${songtitle// /} ]
       then songtitle=${file##*/}
      fi
fi

# generate a tag for output
tag=`echo "$state\
$artist\
$separ1\
$songtitle\
$separ2\
$timeleft"`

tag_deamon=`echo "$state\
$artist\
$separ1\
$songtitle"`

## раскомментируте если нужно выводить теги другим цветом
## цвет шрифта
## указывается название цвета - green, red и т.д. или hex-код цвета - #0000FF
#FONT_COLOR="#FF0000"

## вывод цветного тега
#tag=`echo "<txt><span foreground=\"$FONT_COLOR\">\
#"$state\
#$artist\
#$separ1\
#$songtitle\
#$separ2\
#$timeleft"\
#</span></txt>"`
}

# make plugin moc info in panel
MakePlugin ()
{
# find panel
PANEL=`xfconf-query -c xfce4-panel -p /panels -v | awk '{print $1}' | grep [0-9] | sed 's/^/panel-/g'`

# select panel
PANEL=`echo "$PANEL" | sed "s/^ //g" | sed "s/ /\\\n/g" | zenity --list --title="Add moc info plugin" \
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
echo -e "Command=$SCRIPT_WAY -t
UseLabel=0
Text=(genmon)
UpdatePeriod=2000
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
    -p) MakePlugin;;
    -d) if ! [[ `which notify-send` ]]
           then exit 1
        fi
        while true ; do
          if [[ `pgrep -u $USER mocp` ]]; then
               ReadTag
               old_tag=`cat /dev/shm/moc_tag.txt`
               if [[ "$tag_deamon" !=  "$old_tag" ]]
                 then notify-send $tag_deamon
                      echo "$tag_deamon" > /dev/shm/moc_tag.txt
               fi
          fi
         sleep 2
       done;;
    -k) killall `basename $SCRIPT_WAY` ;;
    -n) if ! [[ `which notify-send` ]]
           then exit 1
        fi
        if [[ `pgrep -u $USER mocp` ]]; then
            ReadTag
            notify-send $tag_deamon
        fi;;
    -t) if [[ `pgrep -u $USER mocp` ]]; then
            ReadTag
            echo "$tag"
       else echo ""
       fi;;
    *) #clear
       echo -e "Script `basename $SCRIPT_WAY` designed to display info moc player

Options
    -p   make Plugin in xfce4-panel
    -d   start Daemon to display info moc player in notify-send
    -k   Kill `basename $SCRIPT_WAY`
    -n   display info moc player in Notify-send
    -t   print Tag";;

esac

exit 0
