#!/bin/bash

# функция отображения тегов
tagi ()
{
# разделители при выводе информации
separ1=" "
separ2=" "

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

# если теги пусты - делаем подмену полей, на крайний случай вставляем имя файла
if [ -z ${artist// /} ] 
 then separ1=''
fi
if [ -z ${songtitle// /} ]
 then songtitle=${title}
      if [ -z ${songtitle// /} ]
       then songtitle=${file##*/} 
      fi
fi


# выводим тег
echo "$state\
$artist\
$separ1\
$songtitle\
$separ2\
$timeleft"

## раскомментируте если нужно выводить теги другим цветом 
## цвет шрифта
## указывается название цвета - green, red и т.д. или hex-код цвета - #0000FF
#FONT_COLOR="#FF0000"

## вывод цветного тега
#echo "<txt><span foreground=\"$FONT_COLOR\">\
#"$state\
#$artist\
#$separ1\
#$songtitle\
#$separ2\
#$timeleft"\
#</span></txt>"
}

# проверяем запущен ли mocp и если запущен выполняем функцию вывода тегов
if [[ `pidof mocp` ]]
  then tagi
  else echo ""
fi

exit 0
