#!/bin/bash

# цвета шрифтов
# указывается название цвета - green, red и т.д. или hex-код цвета - #0000FF
FONT_COLOR_ARTIST="red"
FONT_COLOR_SONG="#008000"
FONT_COLOR_TIME="#0000FF"

# цвет фона
BG_COLOR="#E8E8E7"

# Тип шрифта можно настроить в апплете xfce4-genmon-plugin
# а можно добавить к echo параметр weight=\"$WEIGTH\"
# при этом раскоментировать переменную WEIGTH и дать ей значения: regular - нормальный, bold - полужирный
# WEIGTH="bold"

function tagi
{
#title=`mocp -i |grep -w Title |cut -d : -f2`
#songtitle=`mocp -i |grep -w SongTitle |cut -d : -f2`
#artist=`mocp -i |grep -w Artist |cut -d : -f2`
#rate=`mocp -i |grep -w Rate |cut -d : -f2`
#bitrate=`mocp -i |grep -w Bitrate |cut -d : -f2`
#timeleft=`mocp -i |grep -w TimeLeft |cut -d : -f2-`
#currenttime=`mocp -i |grep -w CurrentTime |cut -d : -f2-`

IFS="
"
for line in $(mocp -i)
 do
    case $line in
      File*) file=`echo $line|cut -d : -f2`;;
      Title*) title=`echo $line|cut -d : -f2`;;
      Artist*) artist=`echo $line|cut -d : -f2`;;
      SongTitle*) songtitle=`echo $line|cut -d : -f2`;;
      Album*) albom=`echo $line|cut -d : -f2`;;
      TotalTime*) totaltime=`echo $line|cut -d : -f2-`;;
      TimeLeft*) timeleft=`echo $line|cut -d : -f2-`;;
      CurrentTime*) currenttime=`echo $line|cut -d : -f2-`;;
      Bitrate*) bitrate=`echo $line|cut -d : -f2`;;
      Rate*) rate=`echo $line|cut -d : -f2`;;
    esac
done

echo "<txt>\
<span bgcolor=\"$BG_COLOR\" foreground=\"$FONT_COLOR_ARTIST\">"$artist"</span>""\
<span bgcolor=\"$BG_COLOR\" foreground=\"$FONT_COLOR_SONG\">"$songtitle"</span>""\
<span bgcolor=\"$BG_COLOR\" foreground=\"$FONT_COLOR_TIME\">"$timeleft"</span>""\
</txt>"

#echo "<txt><span bgcolor=\"#333333\" weight=\"bold\" fgcolor=\"green\">"$artist" "" "$songtitle" "" "$timeleft"</span></txt><tool>mocp playing</tool>"
#echo "<txt><span bgcolor=\"#1C2948\" fgcolor=\"#bebebe\">"$artist""$songtitle""$timeleft"</span></txt>"
}

state=`mocp -i |grep -w State |cut -d : -f2`
if [ $state=PLAY ]
 then
  tagi
fi

exit 0
