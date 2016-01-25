#!/bin/bash

if [ $(id -u) -ne 0 ] #Проверка на запуск с правами root
  then
  echo "Start $0 with root"
  gksudo $0 
  exit 0
fi

DIALOG=zenity #Установка типа графического диалогового окна
if [ ! -x "`which "$DIALOG"`" ] #Проверка наличия zenity
 then eсho "Not Install - $DIALOG!"
fi

WORK_DIR="/etc/NetworkManager/system-connections"
TEMP_DIR="/tmp/net_sittings_saver/"
HOME_DIR="/home/$SUDO_USER"
FILEMANAGER=thunar

case $LANG in
 uk*|ru*|be*|*) #UA RU BE locales
               MAIN_LABEL="Настройки сети NetworkManager"
               MAIN_TEXT="Выберите действие:"
               MENU1="Добавить файлы конфигураций сети"
               MENU2="Сохранить конфигурации сети"
               MENU3="Открыть папку с конфигурациями сети"
               MENU4="Перезапустить NetworkManager"
               MENU5="Справка"
               ATTENTION="Внимание!"
               OK_SAVE1="Конфигурационные файлы"
               OK_SAVE2="сохранены в архив"
               SAVE_TEXT="Сохранение сетевых настроек в архив"
               CHECK_PO="- не найдено!
Установите пакеты для работы -"
               HELP="Данный скрипт позволяет сохранять настройки сети для NetworkManager"
               ;;
esac

if [ ! -d "$TEMP_DIR" ]
 then mkdir "$TEMP_DIR"
 else rm -R $TEMP_DIR/*
fi 

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
   FILE_LIST=$(tar --list -f $FILE_ADD  | awk '{print "FALSE\n"$0}') #Формирование списка файлов в архиве
   echo "$FILE_LIST"
   if [ $? == 0 ] #Если список файлов архива можно создать то произойдет распаковка в папку, если нет - добавление файла.
     then  CHECKED=`echo "$FILE_LIST"|\
         zenity --list --checklist --title="Select network setting-files" \
                --text="Select network setting-files" --column="" --column="Files" --separator="\n"`
     tar xvf $FILE_ADD -C  $TEMP_DIR
     cd $TEMP_DIR
     echo -e "$CHECKED" | while read file_name; do cp "$file_name" "$WORK_DIR"; done
     else cp $FILE_ADD $WORK_DIR
   fi
  chmod -R -r $WORK_DIR/*
fi
service network-manager restart
}
#####################################################################
SaveConfig ()
{
FILE_LIST=$(ls $WORK_DIR | awk '{print "FALSE\n"$0}')
CHECKED=`echo "$FILE_LIST"|\
         zenity --list --checklist --title="Select network setting-files" \
                --text="Select network setting-files" --column="" --column="Files" --separator="\n"`
echo -e "$CHECKED"
if [ $? == 0 ]
   then
    cd "$WORK_DIR"
    echo -e "$CHECKED" | while read file_name; do cp "$file_name" "$TEMP_DIR"; done
    FILE_SAVE=`$DIALOG  --file-selection --title="$SAVE_TEXT" --save --filename=$HOME_DIR/`
    if [ $? == 0 ]
     then  
     cd "$TEMP_DIR"
     tar czpvf $FILE_SAVE\.tar.gz *
     FILE_LIST=$(ls $WORK_DIR | sed "s/^/\'/" | sed "s/$/\'/")
     $DIALOG --info --title="$ATTENTION" \
              --text="$OK_SAVE1 :
$CHECKED
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
   "$MENU2" ) SaveConfig
              MainForm
              ;;
   "$MENU3" ) OpenConfig
              MainForm
              ;;
   "$MENU4" ) service network-manager restart
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

rmdir "$TEMP_DIR"
exit 0
