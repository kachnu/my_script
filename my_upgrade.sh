#!/bin/bash
#Скрипт обновления системы c помощью $APT
#author: kachnu
#email:  ya.kachnu@gmail.com

DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
   then DIALOG=dialog
fi

APT=apt-get

if [ -x "`which apt`" ]
   then APT=apt
fi


case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Обновление системы"
               MAIN_TEXT="Выберите действие:"
               MENU1="Запуск обновления"
               MENU2="Запуск полного обновления"
               MENU3="Редактирование /etc/apt/sources.list"
               MENU4="Очистить кэш и лишние пакеты"
               MENU5="Автоматическое обновление"
               MENU6="Обновление flashplugin"
               MENUh="Справка"
               MENU1_2="Вкл/выкл автообновление (ON или OFF)"
               MENU2_2="Час (0-23)"
               MENU3_2="Минута (0-59)"
               MENU4_2="День недели (1-7)"
               MENU5_2="День месяца (1-31)"
               MENU6_2="Месяц (1-12)"
               MENU7_2="Применить настройки"
               MENU8_2="Редактировать настройки вручную"


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
Пункт Запуск обновления - выполняет команду sudo $APT upgrade
Пункт Запуск полного обновления - выполняет команду sudo $APT dist-upgrade
После обновления пользователю предлагается выполнить предварительное связывание динамических библиотек, команда sudo prelink -amvRf
___________________________________"

               ;;
            *) #All locales
               MAIN_LABEL="Upgrade system"
               MAIN_TEXT="Select an action:"
               MENU1="Start safe upgrade"
               MENU2="Start full upgrade"
               MENU3="Edit /etc/apt/sources.list"
               MENU4="Clear & Autoremove"
               MENU5="Auto-upgrade"
               MENU6="Update flashplugin"
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
Item Start update - executes the command sudo $APT upgrade
Item Running a full update - executes the command sudo $APT dist-upgrade
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
  $DIALOG --title "$ATTENTION" --yesno "$PRELINK_TEXT" 10 60
  if [ $? == 0 ]
     then echo "Start prelink"; sudo prelink -amvRf
   fi
fi
}
#########################################################
Autoupgrade () #Автоматическое обновление
{

ANSWER=$($DIALOG  --cancel-button "Back" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 13 50\
    7\
        1 "$MENU1_2: $autoupgrade"\
        2 "$MENU2_2: $HOUR"\
        3 "$MENU3_2: $MINUTE"\
        4 "$MENU4_2: $DAY_WEEK"\
        5 "$MENU5_2: $DAY_MONTH"\
        6 "$MENU6_2: $MONTH"\
        7 "$MENU7_2" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit to main form ; MainForm
fi
case $ANSWER in
      1 ) if [ -f "/etc/cron.d/autoupgrade" ]
            then sudo cp /etc/cron.d/autoupgrade /etc/cron.d/autoupgrade.backup
                 sudo mv -f /etc/cron.d/autoupgrade.backup '/etc/cron.d/!autoupgrade'
                 autoupgrade="OFF"
          fi
          if [ -f "/etc/cron.d/!autoupgrade" ]
            then sudo mv -f '/etc/cron.d/!autoupgrade' /etc/cron.d/autoupgrade
                 autoupgrade="ON"
          fi
          Autoupgrade;;
      2 ) HOUR=$($DIALOG --title "$MENU2_2" --inputbox "" 10 60 $HOUR 3>&1 1>&2 2>&3 | sed "s/[^0-9,*/]//g")
          if [ $? != 0 ]
            then HOUR=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $2}'`
                 HOUR=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $2}'`
          fi
          Autoupgrade;;
      3 ) MINUTE=$($DIALOG --title "$MENU3_2" --inputbox "" 10 60 $MINUTE 3>&1 1>&2 2>&3 | sed "s/[^0-9,*/]//g")
          if [ $? != 0 ]
            then MINUTE=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $1}'`
                 MINUTE=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $1}'`
          fi
          Autoupgrade;;
      4 ) DAY_WEEK=$($DIALOG --title "$MENU4_2" --inputbox "" 10 60 $DAY_WEEK 3>&1 1>&2 2>&3 | sed "s/[^0-9,*/]//g")
          if [ $? != 0 ]
            then DAY_WEEK=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $3}'`
                 DAY_WEEK=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $3}'`
          fi
          Autoupgrade;;
      5 ) DAY_MONTH=$($DIALOG --title "$MENU5_2" --inputbox "" 10 60 $DAY_MONTH 3>&1 1>&2 2>&3 | sed "s/[^0-9,*/]//g")
          if [ $? != 0 ]
            then DAY_MONTH=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $4}'`
                 DAY_MONTH=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $4}'`
          fi
          Autoupgrade;;
      6 ) MONTH=$($DIALOG --title "$MENU6_2" --inputbox "" 10 60 $MONTH 3>&1 1>&2 2>&3 | sed "s/[^0-9,*/]//g")
          if [ $? != 0 ]
            then MONTH=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $5}'`
                 MONTH=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $5}'`
          fi
          Autoupgrade;;
      7 ) echo -n "# /etc/cron.d/autoupgrade: crontab entries for autoupgrade

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

$MINUTE $HOUR $DAY_WEEK $DAY_MONTH $MONTH   root  export DISPLAY=:0 && beep
" | sudo tee /etc/cron.d/autoupgrade > /dev/null
          if [ -f /etc/cron.d/!autoupgrade ]
             then sudo mv /etc/cron.d/autoupgrade /etc/cron.d/!autoupgrade
          fi
          ;;
       8 ) if [ -f /etc/cron.d/!autoupgrade ]
             then sudo nano /etc/cron.d/!autoupgrade
           fi
           if [ -f /etc/cron.d/autoupgrade ]
             then sudo nano /etc/cron.d/autoupgrade
           fi
esac
echo "$EXIT_TEXT"
read input
MainForm

}

#########################################################
MainForm () #Главная форма
{
if [ -f /etc/cron.d/autoupgrade ]
   then
        HOUR=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $2}'`
        MINUTE=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $1}'`
        DAY_WEEK=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $3}'`
        DAY_MONTH=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $4}'`
        MONTH=`cat /etc/cron.d/autoupgrade | grep beep | awk '{print $5}'`
        autoupgrade="ON"
else
    if [ -f /etc/cron.d/!autoupgrade ]
      then
        HOUR=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $2}'`
        MINUTE=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $1}'`
        DAY_WEEK=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $3}'`
        DAY_MONTH=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $4}'`
        MONTH=`cat /etc/cron.d/!autoupgrade | grep beep | awk '{print $5}'`
        autoupgrade="OFF"
     else
        HOUR="22"
        MINUTE="01"
        DAY_WEEK="6"
        DAY_MONTH="*"
        MONTH="*"

   fi
fi


#       5 "$MENU5 $autoupgrade"\

ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 13 50\
    7\
        1 "$MENU1"\
        2 "$MENU2"\
        3 "$MENU3"\
        4 "$MENU4"\
        5 "$MENU6"\
        h "$MENUh" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
      1 ) sudo $APT update; sudo $APT upgrade && echo "$MENU1 - $ALLOK"; PrelinkSystem ;;
      2 ) sudo $APT update; sudo $APT dist-upgrade && echo "$MENU2 - $ALLOK"; PrelinkSystem ;;
      3 ) Check nano; sudo nano /etc/apt/sources.list ;;
      4 ) sudo $APT autoremove
          dpkg -l | awk '/^rc/ {print $2}' | xargs sudo dpkg --purge
          sudo rm -r /var/cache/apt/archives && echo "remove /var/cache/apt/archive"
          sudo rm -r /var/cache/apt-xapian-index && echo "remove /var/cache/apt-xapian-index";;
      5 ) if [ -x "`sudo which update-flashplugin-nonfree`" ]
             then
             sudo cp /etc/wgetrc /etc/wgetrc.bak
             if [ "$ftp_proxy" != '' ] || [ "$http_proxy" != '' ] || [ "$https_proxy" != '' ]
                then echo "ftp_proxy = $ftp_proxy
http_proxy = $http_proxy
https_proxy = $https_proxy
use_proxy = on" | sudo tee --append /etc/wgetrc > /dev/null
             fi
             echo start update-flashplugin-nonfree
             sudo update-flashplugin-nonfree --install
             sudo update-flashplugin-nonfree --status
             sudo mv /etc/wgetrc.bak /etc/wgetrc
          fi
          if [ -x "`sudo which update-pepperflashplugin-nonfree`" ]
             then
             sudo cp /etc/wgetrc /etc/wgetrc.bak
             if [ "$ftp_proxy" != '' ] || [ "$http_proxy" != '' ] || [ "$https_proxy" != '' ]
                then echo "ftp_proxy = $ftp_proxy
http_proxy = $http_proxy
https_proxy = $https_proxy
use_proxy = on" | sudo tee --append /etc/wgetrc > /dev/null
             fi
             echo start update-pepperflashplugin-nonfree
             sudo update-pepperflashplugin-nonfree --install
             sudo update-pepperflashplugin-nonfree --status
             sudo mv /etc/wgetrc.bak /etc/wgetrc
          fi
          ;;
      h ) Help;;
     '' ) ;;
      * ) echo "oops! - $ANSWER";;
esac
echo "$EXIT_TEXT"
read input
MainForm
}


case $1 in
     "-u"  ) sudo $APT update; sudo $APT -y dist-upgrade;;
     "-uv" ) sudo $APT update; sudo $APT dist-upgrade && echo "$MENU2 - $ALLOK"
             echo "$EXIT_TEXT"
             read input;;
        *  ) MainForm ;;
esac

exit 0
