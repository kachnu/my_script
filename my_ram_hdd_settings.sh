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
  uk*|ru*|be*|*) #UA RU BE locales
               MAIN_LABEL="Настройка параметров работы с дисками и памятью"
               MAIN_TEXT="Выберите действие:"
               
               MENU_PARTITION_FORM="Настройки монтирования"
               MENU_SYSCTL_FORM="Настройки Sysctl"
               MENU_SWAP_FORM="Настройки Swap"
               MENU_OTHER_FORM="Дополнительные настройки"
               MENU_TMP_TO_RAM="Временные файлы /tmp в ОЗУ"
               MENU_LOG_TO_RAM="Логи /var/* в ОЗУ"
               MENU_AUTOSETTINGS_SSD="Автонастройка для SSD"
               MENU_BACKUP="Backup настроек"
               MENU_EDIT_FSTAB="Редактирование /etc/fstab"
               MENU_EDIT_SYSCTLCONF="Редактирование /etc/sysctl.conf"
               MENU_HELP="Справка"
               
               MAIN_PART="Выберите раздел:"
               MENU_DISCARD="TRIM через discard"
               MENU_FSTRIM="TRIM по расписанию fstrim"
               MENU_INFO_FSTRIM="n - выключить fstrim
d - включать fstrim каждый день
w - включать fstrim каждую неделю
m - включать fstrim каждый месяц"

               MENU_BARRIER="Снять барьер barrier=0"
               MENU_COMMIT="Задержка сброса commit=600"
               MENU_NOATIME="Не отслеживать доступ noatime"              
               
               MENU_SWAPPINESS="Настроить порог swappiness"
               MENU_INFO_SWAPPINESS="Введите значение в % (от 0 до 100) свободной ОЗУ, при котором начнется задействование подкачки swap.
Для ОЗУ 2 GB = 30, 4 GB = 10, 6 GB or more = 0."
               MENU_VFS_CACHE_PRESSURECAT="Настроить vfs_cache_pressurecat"
               MENU_INFO_VFS_CACHE_PRESSURECAT="Введите значение (от 0 до 1000), чтобы определить отношение ядра к освободившимся страницам памяти. 
Чем ниже значение, тем дольше информация хранится в ОЗУ и меньше кэшируется, значение выше 100 способствует агрессивному кэшированию.
Для SSD рекомендуют 50, для HDD - 1000."
               MENU_LAPTOPMODE="Режим laptop и активация отложенной записи"
               MENU_DIRTY_WRITEBACK_CENTISECS="Отложенная запись dirty_writeback_centisecs"
               MENU_INFO_DIRTY_WRITEBACK_CENTISECS="Введите значение (от 0 до 60000), чтобы установить время задержки записи (запуска pdflush) на жесткий диск (100 ед. = 1 секунда).
Для SSD - 6000 (1 минута)"
               MENU_DIRTY_RATIO="Настроить dirty_ratio"
               MENU_INFO_DIRTY_RATIO="Введите значение в % (от 0 до 100) - доля свободной системной памяти в процентах, по достижении которой процесс, ведущий запись на диск, инициирует запись \"грязных\" данных.
Для SSD - 60"
               MENU_DIRTY_BACKGROUND_RATIO="Настроить dirty_background_ratio"
               MENU_INFO_DIRTY_BACKGROUND_RATIO="Введите значение в % (от 0 до 100) - доля свободной памяти в процентах от общей памяти всей системы, по достижении которой демон pdflush начинает сбрасывать данные их дискового кэша на сам диск.
Для SSD - 5"               
               
               MENU_SWAP="Подкачка swap"
               MENU_FILE_SWAP="Файл подкачки"
               MENU_INFO_FILE_SWAP="Введите объем файла подкачки в МБ от 0 до"
               MENU_PARTITION_SWAP="Раздел подкачки"
               MENU_IDLE3="Таймер парковки головок HDD WD"
               MENU_PRELOAD="Сортировка в Preload"
               MENU_INFO_PRELOAD="0 - Без сортировки ввода/вывода.
Подходит для флэш-памяти и SSD.
1 - Сортировка на основе только пути к файлу.
Подходит для сетевых файловых систем.
2 - Сортировка в зависимости от количества индексных дескрипторов.
Снижает кол-во операций ввода/вывода, чем вариант - 3.
3 - Сортировка ввода/вывода на основе дискового блока. Самый сложный алгоритм.
Подходит для большинства файловых систем Linux."
               
               HELP_EXIT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               RESTART_TEXT="Для применения настроек необходимо перезагрузить ПК! 

Перезагрузить ПК сейчас?"
               POWER_OFF_TEXT="Для применения настроек необходимо выключить ПК! 

Выключить ПК сейчас?"
               HIB_FILE_SWAP_TEXT="Вы хотите использовать swapfile при гибернации?"
               AUTOSETTINGS_SSD_TEXT="Будут произведены следующие действия:
- изменены параметры монтирования /
- изменены параметры  sysctl
- изменены параметры  Preload
- включено ежедневное fstrim
- включено монтирование /tmp и логов в ОЗУ

Произвести указанные действия?"
               HELP="
____________________________________
   Справка

$0 - скрипт предназначен для настроки таких параметров системы как: журналирование, подкачка, способы хранения временных файлов, монтирование и т.д.
_______________
* $MENU_PARTITION_FORM
Позволяет настроить параметры монтирования разделов из /etc/fstab:
- $MENU_DISCARD - включить TRIM с помощью параметра discard, нужно быть умеренным что данный режим поддерживается апаратно и файловой системой
- $MENU_FSTRIM - включить TRIM по расписанию с помощью fstrim
- $MENU_BARRIER - позволяет повысить производительность при этом есть риск нарушения целостности ФС, будьте внимательный - компьютер должен иметь гараниторанное электропитание (подходит для ноутбуков и ПК с UPS)
- установить минутную задержку сброса дискового кэша на сам диск - 


_______________
* $MENU_SYSCTL_FORM
Позволяет настроить способ подкачки.
__
* $MENU_TMP_TO_RAM
Все временные файлы будут храниться в ОЗУ что повышает быстродействие и уменьшает износ HDD и SSD
Данная технология уже давно применяется в Solaris, Fedora и ArchLinux
Не рекомендуется использовать на ПК с малым объемом ОЗУ 
__
* $MENU_LOG_TO_RAM
__
* $MENU_AUTOSETTINGS_SSD
__
* $MENU_EDIT_FSTAB

___________________________________"
             
               ;;
esac

 #MENU_INFO_PRELOAD="0 - No I/O sorting.
#Useful on Flash memory for example.
#1 - Sort based on file path only.
#Useful for network filesystems.
#2 -	Sort based on inode number.
#Does less house-keeping I/O than the next option.
#3 - Sort I/O based on disk block.  Most sophisticated.
#And useful for most Linux filesystems.
#"





SWAPFILE="/var/swapfile"

#########################################################
RestartPC ()
{
$DIALOG --title "$ATTENTION" --yesno "$RESTART_TEXT" 10 60
if [ $? == 0 ]
   then sudo reboot
fi
}
#########################################################

PowerOffPC ()
{
 $DIALOG --title "$ATTENTION" --yesno "$POWER_OFF_TEXT" 10 60
if [ $? == 0 ]
   then sudo shutdown now
fi   
}
#########################################################
CheckStateMain ()
{
if [ -f /etc/fstab.backup ]
   then TIME_BACKUP=`date +%F_%T -r /etc/fstab.backup`
        TIME_BACKUP="(recovery-"$TIME_BACKUP")"
   else TIME_BACKUP="(make backup)"
fi

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
VALUE_SWAP=$((`free | grep Swap | awk '{print $2}'`/1024))
if [ "$VALUE_SWAP" != '' ]
   then VALUE_SWAP=", size-"$VALUE_SWAP"MB"
fi

if [ -f $SWAPFILE ]
   then STATE_FILE_SWAP="ON"
        VALUE_FILE_SWAP=$((`du $SWAPFILE | awk '{print $1}'`/1024))
        VALUE_FILE_SWAP_TEXT=", size-"$VALUE_FILE_SWAP"MB"
   else STATE_FILE_SWAP="OFF"
        VALUE_FILE_SWAP_TEXT=""
fi

FREE_SPASE_ROOT=$((`df / | sed -e '1d' | awk '{print $4}'`/1024-500))


STATE_PARTITION_SWAP=`cat /proc/swaps | grep partition`
if [ "$STATE_PARTITION_SWAP" != '' ]
   then STATE_PARTITION_SWAP="ON"
        SWAP_PARTITION=`cat /proc/swaps | grep partition | awk '{print $1}'`
        SWAP_PARTITION_XXX=`echo "$SWAP_PARTITION" | awk  -F"/" '{print $3}'`
        UUID_SWAP_PARTITION=`ls -l /dev/disk/by-uuid | grep $SWAP_PARTITION_XXX | awk '{print $9}'`
        VALUE_SWAP_PARTITION=$((`cat /proc/swaps | grep partition | awk '{print $3}'`/1024)) 
        VALUE_PARTITION_SWAP_TEXT=", size-"$VALUE_SWAP_PARTITION"MB"
   else STATE_PARTITION_SWAP="OFF"
fi


}
#########################################################
CheckStateSysctl ()
{
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
SysctlForm ()
{
CheckStateSysctl
ANSWER=$($DIALOG  --cancel-button "Back" --title "$MENU_SYSCTL_FORM" --menu \
    "$MAIN_TEXT" 16 64\
    8\
       "$MENU_SWAPPINESS ($SWAPPINESS% free RAM)" ""\
       "$MENU_VFS_CACHE_PRESSURECAT ($VFS_CACHE_PRESSURECAT filesystem caches)" ""\
       "$MENU_LAPTOPMODE (status-$LAPTOP_MODE)" ""\
       "$MENU_DIRTY_WRITEBACK_CENTISECS ($DIRTY_WRITEBACK_CENTISECS centisecs)" ""\
       "$MENU_DIRTY_RATIO ($DIRTY_RATIO% RAM)" ""\
       "$MENU_DIRTY_BACKGROUND_RATIO ($DIRTY_BACKGROUND_RATIO% RAM)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi
case $ANSWER in
   "$MENU_SWAPPINESS"* ) 
                  while true; do
                     SWAPPINESS=$($DIALOG --title "$MENU_SWAPPINESS" --inputbox "$MENU_INFO_SWAPPINESS" 14 60 $SWAPPINESS 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi
                     
                     if [[ "$SWAPPINESS" -ge 0 ]] && [[ "$SWAPPINESS" -le 100 ]]
                        then break
                     fi
                  done
                  
                  sudo sed -i '/^vm.swappiness/d' /etc/sysctl.conf
                  echo -e "vm.swappiness=$SWAPPINESS" | sudo tee -a /etc/sysctl.conf
                  ;;
   "$MENU_VFS_CACHE_PRESSURECAT"* ) 
                  while true; do
                     VFS_CACHE_PRESSURECAT=$($DIALOG --title "$MENU_VFS_CACHE_PRESSURECAT" --inputbox "$MENU_INFO_VFS_CACHE_PRESSURECAT" 14 60 $VFS_CACHE_PRESSURECAT 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi
                     
                     if [[ "$VFS_CACHE_PRESSURECAT" -ge 0 ]] && [[ "$VFS_CACHE_PRESSURECAT" -le 1000 ]]
                        then break
                     fi
                  done
                  
                  sudo sed -i '/^vm.vfs_cache_pressure/d' /etc/sysctl.conf
                  echo -e "vm.vfs_cache_pressure=$VFS_CACHE_PRESSURECAT" | sudo tee -a /etc/sysctl.conf
                  ;;
   "$MENU_LAPTOPMODE"* ) 
                  if [ "$LAPTOP_MODE" = "OFF" ]  
                    then 
                         sudo sed -i '/^vm.laptop_mode/d' /etc/sysctl.conf
                         echo -e "vm.laptop_mode=5" | sudo tee -a /etc/sysctl.conf
                    else 
                         sudo sed -i '/^vm.laptop_mode/d' /etc/sysctl.conf
                         echo -e "vm.laptop_mode=0" | sudo tee -a /etc/sysctl.conf
                  fi
                  ;;
   "$MENU_DIRTY_WRITEBACK_CENTISECS"* ) 
                  while true; do
                     DIRTY_WRITEBACK_CENTISECS=$($DIALOG --title "$MENU_DIRTY_WRITEBACK_CENTISECS" --inputbox "$MENU_INFO_DIRTY_WRITEBACK_CENTISECS" 14 60 $DIRTY_WRITEBACK_CENTISECS 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi
                     
                     if [[ "$DIRTY_WRITEBACK_CENTISECS" -ge 0 ]] && [[ "$DIRTY_WRITEBACK_CENTISECS" -le 60000 ]]
                        then break
                     fi
                  done
                
                  sudo sed -i '/^vm.dirty_writeback_centisecs/d' /etc/sysctl.conf
                  echo -e "vm.dirty_writeback_centisecs=$DIRTY_WRITEBACK_CENTISECS" | sudo tee -a /etc/sysctl.conf
                  ;;
   "$MENU_DIRTY_RATIO"* ) 
                  while true; do
                     DIRTY_RATIO=$($DIALOG --title "$MENU_DIRTY_RATIO" --inputbox "$MENU_INFO_DIRTY_RATIO" 14 60 $DIRTY_RATIO 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi
                     
                     if [[ "$DIRTY_RATIO" -ge 0 ]] && [[ "$DIRTY_RATIO" -le 100 ]]
                        then break
                     fi
                  done
                  
                  sudo sed -i '/^vm.dirty_ratio/d' /etc/sysctl.conf
                  echo -e "vm.dirty_ratio=$DIRTY_RATIO" | sudo tee -a /etc/sysctl.conf
                  ;;                  
   "$MENU_DIRTY_BACKGROUND_RATIO"* ) 
                  while true; do
                     DIRTY_BACKGROUND_RATIO=$($DIALOG --title "$MENU_DIRTY_BACKGROUND_RATIO" --inputbox "$MENU_INFO_DIRTY_BACKGROUND_RATIO" 14 60 $DIRTY_BACKGROUND_RATIO 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi
                     
                     if [[ "$DIRTY_BACKGROUND_RATIO" -ge 0 ]] && [[ "$DIRTY_BACKGROUND_RATIO" -le 100 ]]
                        then break
                     fi
                  done
                  
                  sudo sed -i '/^vm.dirty_background_ratio/d' /etc/sysctl.conf
                  echo -e "vm.dirty_background_ratio=$DIRTY_BACKGROUND_RATIO" | sudo tee -a /etc/sysctl.conf
                  ;; 
esac

sudo sync
sudo sysctl -p

SysctlForm
}
#########################################################
SwapForm ()
{
CheckStateSwap
ANSWER=$($DIALOG  --cancel-button "Back" --title "$MENU_SWAP_FORM" --menu \
    "$MAIN_TEXT" 16 64\
    8\
       "$MENU_SWAP (automount-$STATE_AUTOMOUNT_SWAP, status-$STATE_STATUS_SWAP$VALUE_SWAP)" ""\
       "$MENU_FILE_SWAP (present-$STATE_FILE_SWAP$VALUE_FILE_SWAP_TEXT)" ""\
       "$MENU_PARTITION_SWAP (status-$STATE_PARTITION_SWAP$VALUE_PARTITION_SWAP_TEXT)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi
case $ANSWER in
   "$MENU_SWAP"* ) if [ "$STATE_AUTOMOUNT_SWAP" = "OFF" ]  
                      then sudo sed -i '/swap/s/\#//g' /etc/fstab
                      else sudo sed -i '/swap/s/^/\#/g' /etc/fstab
                   fi
                  
                   if [ "$STATE_STATUS_SWAP" = "OFF" ]  
                      then sudo swapon -a
                      else sudo swapoff -a
                   fi
                  ;;
   "$MENU_FILE_SWAP"* ) 
                  if [ "$STATE_FILE_SWAP" = "OFF" ]  
                      then 
                           while true; do
                                 VALUE_FILE_SWAP=$($DIALOG --title "$MENU_FILE_SWAP" --inputbox "$MENU_INFO_FILE_SWAP $FREE_SPASE_ROOT" 14 60 $VALUE_FILE_SWAP 3>&1 1>&2 2>&3)
                                 if [ $? != 0 ]
                                    then SwapForm ; break
                                 fi
                     
                                 if [[ "$VALUE_FILE_SWAP" -ge 0 ]] && [[ "$VALUE_FILE_SWAP" -le "$FREE_SPASE_ROOT" ]]
                                     then break
                                 fi
                           done
                           sudo touch $SWAPFILE
                           sudo chmod 0600 $SWAPFILE
                           echo "Please wait for the swap file is created..."
                           sudo dd if=/dev/zero of=$SWAPFILE bs=1024k count=$VALUE_FILE_SWAP
                           sudo mkswap $SWAPFILE
                           echo -e "#Mount $SWAPFILE \n$SWAPFILE   none    swap    sw    0    0" | sudo tee -a /etc/fstab
                           sudo swapon $SWAPFILE
                           
                           $DIALOG --title "$ATTENTION" --yesno "$HIB_FILE_SWAP_TEXT" 10 60
                           if [ $? == 0 ]
                               then 
                                    UUID_FILE_SWAP=`sudo swaplabel $SWAPFILE | awk '{print $2}'`
                                    RESUME_OFFSET=`sudo filefrag -v $SWAPFILE | grep -P " 0:" | awk '{print $4}' | sed "s/\.//g"`
                                    echo djahskjdhkjashd $RESUME_OFFSET
                                    echo -e "resume=UUID=$UUID_FILE_SWAP resume_offset=$RESUME_OFFSET" | sudo tee /etc/initramfs-tools/conf.d/resume 
                                    # echo "RESUME=$(grep swap /etc/fstab| awk '{ print $1 }')" > /etc/initramfs-tools/conf.d/resume 
                                    sudo update-initramfs -u
                           fi
                      else 
                           sudo swapoff $SWAPFILE
                           sudo rm -f $SWAPFILE
                           sudo sed -i '/swapfile/d' /etc/fstab
                           sudo swapon -a
                   fi
                  ;;
   "$MENU_PARTITION_SWAP"* ) 
                  if [ "$STATE_PARTITION_SWAP" = "OFF" ]  
                      then echo ""
                      else echo ""
                  fi    
                  ;;               
esac

SwapForm
}
########################################################
CheckStateOther ()
{

STATE_IDLE3_TOOLS=`dpkg -l | grep idle3-tools`
if [ "$STATE_IDLE3_TOOLS"='' ]
   then STATE_IDLE3_TOOLS="idle3-tools - is not installed"
   else sudo idle3ctl -g103 /dev/sda
fi



SETTING_PRELOAD_SORTSTRATEGY=`cat /etc/preload.conf | grep ^sortstrategy | awk '{print $NF }'|sed "s/=//g"`


}
########################################################
OtherForm ()
{
CheckStateOther
ANSWER=$($DIALOG  --cancel-button "Back" --title "$MENU_OTHER_FORM" --menu \
    "$MAIN_TEXT" 16 64\
    8\
       "$MENU_IDLE3" ""\
       "$MENU_PRELOAD (setting-$SETTING_PRELOAD_SORTSTRATEGY)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi
case $ANSWER in
   "$MENU_IDLE3"* ) 
                  PowerOffPC
                  ;;
   "$MENU_PRELOAD"* ) 
                  while true; do
                     SETTING_PRELOAD_SORTSTRATEGY=$($DIALOG --title "$MENU_PRELOAD" --inputbox "$MENU_INFO_PRELOAD" 18 60 $SETTING_PRELOAD_SORTSTRATEGY 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then OtherForm ; break
                     fi
                     
                     if [[ "$SETTING_PRELOAD_SORTSTRATEGY" -ge 0 ]] && [[ "$SETTING_PRELOAD_SORTSTRATEGY" -le 3 ]]
                        then break
                     fi
                  done
                  sudo sed -i '/^sortstrategy/d' /etc/preload.conf
                  echo -e "sortstrategy = $SETTING_PRELOAD_SORTSTRATEGY" | sudo tee -a /etc/preload.conf
                  sudo /etc/init.d/preload restart
                  ;;
esac

OtherForm
}
#########################################################
CheckStatePartition ()
{
MOUNT_POINT=$(cat /etc/fstab | grep "$PARTITION" | awk '{print $2" "}')

if [[ `echo $PARTITION | grep "^UUID"` ]]
   then
        UUID=`echo "$PARTITION" | sed s/UUID=//g`
        DISK="/dev/"`ls -l /dev/disk/by-uuid | grep $UUID | awk '{print $NF }' | sed s/[./0-9]//g`
   else
        DISK=`echo "$PARTITION" | sed s/[0-9]//g`
fi

MOUNT_DISCARD=$(cat /etc/fstab | grep $PARTITION | grep discard)
if [ "$MOUNT_DISCARD" != "" ]
   then MOUNT_DISCARD="ON"
   else MOUNT_DISCARD="OFF"
fi
STATE_DISCARD=$(mount | grep $MOUNT_POINT | grep discard)
if [ "$STATE_DISCARD" != '' ]
   then STATE_DISCARD="ON"
   else STATE_DISCARD="OFF"
fi

CRON_TRIM="n"
STATE_CRON_TRIM="OFF"

if [[ `cat /etc/cron.daily/trim | grep " $MOUNT_POINT"` ]]
   then CRON_TRIM="d"
        STATE_CRON_TRIM="ON"
fi

if [[ `cat /etc/cron.weekly/trim | grep " $MOUNT_POINT"` ]]
   then CRON_TRIM="w"
        STATE_CRON_TRIM="ON"
fi          

if [[ `cat /etc/cron.monthly/trim | grep " $MOUNT_POINT"` ]]
   then CRON_TRIM="m"
        STATE_CRON_TRIM="ON"
fi

MOUNT_BARRIER=$(cat /etc/fstab | grep $PARTITION | grep barrier)
if [ "$MOUNT_BARRIER" != "" ]
   then MOUNT_BARRIER="ON"
   else MOUNT_BARRIER="OFF"
fi
STATE_BARRIER=$(mount | grep $MOUNT_POINT | grep barrier)
if [ "$STATE_BARRIER" != '' ]
   then STATE_BARRIER="ON"
   else STATE_BARRIER="OFF"
fi

MOUNT_COMMIT=$(cat /etc/fstab | grep $PARTITION | grep commit)
if [ "$MOUNT_COMMIT" != "" ]
   then MOUNT_COMMIT="ON"
   else MOUNT_COMMIT="OFF"
fi
STATE_COMMIT=$(mount | grep $MOUNT_POINT | grep commit)
if [ "$STATE_COMMIT" != '' ]
   then STATE_COMMIT="ON"
   else STATE_COMMIT="OFF"
fi

MOUNT_NOATIME=$(cat /etc/fstab | grep $PARTITION | grep noatime)
if [ "$MOUNT_NOATIME" != "" ]
   then MOUNT_NOATIME="ON"
   else MOUNT_NOATIME="OFF"
fi
STATE_NOATIME=$(mount | grep $MOUNT_POINT | grep noatime)
if [ "$STATE_NOATIME" != '' ]
   then STATE_NOATIME="ON"
   else STATE_NOATIME="OFF"
fi
}
#########################################################
AddParmToFstab ()
{
PARM=$1","
DATA=`cat /etc/fstab | grep $PARTITION`
NEW_DATA=`echo $DATA | awk -v v1=$PARM '{print $1" "$2" "$3" "v1$4" "$5" "$6}' | sed "s/ /\t/g"`
sudo sed -i "s|${DATA}|${NEW_DATA}|g" /etc/fstab
}
#########################################################
RmParmFromFstab ()
{
PARM=$1","
DATA=`cat /etc/fstab | grep $PARTITION`
NEW_DATA=`echo $DATA | sed "s/${PARM}//g" | sed "s/ /\t/g"`
sudo sed -i "s|${DATA}|${NEW_DATA}|g" /etc/fstab
}
#########################################################
PartitionForm ()
{
CheckStatePartition
ANSWER=$($DIALOG  --cancel-button "Back" --title "$PARTITION" --menu \
    "$MAIN_TEXT" 16 60\
    8\
       "$MENU_DISCARD (mount-$MOUNT_DISCARD, state-$STATE_DISCARD) " ""\
       "$MENU_FSTRIM (state-$STATE_CRON_TRIM, cron-$CRON_TRIM)" ""\
       "$MENU_BARRIER (mount-$MOUNT_BARRIER, state-$STATE_BARRIER)" ""\
       "$MENU_COMMIT (mount-$MOUNT_COMMIT, state-$STATE_COMMIT)" ""\
       "$MENU_NOATIME (mount-$MOUNT_NOATIME, state-$STATE_NOATIME)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi

case $ANSWER in
   "$MENU_DISCARD"* )
                    SUPPORTED_TRIM=`sudo hdparm -I $DISK | grep "TRIM supported"`
                    if [[ $SUPPORTED_TRIM == '' ]]
                       then echo "TRIM is NOT supported by hard disk - $DISK !"
                       else echo "TRIM is supported by hard disk - $DISK"
                    fi
                                        
                    OPTION="discard"
                    if [ "$MOUNT_DISCARD" = "OFF" ] && [[ $SUPPORTED_TRIM != '' ]]
                        then AddParmToFstab $OPTION
                        else RmParmFromFstab $OPTION
                    fi
                    sudo mount -o remount $MOUNT_POINT
                    ;;
   "$MENU_FSTRIM"* )                     
                    while true; do
                      CRON_TRIM=$($DIALOG --title "$MENU_FSTRIM" --inputbox "$MENU_INFO_FSTRIM" 16 60 $CRON_TRIM 3>&1 1>&2 2>&3)
                      if [ $? != 0 ]
                         then PartitionForm ; break
                      fi
                      MOUNT_POINT_RESP=`echo $MOUNT_POINT | sed 's|/|\\\/|g'`
                      case $CRON_TRIM in
                          "n" ) sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.daily/trim
                                sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.weekly/trim
                                sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.monthly/trim
                                break
                                ;;
                          "d" ) if [ ! -f /etc/cron.daily/trim ]
                                   then echo -e "#\x21/bin/sh\\nfstrim -v $MOUNT_POINT" | sudo tee /etc/cron.daily/trim
                                        sudo chmod +x /etc/cron.daily/trim
                                   else sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.daily/trim
                                        echo -e "fstrim -v $MOUNT_POINT" | sudo tee -a /etc/cron.daily/trim
                                fi
                                break
                                ;;
                          "w" ) if [ ! -f /etc/cron.weekly/trim ]
                                   then echo -e "#\x21/bin/sh\\nfstrim -v $MOUNT_POINT" | sudo tee /etc/cron.weekly/trim
                                        sudo chmod +x /etc/cron.weekly/trim
                                   else sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.weekly/trim
                                        echo -e "fstrim -v $MOUNT_POINT" | sudo tee -a /etc/cron.weekly/trim
                                fi
                                break
                                ;;
                          "m" ) if [ ! -f /etc/cron.monthly/trim ]
                                   then echo -e "#\x21/bin/sh\\nfstrim -v $MOUNT_POINT" | sudo tee /etc/cron.monthly/trim
                                        sudo chmod +x /etc/cron.monthly/trim
                                   else sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.monthly/trim
                                        echo -e "fstrim -v $MOUNT_POINT" | sudo tee -a /etc/cron.monthly/trim
                                fi
                                break
                                ;;
                      esac
                    done
                    ;;
   "$MENU_BARRIER"* ) 
                    OPTION="barrier=0"
                    if [ "$MOUNT_BARRIER" = "OFF" ] 
                        then AddParmToFstab $OPTION
                        else RmParmFromFstab $OPTION
                    fi
                    sudo mount -o remount $MOUNT_POINT
                    ;;
   "$MENU_COMMIT"* ) 
                    OPTION="commit=600"
                    if [ "$MOUNT_COMMIT" = "OFF" ] 
                        then AddParmToFstab $OPTION
                        else RmParmFromFstab $OPTION
                    fi
                    sudo mount -o remount $MOUNT_POINT
                    ;;
   "$MENU_NOATIME"* ) 
                    OPTION="noatime"
                    if [ "$MOUNT_NOATIME" = "OFF" ] 
                        then AddParmToFstab $OPTION
                        else RmParmFromFstab $OPTION
                    fi
                    sudo mount -o remount $MOUNT_POINT
                    ;;
esac

PartitionForm
}
#########################################################
MountForm ()
{
MOUNT_PARTITIONS=`cat /etc/fstab | grep ^UUID | awk '{print $1" "$2 }'`
MOUNT_PARTITIONS=$MOUNT_PARTITIONS" "`cat /etc/fstab | grep ^/dev | awk '{print $1" "$2 }'`

PARTITION=$($DIALOG  --cancel-button "Back" --title "$MENU_PARTITION_FORM" --menu \
    "$MAIN_PART" 16 60 8 $MOUNT_PARTITIONS  3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi

PartitionForm
}
#########################################################
MainForm ()
{
CheckStateMain
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 20 60\
    12\
       "$MENU_PARTITION_FORM" ""\
       "$MENU_SYSCTL_FORM" ""\
       "$MENU_SWAP_FORM" ""\
       "$MENU_OTHER_FORM" ""\
       "$MENU_TMP_TO_RAM (automount-$STATE_AUTOMOUNT_TMP, status-$STATE_STATUS_TMP)" ""\
       "$MENU_LOG_TO_RAM (automount-$STATE_AUTOMOUNT_LOG, status-$STATE_STATUS_LOG)" ""\
       "$MENU_AUTOSETTINGS_SSD" ""\
       "$MENU_BACKUP $TIME_BACKUP" ""\
       "$MENU_EDIT_FSTAB" ""\
       "$MENU_EDIT_SYSCTLCONF" ""\
       "$MENU_HELP" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then echo Exit ; exit 0
fi
case $ANSWER in
   "$MENU_PARTITION_FORM" ) 
              MountForm
              ;;
   "$MENU_SYSCTL_FORM" ) 
              SysctlForm
              ;;
   "$MENU_SWAP_FORM" ) 
              SwapForm
              ;;
   "$MENU_OTHER_FORM" ) 
              OtherForm
              ;;
   "$MENU_TMP_TO_RAM"* ) 
              if [ "$STATE_AUTOMOUNT_TMP" = "OFF" ]  
                 then echo -e "#Mount /tmp to RAM ( /tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
                 else sudo sed -i '/ \/tmp tmpfs/d' /etc/fstab
              fi
              RestartPC
              ;;
   "$MENU_LOG_TO_RAM"* ) 
              if [ "$STATE_AUTOMOUNT_LOG" = "OFF" ]  
                 then echo -e "#Mount /var/* to RAM 
tmpfs /var/tmp tmpfs defaults 0 0
tmpfs /var/lock tmpfs defaults 0 0
tmpfs /var/log tmpfs defaults,size=20M 0 0
tmpfs /var/spool/postfix tmpfs defaults 0 0" | sudo tee -a /etc/fstab
                 else sudo sed -i '/\/var\//d' /etc/fstab
              fi
              RestartPC
              ;;
   "$MENU_AUTOSETTINGS_SSD" ) 
              $DIALOG --title "$ATTENTION" --yesno "$AUTOSETTINGS_SSD_TEXT" 16 60
              if [ $? == 0 ]
                 then              
                      # setup mount /
                      PARTITION=`cat /etc/fstab | grep -P "\t/\t" | awk '{print $1}'`
                      if [ "$PARTITION"='' ]
                         then ARTITION=`cat /etc/fstab | grep -P " / " | awk '{print $1}'`
                      fi
                      OPTION="barrier=0,commit=600,noatime"
                      AddParmToFstab $OPTION
                      sudo mount -o remount /
                      
                      # setup sysctl
                      sudo sed -i '/^vm./d' /etc/sysctl.conf 
                      echo -e "vm.swappiness=0
vm.vfs_cache_pressure=50
vm.laptop_mode=5
vm.dirty_writeback_centisecs=6000
vm.dirty_ratio=60
vm.dirty_background_ratio=5" | sudo tee -a /etc/sysctl.conf
                      sudo sync
                      sudo sysctl -p
              
                      # logs and tmp to RAM
                      sudo sed -i '/ \/tmp tmpfs/d' /etc/fstab
                      sudo sed -i '/\/var\//d' /etc/fstab
                      echo -e "#Mount /tmp to RAM ( /tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
                      echo -e "#Mount /var/* to RAM 
tmpfs /var/tmp tmpfs defaults 0 0
tmpfs /var/lock tmpfs defaults 0 0
tmpfs /var/log tmpfs defaults,size=20M 0 0
tmpfs /var/spool/postfix tmpfs defaults 0 0" | sudo tee -a /etc/fstab
              
                      # setup preload sortstrategy
                      sudo sed -i '/^sortstrategy/d' /etc/preload.conf
                      echo -e "sortstrategy = 0" | sudo tee -a /etc/preload.conf
                      sudo /etc/init.d/preload restart
              
                      #setup auto fstrim
                      echo -e "#\x21/bin/sh\\nfstrim -v / " | sudo tee /etc/cron.daily/trim
                      sudo chmod +x /etc/cron.daily/trim

                      RestartPC
              fi
              ;;
   "$MENU_BACKUP"* )  
              if [ "$TIME_BACKUP" == "(make backup)" ]
                 then 
                      sudo cp /etc/fstab  /etc/fstab.backup
                      sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
                 else 
                      sudo mv /etc/fstab.backup /etc/fstab
                      sudo mv /etc/sysctl.conf.backup /etc/sysctl.conf
                      
                      sudo rm /etc/cron.daily/trim
                      sudo rm /etc/cron.weekly/trim
                      sudo rm /etc/cron.monthly/trim
                      
                      RestartPC
              fi
              ;;              
   "$MENU_EDIT_FSTAB" ) 
              sudo $EDITOR /etc/fstab
              ;;
   "$MENU_EDIT_SYSCTLCONF" ) 
              sudo $EDITOR /etc/sysctl.conf
              ;;              
   "$MENU_HELP" ) 
              echo "$HELP"
              echo "$HELP_EXIT"
              read x
              ;;
esac

MainForm 
}
#########################################################

MainForm

exit 0
