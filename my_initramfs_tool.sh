#!/bin/bash
DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
   then DIALOG=dialog
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Cкрипт для формирования initramfs"
               MAIN_TEXT="Выберите действие:"

               MAKE_NEW_FOR_THIS_SYS="Сделать initramfs под данную систему"
               MAKE_NEW_FOR_ALL_SYS="Сделать универнсальный initramfs"
               UPDATE_INITRAMFS="Обновить initramfs для всех ядер"
               MENUh="Справка"

               HELP_TEXT="Скрипт $0 позволяет более гибко создавать initramfs
Пункты:
 * $MAKE_NEW_FOR_THIS_SYS - создает initramfs только из тех модулей, что используются данной системой. При этом размер initramfs существенно уменьшается, что повышает скорость рагрузки. 
 * $MAKE_NEW_FOR_ALL_SYS - создает initramfs подходящий для болинства систем
 * $UPDATE_INITRAMFS - пересоздает initramfs для всех ядер системы
 " 
               HELP_EXIT="Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               ;;
               *)
               MAIN_LABEL="Scripts for the formation initramfs"
               MAIN_TEXT="Select an action:"

               MAKE_NEW_FOR_THIS_SYS="Make initramfs under this system"
               MAKE_NEW_FOR_ALL_SYS="Make univernsalny initramfs"
               UPDATE_INITRAMFS="Update initramfs for all kernel"
               MENUh="Help"

               HELP_TEXT="The script is $0 allows more flexibility to create initramfs
Points:
 * $MAKE_NEW_FOR_THIS_SYS - creates initramfs only those modules that are used by the system. Thus initramfs size is significantly reduced, which increases the speed ragruzki.
 * $MAKE_NEW_FOR_ALL_SYS - creates initramfs suitable for bolinstva systems
 * $UPDATE_INITRAMFS - initramfs recreates all system cores
 " 
               
               HELP_EXIT="Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               ;;
esac             

if [[ $1 == '' ]]
then 
 if [ $(id -u) -ne 0 ] #Проверка на запуск с правами root
  then
  echo "Start $0 with root"
  sudo $0 
  exit 0
 fi
fi


# Make backup
if [ ! -f "/etc/initramfs-tools/initramfs.conf.bak" ]; then
   cp /etc/initramfs-tools/initramfs.conf /etc/initramfs-tools/initramfs.conf.bak
fi

if [ ! -f "/etc/initramfs-tools/modules.bak" ]; then
   cp /etc/initramfs-tools/modules /etc/initramfs-tools/modules.bak
fi


MainForm ()
{
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 16 60\
    5\
        1 "$MAKE_NEW_FOR_THIS_SYS"\
        2 "$MAKE_NEW_FOR_ALL_SYS"\
        3 "$UPDATE_INITRAMFS"\
        h "$MENUh" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then exit 0
fi
case $ANSWER in
    1) OLD_SIZE=`du /boot/initrd.img-$(uname -r)| awk '{print $1}'`
       sed -i "s/MODULES=most/MODULES=list/g" /etc/initramfs-tools/initramfs.conf
       lsmod | tail -n +2 | sort | awk '{print $1;}' > /etc/initramfs-tools/modules
       update-initramfs -v -d -k `uname -r` && update-initramfs -v -c -k `uname -r`
       NEW_SIZE=`du /boot/initrd.img-$(uname -r)| awk '{print $1}'`
       echo "_______________________________"
       echo "FILE:		initrd.img-$(uname -r)"
       echo "OLD SIZE:	$OLD_SIZE kB"
       echo "NEW SIZE:	$NEW_SIZE kB"
       let "DIFFERENCE=OLD_SIZE-NEW_SIZE"
       echo "DIFFERENCE:	$DIFFERENCE kB"
       echo "_______________________________"
       echo $HELP_EXIT 
       read x
       ;;
    2) OLD_SIZE=`du /boot/initrd.img-$(uname -r)| awk '{print $1}'`
       cp /etc/initramfs-tools/initramfs.conf.bak /etc/initramfs-tools/initramfs.conf
       cp /etc/initramfs-tools/modules.bak /etc/initramfs-tools/modules
       update-initramfs -v -d -k `uname -r` && update-initramfs -v -c -k `uname -r`
       NEW_SIZE=`du /boot/initrd.img-$(uname -r)| awk '{print $1}'`
       echo "_______________________________"
       echo "FILE:		initrd.img-$(uname -r)"
       echo "OLD SIZE:	$OLD_SIZE kB"
       echo "NEW SIZE:	$NEW_SIZE kB"
       let "DIFFERENCE=OLD_SIZE-NEW_SIZE"
       echo "DIFFERENCE:	$DIFFERENCE kB"
       echo "_______________________________"
       read x
       ;;
    3) update-initramfs -c -k all
       echo $HELP_EXIT 
       read x
       ;; 
    h) clear
       echo -e "$HELP_TEXT"
       echo $HELP_EXIT 
       read x
       MainForm
       ;;              
    *) echo oops! - $ANSWER
       exit 1
       ;;
esac

MainForm
}

MainForm
              
exit 0
