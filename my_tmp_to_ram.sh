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
               MENU2="Настройки Swap & Sysctl"
               MENU3="Временные файлы /tmp в ОЗУ"
               MENU4="Логи /var/* в ОЗУ"
               MENU5="Автонастройка для SSD"
               MENU6="Редактирование /etc/fstab"
               MENU7="Редактирование /etc/sysctl.conf"
               MENUh="Справка"
               MENU1_SWAP="Подкачка swap"
               MENU2_SWAP="Настроить порог swappiness"
               MENU2_SWAP_SWAPPINESS="Введите значение в % (от 0 до 100) свободной ОЗУ, при котором начнется задействование подкачки swap.
Для ОЗУ 2 GB = 30, 4 GB = 10, 6 GB or more = 0."
               MENU3_SWAP="Настроить vfs_cache_pressurecat"
               MENU3_SWAP_VFS_CACHE_PRESSURECAT="Введите значение (от 0 до 1000), чтобы определить отношение ядра к освободившимся страницам памяти. 
Чем ниже значение, тем дольше информация хранится в ОЗУ и меньше кэшируется, значение выше 100 способствует агрессивному кэшированию.
Для SSD рекомендуют 50, для HDD - 1000."
               MENU4_SWAP="Режим laptop и активация отложенной записи"
               MENU5_SWAP="Отложенная запись dirty_writeback_centisecs"
               MENU5_SWAP_DIRTY_WRITEBACK_CENTISECS="Введите значение (от 0 до 60000), чтобы установить время задержки записи (запуска pdflush) на жесткий диск (100 ед. = 1 секунда).
Для SSD - 6000 (1 минута)"
               MENU6_SWAP="Настроить dirty_ratio"
               MENU6_SWAP_DIRTY_RATIO="Введите значение в % (от 0 до 100) - доля свободной системной памяти в процентах, по достижении которой процесс, ведущий запись на диск, инициирует запись \"грязных\" данных.
Для SSD - 60"
               MENU7_SWAP="Настроить dirty_background_ratio"
               MENU7_SWAP_DIRTY_BACKGROUND_RATIO="Введите значение в % (от 0 до 100) - доля свободной памяти в процентах от общей памяти всей системы, по достижении которой демон pdflush начинает сбрасывать данные их дискового кэша на сам диск.
Для SSD - 5"
               MENU8_SWAP="Сброс настроек sysctl по умолчанию"
               
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


STATE_AUTOMOUNT_LOG=$(cat /etc/fstab | grep "^tmpfs /var/")
if [ "$STATE_AUTOMOUNT_LOG" != '' ]
 then STATE_AUTOMOUNT_LOG="ON"
 else STATE_AUTOMOUNT_LOG="OFF"
fi
STATE_STATUS_LOG=$(mount | grep "/var/")
if [ "$STATE_STATUS_LOG" != '' ]
 then STATE_STATUS_LOG="ON"
 else STATE_STATUS_LOG="OFF"
fi


}
#########################################################
CheckStateSwapSysctl ()
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

VALUE_SWAP=$(cat /proc/swaps | sed -e '1d' | awk '{print $3}')
if [ "$VALUE_SWAP" != '' ]
 then VALUE_SWAP=", size="$VALUE_SWAP
fi

SWAPPINESS=$(cat /proc/sys/vm/swappiness)

VFS_CACHE_PRESSURECAT=$(cat /proc/sys/vm/vfs_cache_pressure)

LAPTOP_MODE=$(cat /proc/sys/vm/laptop_mode)
if [ "$LAPTOP_MODE" != '0' ]
 then LAPTOP_MODE="ON"
 else LAPTOP_MODE="OFF"
fi

DIRTY_WRITEBACK_CENTISECS=$(cat /proc/sys/vm/dirty_writeback_centisecs)

DIRTY_RATIO=$(cat /proc/sys/vm/dirty_ratio)

DIRTY_BACKGROUND_RATIO=$(cat /proc/sys/vm/dirty_background_ratio)
}
#########################################################
SwapSysctlForm () #Форма для настройки Swap & Sysctl
{
CheckStateSwapSysctl
ANSWER=$($DIALOG  --cancel-button "Back" --title "Swap & Sysctl settings" --menu \
    "$MAIN_TEXT" 16 62\
    8\
       "$MENU1_SWAP (automount-$STATE_AUTOMOUNT_SWAP, status-$STATE_STATUS_SWAP$VALUE_SWAP)" ""\
       "$MENU2_SWAP ($SWAPPINESS% free RAM)" ""\
       "$MENU3_SWAP ($VFS_CACHE_PRESSURECAT filesystem caches)" ""\
       "$MENU4_SWAP (status-$LAPTOP_MODE)" ""\
       "$MENU5_SWAP ($DIRTY_WRITEBACK_CENTISECS centisecs)" ""\
       "$MENU6_SWAP ($DIRTY_RATIO% RAM)" ""\
       "$MENU7_SWAP ($DIRTY_BACKGROUND_RATIO% RAM)" ""\
       "$MENU8_SWAP" "" 3>&1 1>&2 2>&3)
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
                  ;;
 "$MENU2_SWAP"* ) while true; do
                     SWAPPINESS=$($DIALOG --title "$MENU2_SWAP" --inputbox "$MENU2_SWAP_SWAPPINESS" 14 60 $SWAPPINESS 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SwapSysctlForm ; break
                     fi
                     
                     if [[ "$SWAPPINESS" -ge 0 ]] && [[ "$SWAPPINESS" -le 100 ]]
                        then break
                     fi
                  done
                  
                  sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
                  echo -e "vm.swappiness=$SWAPPINESS" | sudo tee -a /etc/sysctl.conf
                  ;;
 "$MENU3_SWAP"* ) while true; do
                     VFS_CACHE_PRESSURECAT=$($DIALOG --title "$MENU3_SWAP" --inputbox "$MENU3_SWAP_VFS_CACHE_PRESSURECAT" 14 60 $VFS_CACHE_PRESSURECAT 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SwapSysctlForm ; break
                     fi
                     
                     if [[ "$VFS_CACHE_PRESSURECAT" -ge 0 ]] && [[ "$VFS_CACHE_PRESSURECAT" -le 1000 ]]
                        then break
                     fi
                  done
                  
                  sudo sed -i '/vm.vfs_cache_pressure/d' /etc/sysctl.conf
                  echo -e "vm.vfs_cache_pressure=$VFS_CACHE_PRESSURECAT" | sudo tee -a /etc/sysctl.conf
                  ;;
 "$MENU4_SWAP"* ) if [ "$LAPTOP_MODE" = "OFF" ]  
                    then 
                         sudo sed -i '/vm.laptop_mode/d' /etc/sysctl.conf
                         echo -e "vm.laptop_mode=5" | sudo tee -a /etc/sysctl.conf
                    else 
                         sudo sed -i '/vm.laptop_mode/d' /etc/sysctl.conf
                         echo -e "vm.laptop_mode=0" | sudo tee -a /etc/sysctl.conf
                  fi
                  ;;                 
     
 "$MENU5_SWAP"* ) while true; do
                     DIRTY_WRITEBACK_CENTISECS=$($DIALOG --title "$MENU5_SWAP" --inputbox "$MENU5_SWAP_DIRTY_WRITEBACK_CENTISECS" 14 60 $DIRTY_WRITEBACK_CENTISECS 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SwapSysctlForm ; break
                     fi
                     
                     if [[ "$DIRTY_WRITEBACK_CENTISECS" -ge 0 ]] && [[ "$DIRTY_WRITEBACK_CENTISECS" -le 60000 ]]
                        then break
                     fi
                  done
                
                  sudo sed -i '/vm.dirty_writeback_centisecs/d' /etc/sysctl.conf
                  echo -e "vm.dirty_writeback_centisecs=$DIRTY_WRITEBACK_CENTISECS" | sudo tee -a /etc/sysctl.conf
                  ;;
 "$MENU6_SWAP"* ) while true; do
                     DIRTY_RATIO=$($DIALOG --title "$MENU6_SWAP" --inputbox "$MENU6_SWAP_DIRTY_RATIO" 14 60 $DIRTY_RATIO 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SwapSysctlForm ; break
                     fi
                     
                     if [[ "$DIRTY_RATIO" -ge 0 ]] && [[ "$DIRTY_RATIO" -le 100 ]]
                        then break
                     fi
                  done
                  
                  sudo sed -i '/vm.dirty_ratio/d' /etc/sysctl.conf
                  echo -e "vm.dirty_ratio=$DIRTY_RATIO" | sudo tee -a /etc/sysctl.conf
                  ;;                  
 "$MENU7_SWAP"* ) while true; do
                     DIRTY_BACKGROUND_RATIO=$($DIALOG --title "$MENU7_SWAP" --inputbox "$MENU7_SWAP_DIRTY_BACKGROUND_RATIO" 14 60 $DIRTY_BACKGROUND_RATIO 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SwapSysctlForm ; break
                     fi
                     
                     if [[ "$DIRTY_BACKGROUND_RATIO" -ge 0 ]] && [[ "$DIRTY_BACKGROUND_RATIO" -le 100 ]]
                        then break
                     fi
                  done
                  
                  sudo sed -i '/vm.dirty_background_ratio/d' /etc/sysctl.conf
                  echo -e "vm.dirty_background_ratio=$DIRTY_BACKGROUND_RATIO" | sudo tee -a /etc/sysctl.conf
                  ;; 
 "$MENU8_SWAP" )  sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
                  sudo sed -i '/vm.vfs_cache_pressure/d' /etc/sysctl.conf
                  sudo sed -i '/vm.laptop_mode/d' /etc/sysctl.conf
                  sudo sed -i '/vm.dirty_writeback_centisecs/d' /etc/sysctl.conf
                  sudo sed -i '/vm.dirty_ratio/d' /etc/sysctl.conf
                  sudo sed -i '/vm.dirty_background_ratio/d' /etc/sysctl.conf
                  RestartPC
                  ;;                                   
esac

sudo sync
sudo sysctl -p

SwapSysctlForm
}
#########################################################
MainForm () #Главная форма
{
CheckStateTmpfs
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 16 60\
    8\
       "$MENU1" ""\
       "$MENU2" ""\
       "$MENU3 (automount-$STATE_AUTOMOUNT_TMP, status-$STATE_STATUS_TMP)" ""\
       "$MENU4 (automount-$STATE_AUTOMOUNT_LOG, status-$STATE_STATUS_LOG)" ""\
       "$MENU5" ""\
       "$MENU6" ""\
       "$MENU7" ""\
       "$MENUh" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
   "$MENU2" ) SwapSysctlForm
              ;;
  "$MENU3"* ) if [ "$STATE_AUTOMOUNT_TMP" = "OFF" ]  
               then echo -e "#Mount /tmp to RAM ( /tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
               else sudo sed -i '/ \/tmp tmpfs/d' /etc/fstab
              fi
              RestartPC
              ;;
  "$MENU4"* ) if [ "$STATE_AUTOMOUNT_LOG" = "OFF" ]  
               then echo -e "#Mount /var/* to RAM 
tmpfs /var/tmp tmpfs defaults 0 0
tmpfs /var/lock tmpfs defaults 0 0
tmpfs /var/log tmpfs defaults,size=20M 0 0
tmpfs /var/spool/postfix tmpfs defaults 0 0" | sudo tee -a /etc/fstab
               else sudo sed -i '/\/var\//d' /etc/fstab
              fi
              RestartPC
              ;;
   "$MENU5" ) #setup sysctl
              echo -e "vm.swappiness=0
vm.vfs_cache_pressure=50
vm.laptop_mode=5
vm.dirty_writeback_centisecs=6000
vm.dirty_ratio=60
vm.dirty_background_ratio=5" | sudo tee -a /etc/sysctl.conf
              sudo sync
              sudo sysctl -p
              
              #setup logs and tmp to RAM
              echo -e "#Mount /tmp to RAM ( /tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
              echo -e "#Mount /var/* to RAM 
tmpfs /var/tmp tmpfs defaults 0 0
tmpfs /var/lock tmpfs defaults 0 0
tmpfs /var/log tmpfs defaults,size=20M 0 0
tmpfs /var/spool/postfix tmpfs defaults 0 0" | sudo tee -a /etc/fstab
              RestartPC
              ;;
   "$MENU6" ) sudo $EDITOR /etc/fstab
              ;;
   "$MENU7" ) sudo $EDITOR /etc/sysctl.conf
              ;;              
   "$MENUh" ) echo "$HELP"
              echo "$HELP_EXIT"
              read x
              ;;
esac

MainForm 
}
#########################################################

MainForm

exit 0
