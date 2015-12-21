#!/bin/bash
#Скрипт по созданию Live-USB с сохранением
#author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=zenity
if [ ! -x "`which "$DIALOG"`" ] #Проверка наличия zenity
 then eсho "Not Install $DIALOG!"; exit 1
fi

if [ $(id -u) -ne 0 ] #Проверка на запуск с правами root
 then
  echo "Restart $0 with root"
  gksudo $0 
  exit 1
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Создание LiveUSB c сохранием"
               MAIN_TEXT="Выберите действие:"
               MENU1="Форматирование USB с помощью Gparted"
               MENU2="Создание файла persistence.conf"
               MENU3="Запись iso с помощью Unebootin"
               MENU4="Правка меню загрузки live-usb (syslinux.cfg)"
               MENU5="Выполнение всех действий по очереди (п/п 1-4)"
               MENU6="Справка"
               ATTENTION="ВНИМАНИЕ!"
               CHECK_PO="- не найдено!
Установите пакеты для работы -"
               FORMAT_USB_TEXT="Этап форматирования USB-накопителя (флешки)
Убедитесь в том, что USB-накопитель вставлен.
Необходимо на флешке создать 2 раздела:
раздел №1 - с файловой системой fat32, будет использоваться для iso образа дистрибутива
раздел №2 - с файловой системой ext2 (ext3, ext4)  и меткой persistence, будет использоваться для сохранения изменений во время live-режима
Еще раз раздел с меткой - persistence это очень важно!
Слово persistence - будет скопировано в буфер обмена, просто вставьте во время формирования метки для раздела №2

Если все понятно нажмите ОК (Да), чтобы запустить Gparted и приступить к форматированию флешки"
               ERROR_MAKE_FILE="Не могу найти раздел с меткой persistence. 
Попробуйте создать раздел с помощью программы Gparted"
               OK_MAKE_FILE="Файл persistence.conf создан"
               ERROR_EDIT_MENU="Файл syslinux.cfg не найден, либо найдено несколько файлов syslinux.cfg
Смонтируйте раздел usb-накопителя и повторите попытку. 
Укажите путь к syslinux.cfg самостоятельно

Нажмите ОК (Да), чтобы самостоятельно указать syslinux.cfg"
               OK_EDIT_MENU="Этап редактирования меню USB-накопителя (флешки) 
Для включения режима сохранения необходимо запускать ядро linux с параметром persistence,
данный параметр можно передать ядру 2 способами:
1) В момент загрузки с usb-накопителя, отредактировать пункт меню, нажав Tab и
добавив в конец строки слово persistence (Enter - для продолжения загрузки)
2) Отредактировать файл-меню syslinux.cfg добавив слово persistence в конец строки
append initrd=/live/initrd.img .... 
например,
append initrd=/live/initrd.img boot=live config quiet splash locales=ru_UA.UTF-8 persistence

Слово persistence - будет скопировано в буфер обмена
Нажмите ОК (Да), чтобы приступить к редактированию файла"
               
               HELP="Скрипт $0 - формирует Live-usb Linux с возможностью сохранения изменений.

В скрипте используются утилиты: 
 Gparted - форматирование и создание разделов на накопителях; 
 Unetbootin - перенос iso на флешку.

Можно создавать Live-usb последовательно переходя от п/п 1 до 4, можно запустить последовательное выполнение данных подпунктов выбрав пункт 5"
               ;;
            *) #All locales
               MAIN_LABEL="Create LiveUSB with Save"
               MAIN_TEXT="Select an action:"
               MENU1="Formatting USB using Gparted"
               MENU2="Creating persistence.conf"
               MENU3="Burn iso using Unebootin"
               MENU4="Edit the boot menu live-usb (syslinux.cfg)"
               MENU5="Performing all operations in turn (1-4)"
               MENU6="Help"
               ATTENTION="ATTENTION!"
               CHECK_PO="- not found!
Install packages for -"
               FORMAT_USB_TEXT="Step formatting USB-drive (flash drive)

Make sure that the USB-drive is inserted .
It should be on a flash drive to create 2 sections:
Section №1 - file system fat32, will be used for the iso image distribution
Section №2 - an ext2 (ext3, ext4) and tag persistence, it will be used to save the changes during a live-mode
Once again, the section labeled - persistence is very important!
Word persistence - will be copied to the clipboard, just insert during the formation of the label for the section №2

Press OK (Yes) to start Gparted and begin formatting the stick"
               ERROR_MAKE_FILE="I can not find the section labeled persistence. 
Try to create a partition using Gparted"
               OK_MAKE_FILE="The file persistence.conf is created "
               ERROR_EDIT_MENU="Syslinux.cfg file is not found, or found a few files syslinux.cfg
Mount the partition usb- drive and try again.
Specify the path to self- syslinux.cfg

Click OK (Yes) to indicate their own syslinux.cfg"
               OK_EDIT_MENU="Step Edit menu USB-drive (flash driv )
To activate the preservation must be run with the parameter linux kernel persistence,
This parameter can be passed to the kernel in 2 ways:
1) At the time of loading from the usb- drive , edit the menu item by pressing the Tab and
adding to the end of the line the word persistence (Enter - to boot) 
2) Edit syslinux.cfg file menu by adding the word persistence in the end of the line
append initrd=/live/initrd.img .... 
example
append initrd=/live/initrd.img boot=live config quiet splash locales=ru_UA.UTF-8 persistence

Word persistence - will be copied to the clipboard
Click OK (Yes) to start editing the file"
               
               HELP="The script is $0 - generates Live-usb Linux with the ability to save the changes.

In a script used by the utility:
 Gparted - formatting and partitioning your storage devices; 
 Unetbootin - transfer iso to the stick.

You can create a Live-usb consistently moving from 1 to 4, you can run the sequential execution of the sub-items by selecting 5"
               ;;
esac

#########################################################
Help () #Справка
{
echo "$HELP"
}
#########################################################
Check () #Функция проверки ПО
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument check error; exit 1
fi
if [ ! -x "`which "$1"`" ] #Проверка наличия ПО
 then echo $1 - not found!
 $DIALOG --info --title="$ATTENTION" \
              --text="$1 $CHECK_PO $1"
 MainForm
fi
}
#########################################################
FormatUSB () #Функция форматирования USB
{
$DIALOG --question --title="$ATTENTION" \
        --text="$FORMAT_USB_TEXT" 
if [ $? == 0 ]
 then echo -n persistence | xclip -selection "clipboard"
      gparted
 else echo Back; MainForm
fi
}
#########################################################
MakeFile () #Создание файла persistence.conf
{
PARTITION=$(ls -l /dev/disk/by-label/ | grep persistence | sed "s/\(.*\)\///g")
if [[ $PARTITION == '' ]]
then 
 $DIALOG --info --title="$ATTENTION" --text="$ERROR_MAKE_FILE"
MainForm
fi
mkdir /media/persistence/
mount /dev/$PARTITION /media/persistence/
echo "/ union,source=." > /media/persistence/persistence.conf
if [ -f /media/persistence/persistence.conf ]
 then $DIALOG --info --title="$ATTENTION" --text="$OK_MAKE_FILE"
fi
umount /media/persistence/
rm -r /media/persistence
}
#########################################################
EditMenuUSB () #Редактирование загрузочного меню USB
{
MENU_FILE=$(find /media/ -maxdepth 3 -name syslinux.cfg)

if [ -f "$MENU_FILE" ] #Проверка существования backup-list.txt
 then echo "File syslinux.cfg is present - $MENU_FILE"
 else echo "File syslinux.cfg is not present or more! Searching results - $MENU_FILE"
      $DIALOG --question --cancel-label="Back" --title="$ATTENTION" --text="$ERROR_EDIT_MENU"
      if [ $? == 0 ]
       then echo ищем
        MENU_FILE=`$DIALOG  --file-selection --title="Open file syslinux.cfg" --filename=syslinux.cfg`
        if [ $? != 0 ]
         then MainForm
        fi         
       else MainForm
      fi
fi
$DIALOG --question --title="$ATTENTION" \
        --text="$OK_EDIT_MENU $MENU_FILE " 
if [ $? == 0 ]
 then 
  echo Edit $MENU_FILE
  echo -n persistence | xclip -selection "clipboard"
  ORIG_MENU=$(cat "$MENU_FILE")
  EDIT_MENU=$(echo -n "$ORIG_MENU" | zenity --text-info --editable --title="Edit $MENU_FILE" \
            --width=550 --height=500 ) 
  if [ "$EDIT_MENU" != "" ]
   then echo -n "$EDIT_MENU" > $MENU_FILE
  fi
 else echo Back; MainForm
fi
}
#########################################################
MainForm () #Главное меню
{
ANSWER=$($DIALOG --width=400 --height=300 --list --cancel-label="Exit" --title="$MAIN_LABEL" \
      --text="$MAIN_TEXT" \
      --column="" --column="" \
        1 "$MENU1"\
        2 "$MENU2"\
        3 "$MENU3"\
        4 "$MENU4"\
        5 "$MENU5"\
        6 "$MENU6" )
if [ $? == 0 ]
then
  case $ANSWER in
    1) Check gparted
       Check xclip
       FormatUSB
       MainForm
       ;;
    2) MakeFile
       MainForm
       ;;    
    3) Check unetbootin
       unetbootin
       MainForm
       ;;
    4) EditMenuUSB
       Check xclip
       MainForm
       ;;       
    5) Check gparted
       Check unetbootin
       Check xclip
       FormatUSB
       MakeFile
       unetbootin
       EditMenuUSB
       MainForm
       ;;
    6) Help | zenity --text-info --cancel-label="Back" --title="Help" --width=400 --height=300
       MainForm
       ;;              
    *) echo ooops! - $ANSWER
       exit 1
       ;;
 esac
else echo Exit ; exit 0
fi	
}
#########################################################

MainForm

exit 0
