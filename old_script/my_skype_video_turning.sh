#!/bin/bash
#Скрипт предназначен для поворота изображения в скайпе
#author: kachnu
# email: ya.kachnu@gmail.com

DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
   then DIALOG=dialog
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Cкрипт для поворота видео в Skype"
               MAIN_TEXT="Выберите действие:"
               MENU1="Отображать видео по умолчанию"
               MENU2="Отображать зеркально по горизонтали"
               MENU3="Отображать зеркально по вертикали"
               MENU4="Отображать по горизонтали и по вертикали"
               MENU5="Удалить все проделки данного скрипта над скайпом"
               MENU6="Редактировать файл /usr/bin/skype"
               MENUh="Справка"
               HELP_EXIT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               CHECK_PO="- не найдено!"
               RESTART_TEXT="Запустить (перезапустить) Skype сейчас?"
               HELP="
____________________________________
   Справка

$0 - скрипт помогает настроить видео Skype.
___________________________________"
             
               ;;
            *) #All locales
               MAIN_LABEL="Scripts for turning video in Skype"
               MAIN_TEXT="Select an action:"
               MENU1="Display the default video"
               MENU2="Display mirror horizontally"
               MENU3="Display mirror vertically"
               MENU4="Show on the horizon and vertically"
               MENU5="Delete all the tricks of the script over skype"
               MENU6="Edit the file /usr/bin/skype"
               MENUh="Help"
               HELP_EXIT="
Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               CHECK_PO="- not found!"
               RESTART_TEXT="Start (restart) Skype now?"
               HELP="
____________________________________
   Help

$0 - script helps adjust video Skype.
___________________________________"

               ;;
esac    

#########################################################
Check () #Функция проверки ПО
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument check error; exit 1
fi
if [ ! -x "`which "$1"`" ] #Проверка наличия ПО
 then echo $1 $CHECK_PO
 exit 1
fi
}
#########################################################
Help () #Справка
{
echo "$HELP"
}
#########################################################
RestartSkype () #Перезапуск скайпа
{
$DIALOG --title "$ATTENTION" --yesno "$RESTART_TEXT" 10 60
if [ $? == 0 ]
 then 
 killall skype.real
 killall skype
 sleep 2
 skype &
 else MainForm
fi
}
#########################################################
VideoTurn () #Добавляем в прослоку, параметры запуска скайпа - переворот видео
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument check error; exit 1
fi
if [ ! -f /usr/lib/i386-linux-gnu/libv4l/v4l2convert.so ]
 then echo error - v4l2convert.so not found; exit 1
fi

sudo sh -c "echo '#!/bin/bash
#FLAGS 0=normal, 1=turn left-right, 2=turn up-down, 3=turn up-down and left-right
export LIBV4LCONTROL_FLAGS=$1
LD_PRELOAD=/usr/lib/i386-linux-gnu/libv4l/v4l2convert.so /usr/bin/skype.real \"\$@\" &
exit 0' > /usr/bin/skype"
}
#########################################################
MakeFakeSkype () #Создаем прослойку перед запуском скайпа
{
if [ ! -f /usr/bin/skype.real ]
 then sudo mv /usr/bin/skype /usr/bin/skype.real
      sudo sh -c "echo '#!/bin/bash
/usr/bin/skype.real \"\$@\" &
exit 0' > /usr/bin/skype"
      sudo chmod +x /usr/bin/skype
fi
}
#########################################################
CheckState ()
{
STATE_DEF=''
STATE_HOR=''
STATE_VER=''
STATE_HOR_VER=''
if [ -f /usr/bin/skype.real ] && [ -f /usr/bin/skype ]
 then
 STATE_ALL=$(cat "/usr/bin/skype" | grep LIBV4LCONTROL_FLAGS | sed "s/export LIBV4LCONTROL_FLAGS=//g")
 case $STATE_ALL in
   0) STATE_DEF='- ON';;
   1) STATE_HOR='- ON';;
   2) STATE_VER='- ON';;
   3) STATE_HOR_VER='- ON';;
   *) echo oops! - $STATE_ALL;;
 esac
fi 
}

#########################################################
MainForm () #Главная форма
{
CheckState
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 15 60\
    7\
        1 "$MENU1 $STATE_DEF"\
        2 "$MENU2 $STATE_HOR"\
        3 "$MENU3 $STATE_VER"\
        4 "$MENU4 $STATE_HOR_VER"\
        5 "$MENU5"\
        6 "$MENU6"\
        h "$MENUh" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
    1) # normal
       MakeFakeSkype
       VideoTurn 0
       RestartSkype
       MainForm
       ;;
    2) # ->
       MakeFakeSkype
       VideoTurn 1
       RestartSkype
       MainForm
       ;;
    3) # ^
       MakeFakeSkype
       VideoTurn 2
       RestartSkype
       MainForm
       ;;   
    4) # ^ + ->
       MakeFakeSkype
       VideoTurn 3
       RestartSkype
       MainForm
       ;;  
    5) #del fake skype
       sudo mv /usr/bin/skype.real /usr/bin/skype
       MainForm
       ;;
    6) Check nano
       sudo nano /usr/bin/skype
       MainForm
       ;; 
    h) Help
       echo $HELP_EXIT 
       read x
       MainForm
       ;;              
    *) echo oops! - $ANSWER
       exit 1
       ;;
esac
}
#########################################################
Check skype
MainForm

exit 0
