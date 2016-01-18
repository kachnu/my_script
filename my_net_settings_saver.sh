#!/bin/bash

DIALOG=zenity #Установка типа графического диалогового окна
if [ ! -x "`which "$DIALOG"`" ] #Проверка наличия zenity
 then eсho "Not Install - $DIALOG!"
fi

WORK_DIR="/etc/NetworkManager/system-connections"
HOME_DIR="/home/$SUDO_USER"
FILEMANAGER=thunar

case $LANG in
 uk*|ru*|be*|*) #UA RU BE locales
               MAIN_LABEL="system connections"
               MAIN_TEXT="Выберите действие:"
               MENU1="Добавить файлы конфигураций сети"
               MENU2="Сохранить конфигурации сети"
               MENU3="Открыть папку с конфигурациями сети"
               MENU4="Проверка соединений"
               MENU5="Справка"
               ATTENTION="ВНИМАНИЕ!"
               OK_SAVE1="Конфигурационные файлы"
               OK_SAVE2="сохранены в архив"
               SAVE_TEXT="Сохранение сетевых настроек в архив"
               CHECK_PO="- не найдено!
Установите пакеты для работы -"
               CHECK_NAME_TEXT="Были найдены папки (темы) название, которых содержат ПРОБЕЛЫ.
Наличие пробелов в названии, может повлиять на правильность формирования списка тем.

Вы согласны переименовать папки?"
               HELP="Данный скрипт позволяет управлять "
               ;;
esac

#if [ $(id -u) -ne 0 ] #Проверка на запуск с правами root
  #then
  #echo "Start $0 with root"
  #gksudo $0 
  #exit 0
#fi

if ! [ -d "$WORK_DIR.backup" ]
 then cp -R $WORK_DIR $WORK_DIR.backup
fi

#####################################################################
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
#####################################################################
Help () #Помощь
{
echo -n "$HELP" | zenity --text-info --cancel-label="Back" --title="Help" \
 --width=400 --height=300
}
#####################################################################

AddConfig ()
{
FILE_ADD=`$DIALOG  --file-selection --title="$ADD_TEXT" --save --filename=$HOME_DIR/`
if [ $? == 0 ]
 then
   FILE_LIST=$(tar --list -f $FILE_ADD) #Формирование списка файлов в архиве
   if [ $? == 0 ] #Если список файлов архива можно создать то произойдет распаковка в папку, если нет - добавление файла.
     then  echo -n "$FILE_LIST" | zenity --text-info --title="$ATTENTION $COPY_TEXT" \
--width=400 --height=300 
     tar xvf $FILE_ADD -C  $WORK_DIR
     else cp $FILE_ADD $WORK_DIR
   fi
  chmod -R -r $WORK_DIR/*
fi
service network-manager restart
}
#####################################################################
SaveConfig ()
{
FILE_SAVE=`$DIALOG  --file-selection --title="$SAVE_TEXT" --save --filename=$HOME_DIR/`
if [ $? == 0 ]
 then  
   cd $WORK_DIR/
   tar czpvf $FILE_SAVE\.tar.gz ./
   FILE_LIST=$(ls $WORK_DIR | sed "s/^/\'/" | sed "s/$/\'/")
   $DIALOG --info --title="$ATTENTION" \
              --text="$OK_SAVE1 :
$FILE_LIST 
$OK_SAVE2 $FILE_SAVE\.tar.gz"
fi
}
#####################################################################
SaveConfig2 ()
{
FILE_LIST=$(ls $WORK_DIR | awk '{print "FALSE\n"$0}' |  sed "s/ /\\\ /g")
CHECKED=`echo "$FILE_LIST"|\
         zenity --list --checklist --title="Select network setting-files" \
                --text="Select network setting-files" --column="" --column="Files" --separator=" "`
echo "$CHECKED"
if [ $? == 0 ]
   then
   FILE_SAVE=`$DIALOG  --file-selection --title="$SAVE_TEXT" --save --filename=$HOME_DIR/`
   if [ $? == 0 ]
     then  
     cd "$WORK_DIR"
     tar czpvf "$FILE_SAVE"\.tar.gz "$CHECKED"
     FILE_LIST=$(tar -tvf $FILE_SAVE\.tar.gz)
     $DIALOG --info --title="$ATTENTION" \
              --text="$OK_SAVE1 :
$FILE_LIST 
$OK_SAVE2 $FILE_SAVE\.tar.gz"
   fi
fi
}

#####################################################################
OpenConfig ()
{
Check $FILEMANAGER
`$FILEMANAGER $WORK_DIR`
}
#####################################################################
TestConfig ()
{
	echo
}
#####################################################################
MainForm () #Функция главного окна
{
ANSWER=$($DIALOG --width=400 --height=300 --list --cancel-label="Exit" --title="$MAIN_LABEL" \
      --text="$MAIN_TEXT" \
      --column="" \
      "$MENU1" \
      "$MENU2" \
      "$MENU3" \
      "$MENU4" \
      "$MENU5")
if [ $? == 0 ]
then
 case $ANSWER in
   "$MENU1" ) AddConfig
              MainForm
              ;;
   "$MENU2" ) SaveConfig2
              MainForm
              ;;
   "$MENU3" ) OpenConfig
              MainForm
              ;;
   "$MENU4" ) TestConfig
              MainForm
              ;;
   "$MENU5" ) Help
              MainForm
              ;;
         "" ) MainForm 
              ;;  
           *) echo "ooops!- $ANSWER"
              exit 1
              ;;
 esac
fi
}

MainForm

exit 0
