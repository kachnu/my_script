#!/bin/bash
#Скрипт обновления системы c помощью apt-get
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
               MAIN_LABEL="Обновление системы"
               MAIN_TEXT="Выберите действие:"
               MENU1="Запуск обновления"
               MENU2="Запуск полного обновления"
               MENU3="Редактирование /etc/apt/sources.list"
               MENU4="Обновление flashplugin-nonfree"
               MENUh="Справка"
               PRELINK_TEXT="Для ускорения запуска приложений рекомендуется воспользоваться утилитой prelink!
               
Запустить prelink сейчас?"
               EXIT_TEXT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               CHECK_PO="- не найдено!"
               ALLOK="Задание выполнено!"
               HELP="
____________________________________
   Справка
Пункт Запуск обновления - выполняет команду sudo apt-get upgrade
Пункт Запуск полного обновления - выполняет команду sudo apt-get dist-upgrade
После обновления пользователю предлагается выполнить предварительное связывание динамических библиотек, команда sudo prelink -amvRf
___________________________________"
             
               ;;
            *) #All locales
               MAIN_LABEL="Upgrade system"
               MAIN_TEXT="Select an action:"
               MENU1="Start safe upgrade"
               MENU2="Start full upgrade"
               MENU3="Edit /etc/apt/sources.list"
               MENU4="Update flashplugin-nonfree"
               MENUh="Help"
               PRELINK_TEXT="To speed up the application launch is recommended to use the utility prelink!
               
Run prelink Now?"
               EXIT_TEXT="
Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               CHECK_PO="- not found!"
               ALLOK="All be done!"
               HELP="
____________________________________
Help
Item Start update - executes the command sudo apt-get upgrade
Item Running a full update - executes the command sudo apt-get dist-upgrade
After the upgrade, the user is prompted to perform a preliminary binding dynamic libraries, the command sudo prelink -amvRf
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
PrelinkSystem () #Перезагрузка
{
if [ -x "`which "/usr/sbin/prelink"`" ]
 then
  whiptail --title "$ATTENTION" --yesno "$PRELINK_TEXT" 10 60
  if [ $? == 0 ]
     then echo "Start prelink"; sudo prelink -amvRf
   fi
fi
}
#########################################################
MainForm () #Главная форма
{
flash="4"
if ! [ -f /usr/lib/flashplugin-nonfree/libflashplayer.so ]
 then flash=''
  MENU4=''
fi

ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 13 50\
    5\
        1 "$MENU1"\
        2 "$MENU2"\
        3 "$MENU3"\
        "$flash" "$MENU4"\
        h "$MENUh" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
  1 ) sudo apt-get update; sudo apt-get upgrade && echo "$MENU1 - $ALLOK"; PrelinkSystem ;; 
  2 ) sudo apt-get update; sudo apt-get dist-upgrade && echo "$MENU2 - $ALLOK"; PrelinkSystem ;;
  3 ) Check nano; sudo nano /etc/apt/sources.list ;;
  4 ) Check sudo update-flashplugin-nonfree; 
      sudo cp /etc/wgetrc /etc/wgetrc.bak
      if [ "$ftp_proxy" != '' ] || [ "$http_proxy" != '' ] || [ "$https_proxy" != '' ]
        then echo "ftp_proxy = $ftp_proxy
http_proxy = $http_proxy
https_proxy = $https_proxy
use_proxy = on" | sudo tee --append /etc/wgetrc
      fi
      sudo update-flashplugin-nonfree --install
      sudo update-flashplugin-nonfree --status
      sudo mv /etc/wgetrc.bak /etc/wgetrc
      ;;
  h ) Help;;
 '' ) ;;
  * ) echo "oops! - $ANSWER";;
esac
echo "$EXIT_TEXT"
read input
MainForm
}

MainForm
exit 0
