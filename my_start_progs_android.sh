#!/bin/bash
#http://vasilisc.com/android-app-in-linux

#указывается путь к папке с ARCon, скачать можно с ресурса https://github.com/vladikoff/chromeos-apk/blob/master/archon.md
FOLDER_WITH_ARCHON="$HOME/tmp/vladikoff-archon-2d4c947b3f04"

#указыкается путь к бинарнику node, скачать можно с ресурса https://nodejs.org/download/
FOLDER_WITH_NODE="$HOME/tmp/node-v5.3.0-linux-x86/bin"

TEMP_FOLDER="$HOME/tmp/"
MY_TERMINAL="x-terminal-emulator"
FILE_APK="$1"

InstallPackages ()
{
sudo apt-get update
sudo apt-get install npm
sudo npm install -g chromeos-apk
}

StartApk ()
{
cd $TEMP_FOLDER
export PATH=$PATH:$FOLDER_WITH_NODE
chromeos-apk "$FILE_APK"
NAME_FOLDER_APK=$(chromeos-apk "$FILE_APK" | awk '{print $3}')
echo NAME_FOLDER_APK=$NAME_FOLDER_APK
FOLDER_APK="$TEMP_FOLDER/$NAME_FOLDER_APK"
echo FOLDER_APK=$FOLDER_APK
if [ -d "$FOLDER_APK" ]
 then
    TEXT_TO_INCLUDE=$(cat "$FOLDER_APK/manifest.json" | grep -m1 name | sed "s/name/message/" | sed "s/,//")
    sed -i "s/\"description\": \"Extension name\"/\"description\": \"Extension name\", ${TEXT_TO_INCLUDE}/g" $FOLDER_APK/_locales/en/messages.json
    google-chrome --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_APK" # && rm -R "$FOLDER_APK"
fi
}

CheckPO ()
{
ERROR_MASSAGE=''

if [ ! -d $FOLDER_WITH_ARCHON ]
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n * Папка $FOLDER_WITH_ARCHON  не существует!")
fi

if [ ! -d $FOLDER_WITH_NODE ]
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n * Папка $FOLDER_WITH_NODE не существует!")
fi

if [ ! -x "`which chromeos-apk`" ] #Проверка наличия chromeos-apk
 then 
      ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n * Не установлен chromeos-apk! Пожалуйста выполните в терминале команду $0 --install")
fi

if [ ! -x "`which google-chrome`" ] #Проверка наличия google-chrome
 then 
      ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n * Не установлен google-chrome! Пожалуйста установите google-chrome")
fi

if [ "$ERROR_MASSAGE" != '' ]
 then echo -e "Есть ошибки: $ERROR_MASSAGE"
      read x
      exit 1
fi
}

case "$FILE_APK" in
            '') echo "Не указан аргумент. Наберите $0 -h , чтобы получить дополнительную информацию"
                #$MY_TERMINAL -e $0 -h
                exit 1
                ;;
     -h|--help) echo "Скрипт $0 позволяет запустить файлы *.ark"
                read x
                exit 0
                ;;
     --install) InstallPackages
                ;;     
         *.apk) if [ -f "$FILE_APK" ]
                  then 
                      if [ -w "$FILE_APK" ]
                         then TEMP_FOLDER=$(dirname "$FILE_APK" )
                      fi   
                      CheckPO
                      StartApk
                fi
                ;;
             *) if [ -d "$FILE_APK" ]
                  then FOLDER_APK="$FILE_APK"
                       CheckPO
                       google-chrome --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_APK"
                fi
                ;;
esac   

exit 0
