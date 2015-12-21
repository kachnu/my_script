#!/bin/bash
#Скрипт для применения/отмены prelink
#Prelink - программа для предварительного динамического связывания библиотек, позволяет уменьшить время запуска программ. 
#author: kachnu
#email:  ya.kachnu@yandex.ua

DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
 then
  DIALOG=whiptail
  if [ ! -x "`which "$DIALOG"`" ]
  then DIALOG=dialog
  fi
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Cкрипт prelink"
               MAIN_TEXT="Выберите действие:"
               MENU1="Запуск связывания prelink"
               MENU2="Отмена связывания prelink"
               MENUh="Справка"
               EXIT_TEXT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               CHECK_PO="- не найдено!"
               ALLOK="Задание выполнено!"
               HELP="
____________________________________
   Справка
prelink - утилита для предварительного связывания динамических библиотек, позволяет уменьшить  время запуска программ.
При обновлении библиотек процесс связывания необходимо запускать заново.
___________________________________"
             
               ;;
            *) #All locales
               MAIN_LABEL="Scripts for prelink"
               MAIN_TEXT="Select an action:"
               MENU1="Start prelink "
               MENU2="Start un-prelink "
               MENUh="Help"
               EXIT_TEXT="
Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               CHECK_PO="- not found!"
               ALLOK="All be done!"
               HELP="
____________________________________
Help
prelink - utility prebinding dynamic libraries can reduce the startup time.
When updating library binding process must be run again.
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
MainForm () #Главная форма
{
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 12 50\
    3\
        1 "$MENU1"\
        2 "$MENU2"\
        h "$MENUh" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
  1 ) sudo prelink -amvRf && echo "$ALLOK";; 
  2 ) sudo prelink -auv && echo "$ALLOK";; 
  h ) Help;;
  * ) echo "oops!";;
esac
echo "$EXIT_TEXT"
read input
MainForm
}
Check /usr/sbin/prelink
MainForm

exit 0
