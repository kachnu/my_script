#!/bin/bash
#Скрипт позволяет сохранять конфигурационные файлы NetworkManager
#author: kachnu
# email: ya.kachnu@yandex.ua
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
 uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Настройки сети NetworkManager"
               MAIN_TEXT="Выберите действие:"
               MENU1="Добавить файлы конфигурации сети"
               MENU2="Сохранить конфигурации сети"
               MENU3="Открыть папку с конфигурациями сети"
               MENU4="Перезапустить NetworkManager"
               MENU5="Справка"
               ATTENTION="Внимание!"
               OK_SAVE1="Конфигурационные файлы"
               OK_SAVE2="сохранены в архив"
               SAVE_TEXT="Сохранение сетевых настроек в архив *.tar.gz"
               ADD_TEXT="Выберите архив или конфигурацию NetworkManager"
               CHECK_PO="- не найдено!
Установите пакеты для работы -"
               FIND_POVTORKA="Найдено совпадение"
               EDIT_NAME="Уже имеется файл с таким названием!
Измените имя файла:"
               SELECT_LABEL="Список NetworkManager"
               SELECT_FILES="Выберите конфигурации"
               
               HELP="Данный скрипт позволяет сохранять настройки сети для NetworkManager"
               ;;
           *)  #All UA RU BE locales
               MAIN_LABEL="Network Settings NetworkManager"
               MAIN_TEXT="Select an action:"
               MENU1="Add network configuration files"
               MENU2="Save the network configuration"
               MENU3="Open the folder with the network configuration"
               MENU4="Restart the NetworkManager"
               MENU5="Help"
               ATTENTION="Attention!"
               OK_SAVE1="Configuration files"
               OK_SAVE2="stored in the archive"
               SAVE_TEXT="Save the network settings to the archive *.tar.gz"
               ADD_TEXT="Select the file or the configuration of NetworkManager"
               CHECK_PO="-not found!
Install packages for -"
               FIND_POVTORKA="Matches found"
               EDIT_NAME="There is already a file with that name!
Change the file name:"
               SELECT_LABEL="List NetworkManager"
               SELECT_FILES="Выберите конфигурации"
               
               HELP="This script allows you to save the network settings for NetworkManager"
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
echo -n "$HELP" | $DIALOG --text-info --cancel-label="Back" --title="Help" \
 --width=400 --height=300
}
#####################################################################
AddConfig ()
{
FILE_ADD=`$DIALOG  --file-selection --title="$ADD_TEXT" --save --filename=$HOME_DIR/`
if [ $? == 0 ]
 then
   echo $FILE_ADD
   FILE_LIST=$(tar --list -f $FILE_ADD) #Формирование списка файлов в архиве
   if [ $? == 0 ] #Если список файлов архива можно создать то произойдет распаковка в папку, если нет - добавление файла.
     then    
     FILE_LIST=$(echo "$FILE_LIST" | awk '{print "FALSE\n"$0}')
     CHECKED=`echo "$FILE_LIST"|\
         $DIALOG --list --checklist --title="$SELECT_LABEL" \
                --text="$SELECT_FILES" --column="" --column="Files" --separator="\n"`
     rm -R $TEMP_DIR/*
     tar xvf $FILE_ADD -C  $TEMP_DIR
     cd $TEMP_DIR
     echo -e "$CHECKED" | while read file_name; do 
       POVTORKA=$(find "$WORK_DIR" -name "$file_name") 
       if [ "$POVTORKA" = '' ]
         then cp "$file_name" "$WORK_DIR"
         else FILE_NEW=$($DIALOG --entry --title="$FIND_POVTORKA" --text="$EDIT_NAME" \
          --entry-text="$(basename "$file_name")")
              if [ $? == 0 ]
               then cp "$file_name" "$WORK_DIR"/"$FILE_NEW"
              fi
       fi
       done
     else 
     POVTORKA=$(find "$WORK_DIR" -name "$(basename "$FILE_ADD")")
     if [ "$POVTORKA" = '' ]
       then cp "$FILE_ADD" "$WORK_DIR"
       else FILE_NEW=$($DIALOG --entry --title="$FIND_POVTORKA" --text="$EDIT_NAME" \
          --entry-text="$(basename "$FILE_ADD")")
            if [ $? == 0 ]
              then cp "$FILE_ADD" "$WORK_DIR"/"$FILE_NEW"
            fi
     fi
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
         $DIALOG --list --checklist --title="$SELECT_LABEL" \
                --text="$SELECT_FILES" --column="" --column="Files" --separator="\n"`
echo -e "$CHECKED"
if [ $? == 0 ]
   then
    if [ "$CHECKED" == '' ]
      then MainForm
    fi
    cd "$WORK_DIR"
    rm -R $TEMP_DIR/*
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
          * ) MainForm 
              ;;  
 esac
 else exit 0
fi
}

MainForm

rmdir "$TEMP_DIR"
exit 0
