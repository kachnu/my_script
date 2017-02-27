#!/bin/bash
#Скрипт установки драйверов на видео-устройства NVIDIA Optimus
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
               MAIN_LABEL="Cкрипт NVIDIA Optimus"
               MAIN_TEXT="Выберите действие:"
               MENU1="Установка NVIDIA Optimus (non-free)"
               MENU2="Установка NVIDIA Optimus (nouveau)"
               MENU3="Запуск теста NVIDIA Optimus"
               MENUh="Справка"
               REBOOT_TEXT="Для применения настроек необходимо перезагрузить систему!
               
Перезагрузить систему сейчас?"
               EXIT_TEXT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               CHECK_PO="- не найдено!"
               ALLOK="Задание выполнено!"
               HELP="
____________________________________
   Справка
Русская инструкция - https://wiki.debian.org/ru/Bumblebee
___________________________________"
             
               ;;
            *) #All locales
               MAIN_LABEL="Scripts NVIDIA Optimus"
               MAIN_TEXT="Select an action:"
               MENU1="Install NVIDIA Optimus (non-free)"
               MENU2="Install NVIDIA Optimus (nouveau)"
               MENU3="Help"
               MENUh="Start test NVIDIA Optimus"
               REBOOT_TEXT="To apply the settings you must reboot the system !
               
Reboot Sistem now?"
               EXIT_TEXT="
Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               CHECK_PO="- not found!"
               ALLOK="All be done!"
               HELP="
____________________________________
Help
Manual - https://wiki.debian.org/Bumblebee
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
RebootSystem () #Перезагрузка
{
whiptail --title "$ATTENTION" --yesno "$REBOOT_TEXT" 10 60
if [ $? == 0 ]
 then sudo reboot
 else exit 0
fi
}
#########################################################
MainForm () #Главная форма
{
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 13 50\
    4\
        1 "$MENU1"\
        2 "$MENU2"\
        3 "$MENU3"\
        h "$MENUh" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
  1 ) sudo apt-get update; sudo apt-get install bumblebee-nvidia primus && echo "$ALLOK"; RebootSystem ;; 
  2 ) sudo apt-get update; sudo apt-get install bumblebee primus && echo "$ALLOK"; RebootSystem ;; 
  3 ) Check optirun && optirun glxgears -info;;
  h ) Help;;
  * ) echo "oops! - $ANSWER" ;;
esac
echo "$EXIT_TEXT"
read input
MainForm
}

MainForm

exit 0
