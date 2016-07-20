#!/bin/bash
# Скрипт предназначен для настройки параметров работы с дисками и памятью
# основой для создания скрипта послужили статьи 
# http://vasilisc.com/tmp-on-tmpfs
# http://fx-files.ru/archives/704
# https://wiki.archlinux.org/index.php/Solid_State_Drives_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)
#
#
#
# author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
 then
  DIALOG=whiptail
  if [ ! -x "`which "$DIALOG"`" ]
  then DIALOG=dialog
  fi
fi

EDITOR=nano

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Настройка параметров работы с дисками и памятью"
               MAIN_TEXT="Выберите действие:"
               MENU1="Параметры монтирования"
               MENU2="Настройки Swap и Cashe"
               MENU3="Временные файлы /tmp в ОЗУ"
               MENU4="Логи в ОЗУ"
               MENU5="Автонастройка для SSD"
               MENU6="Редактирование /etc/fstab"
               MENUh="Справка"
               MENU1_SWAP="Подкачка swap"
               MENU2_SWAP="Настроить порог swappiness"
               MENU2_SWAP_SWAPPINESS="Введите значение в % (от 0 до 100) свободной ОЗУ, при котором начнется задействование подкачки swap"
               MENU3_SWAP="Настроить vfs_cache_pressurecat"
               MENU3_SWAP_VFS_CACHE_PRESSURECAT="Введите значение (от 0 до 1000), чтобы определить отношение ядра к освободившимся страницам памяти. 
Чем ниже значение, тем дольше информация хранится в ОЗУ и меньше кэшируется, значение выше 100 способствует агрессивному кэшированию.
Для SSD рекомендуют 50, для HDD - 1000."
               HELP_EXIT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               RESTART_TEXT="Для применения настроек необходимо перезагрузить ПК! 

Перезагрузить ПК сейчас?"
               HELP="
____________________________________
   Справка

$0 - скрипт предназначен для настроки таких параметров системы как: журналирование, подкачка, способы хранения временных файлов, монтирование и т.д.
__
* $MENU1
__
* $MENU2
Позволяет настроить способ подкачки.
__
* $MENU3
Все временные файлы будут храниться в ОЗУ что повышает быстродействие и уменьшает износ HDD и SSD
Данная технология уже давно применяется в Solaris, Fedora и ArchLinux
Не рекомендуется использовать на ПК с малым объемом ОЗУ 
__
* $MENU4
__
* $MENU5
__
* $MENU6

___________________________________"
             
               ;;
            *) #All locales
               MAIN_LABEL="/tmp to RAM"
               MAIN_TEXT="Select an action:"
               MENU3="Temporary files /tmp to RAM"
               MENU6="Edit /etc/fstab"
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
CheckStateTmpfs () #Проверка состояния
{
STATE_AUTOMOUNT_TMP=$(cat /etc/fstab | grep "^tmpfs /tmp tmpfs")
if [ "$STATE_AUTOMOUNT_TMP" != '' ]
 then STATE_AUTOMOUNT_TMP="ON"
 else STATE_AUTOMOUNT_TMP="OFF"
fi
STATE_STATUS_TMP=$(mount | grep "/tmp")
if [ "$STATE_STATUS_TMP" != '' ]
 then STATE_STATUS_TMP="ON"
 else STATE_STATUS_TMP="OFF"
fi


STATE_AUTOMOUNT_LOG=$(cat /etc/fstab | grep "^tmpfs /tmp tmpfs")
if [ "$STATE_AUTOMOUNT_LOG" != '' ]
 then STATE_AUTOMOUNT_LOG="ON"
 else STATE_AUTOMOUNT_LOG="OFF"
fi
STATE_STATUS_LOG=$(mount | grep "/tmp")
if [ "$STATE_STATUS_LOG" != '' ]
 then STATE_STATUS_LOG="ON"
 else STATE_STATUS_LOG="OFF"
fi


}
#########################################################
CheckStateSwap ()
{
STATE_AUTOMOUNT_SWAP=$(cat /etc/fstab | grep "swap" | sed -e '/\#/d')
if [ "$STATE_AUTOMOUNT_SWAP" != '' ]
 then STATE_AUTOMOUNT_SWAP="ON"
 else STATE_AUTOMOUNT_SWAP="OFF"
fi

STATE_STATUS_SWAP=$(cat /proc/swaps | sed -e '1d')
if [ "$STATE_STATUS_SWAP" != '' ]
 then STATE_STATUS_SWAP="ON"
 else STATE_STATUS_SWAP="OFF"
fi

SWAPPINESS=$(cat /proc/sys/vm/swappiness)

VFS_CACHE_PRESSURECAT=$(cat /proc/sys/vm/vfs_cache_pressure)
}
#########################################################
SwapForm () #Форма для настройки swap
{
CheckStateSwap
ANSWER=$($DIALOG  --cancel-button "Exit" --title "Swap settings" --menu \
    "$MAIN_TEXT" 14 60\
    4\
       "$MENU1_SWAP (automount-$STATE_AUTOMOUNT_SWAP, status-$STATE_STATUS_SWAP)" ""\
       "$MENU2_SWAP ($SWAPPINESS% free RAM)" ""\
       "$MENU3_SWAP ($VFS_CACHE_PRESSURECAT filesystem caches)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo "to MainForm"; MainForm
fi
case $ANSWER in
 "$MENU1_SWAP"* ) if [ "$STATE_AUTOMOUNT_SWAP" = "OFF" ]  
                    then sudo sed -i '/swap/s/\#//g' /etc/fstab
                    else sudo sed -i '/swap/s/^/\#/g' /etc/fstab
                  fi
                  
                  if [ "$STATE_STATUS_SWAP" = "OFF" ]  
                    then sudo swapon -a
                    else sudo swapoff -a
                  fi
                  SwapForm
                  ;;
 "$MENU2_SWAP"* ) while true; do
                     SWAPPINESS=$($DIALOG --title "$MENU2_SWAP" --inputbox "$MENU2_SWAP_SWAPPINESS" 14 60 $SWAPPINESS 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SwapForm ; break
                     fi
                     
                     if [[ "$SWAPPINESS" -ge 0 ]] && [[ "$SWAPPINESS" -le 100 ]]
                        then break
                     fi
                  done
                  sudo sysctl -w vm.swappiness=$SWAPPINESS
                  sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
                  echo -e "vm.swappiness=$SWAPPINESS" | sudo tee -a /etc/sysctl.conf
                  SwapForm
                  ;;
 "$MENU3_SWAP"* ) while true; do
                     VFS_CACHE_PRESSURECAT=$($DIALOG --title "$MENU3_SWAP" --inputbox "$MENU3_SWAP_VFS_CACHE_PRESSURECAT" 14 60 $VFS_CACHE_PRESSURECAT 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SwapForm ; break
                     fi
                     
                     if [[ "$VFS_CACHE_PRESSURECAT" -ge 0 ]] && [[ "$VFS_CACHE_PRESSURECAT" -le 1000 ]]
                        then break
                     fi
                  done
                  sudo sysctl -w vm.vfs_cache_pressure=$VFS_CACHE_PRESSURECAT
                  sudo sed -i '/vm.vfs_cache_pressure/d' /etc/sysctl.conf
                  echo -e "vm.vfs_cache_pressure=$VFS_CACHE_PRESSURECAT" | sudo tee -a /etc/sysctl.conf
                  SwapForm                 
                  ;;
               *) SwapForm 
                  ;;
 esac
}

#########################################################
MainForm () #Главная форма
{
CheckStateTmpfs
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 16 60\
    7\
       "$MENU1" ""\
       "$MENU2" ""\
       "$MENU3 (automount-$STATE_AUTOMOUNT_TMP, status-$STATE_STATUS_TMP)" ""\
       "$MENU4 (automount-$STATE_AUTOMOUNT_LOG, status-$STATE_STATUS_LOG)" ""\
       "$MENU5" ""\
       "$MENU6" ""\
       "$MENUh" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
   "$MENU2" ) SwapForm
              MainForm
              ;;
  "$MENU3"* ) if [ "$STATE_AUTOMOUNT_TMP" = "OFF" ]  
               then echo -e "#Mount /tmp to RAM (/tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
               else sudo sed -i '/\/tmp tmpfs/d' /etc/fstab
              fi
              RestartPC
              ;;
  "$MENU4"* ) if [ "$STATE_AUTOMOUNT_LOG" = "OFF" ]  
               then echo -e "#Mount /tmp to RAM (/tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
               else sudo sed -i '/\/tmp tmpfs/d' /etc/fstab
              fi
              RestartPC
              ;;
   "$MENU6" ) sudo $EDITOR /etc/fstab
              MainForm
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
