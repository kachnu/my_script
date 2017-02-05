#!/bin/bash

# функция отображения тегов
tagi ()
{
# разделитель при выводе информации
separ=" -"

# перебираем вывод команды mocp -i и раскладываем все по переменным
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
                           separ='';;
              esac  ;;
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


# выводим тег
echo "$state\
$artist\
$separ\
$songtitle\
$separ\
$timeleft"


## цвета шрифтов
## указывается название цвета - green, red и т.д. или hex-код цвета - #0000FF
#FONT_COLOR_ARTIST="red"
#FONT_COLOR_SONG="#008000"
#FONT_COLOR_TIME="#0000FF"

## цвет фона
#BG_COLOR="#E8E8E7"

## Тип шрифта можно настроить в апплете xfce4-genmon-plugin
## а можно добавить к echo параметр weight=\"$WEIGTH\"
## при этом раскоментировать переменную WEIGTH и дать ей значения: regular - нормальный, bold - полужирный
## WEIGTH="bold"

#echo "<txt>\
#<span bgcolor=\"$BG_COLOR\" foreground=\"$FONT_COLOR_ARTIST\">"$artist"</span>""\
#<span bgcolor=\"$BG_COLOR\" foreground=\"$FONT_COLOR_SONG\">"$songtitle"</span>""\
#<span bgcolor=\"$BG_COLOR\" foreground=\"$FONT_COLOR_TIME\">"$timeleft"</span>""\
#</txt>"
}

# проверяем запущен ли mocp и если запущен выполняем функцию вывода тегов
if [[ `pidof mocp` ]]
  then tagi
  else echo ""
fi

exit 0
