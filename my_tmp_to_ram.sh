#!/bin/bash
#Скрипт предназначен для монтирования /tmp в tmpfs 
#таким образом все временные файлы будут храниться в ОЗУ, что повышает быстродействие и уменьшает износ HDD и SSD
#основой для созданитя скрипта послужила статья http://vasilisc.com/tmp-on-tmpfs
#author: kachnu
# email: ya.kachnu@yandex.ua

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
               MAIN_LABEL="Cкрипт /tmp в ОЗУ"
               MAIN_TEXT="Выберите действие:"
               MENU1="Временные файлы /tmp в ОЗУ"
               MENUh="Справка"
               HELP_EXIT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               RESTART_TEXT="Для применения настроек необходимо перезагрузить ПК! 

Перезагрузить ПК сейчас?"
               HELP="
____________________________________
   Справка

$0 - скрипт предназначен для /tmp в tmpfs 
Таким образом все временные файлы будут храниться в ОЗУ что повышает быстродействие и уменьшает износ HDD и SSD
Данная технология уже давно применяется в Solaris, Fedora и ArchLinux
Не рекомендуется использовать на ПК с малым объемом ОЗУ 
___________________________________"
             
               ;;
            *) #All locales
               MAIN_LABEL="/tmp to RAM"
               MAIN_TEXT="Select an action:"
               MENU1="Temporary files /tmp to RAM"
               MENUh="Help"
               HELP_EXIT="
Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               RESTART_TEXT="To apply the settings you must reboot!
            
Reboot now?"
               HELP="
____________________________________
   Help
$0 - script for /tmp on tmpfs
All the temporary files are stored in the RAM that improves performance and reduces wear  HDD and SSD
This technology has long been used in Solaris, Fedora and ArchLinux
It is not recommended to use at PC with small RAM
___________________________________"

               ;;
esac    
#########################################################
RestartPC () #Перезагрузка
{
$DIALOG --title "$ATTENTION" --yesno "$RESTART_TEXT" 10 60
if [ $? == 0 ]
 then sudo reboot
 else MainForm
fi
}
#########################################################
CheckState () #Проверка состояния
{
STATE_AUTOMOUNT=$(cat /etc/fstab | grep "^tmpfs /tmp tmpfs")
if [ "$STATE_AUTOMOUNT" != '' ]
 then STATE_AUTOMOUNT="ON"
 else STATE_AUTOMOUNT="OFF"
fi
STATE_STATUS=$(mount | grep "/tmp")
if [ "$STATE_STATUS" != '' ]
 then STATE_STATUS="ON"
 else STATE_STATUS="OFF"
fi
}
#########################################################
MainForm () #Главная форма
{
CheckState
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 10 60\
    3\
       "$MENU1 (automount-$STATE_AUTOMOUNT, status-$STATE_STATUS)" ""\
       "$MENUh" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
  "$MENU1"* ) if [ "$STATE_AUTOMOUNT" = "OFF" ]  
               then echo -e "#Mount /tmp to RAM (/tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
               else sudo sed -i '/\/tmp tmpfs/d' /etc/fstab
              fi
              RestartPC
              ;;
   "$MENUh" ) echo "$HELP"
              echo "$HELP_EXIT"
              read x
              MainForm
              ;;
           *) MainForm 
              ;;
 esac
}
#########################################################

MainForm

exit 0
