#!/bin/bash
#Сделано на основании статьи http://vasilisc.com/android-app-in-linux
#Скрипт для запуска android-приложений *.apk а также подготовленных для запуска файлов ARCon
#author: kachnu
# email: ya.kachnu@yandex.ua

#указывается путь к папке с ARCon, скачать можно с ресурса https://github.com/vladikoff/chromeos-apk/blob/master/archon.md
FOLDER_WITH_ARCHON="$HOME/tmp/vladikoff-archon-2d4c947b3f04"

#указывается путь к бинарнику node, скачать можно с ресурса https://nodejs.org/download/
FOLDER_WITH_NODE="$HOME/tmp/node-v5.3.0-linux-x86/bin"

TEMP_FOLDER="$HOME/tmp/"
MY_TERMINAL="x-terminal-emulator" #Присваивание терминала 
DIALOG=zenity #Присваивание типа графического диалогового окна
FILE_APK="$1"

HELP="НАИМЕНОВАНИЕ
     Скрипт $0 позволяет запустить файлы *.ark и предварительно подготовленные ARChon файлы (указываются папки) 
СИНТАКСИС
	$0 [КЛЮЧ] [Файл или Папка]
КЛЮЧИ
	-h, --help - выводит данное сообщение
	--install - устанавливает необходимые пакеты и программы для работы с *.apk
	--gui - запуск скрипта в графическом диалоговом окне	
ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ СКРИПТА
	$0 \"/home/user/Game.apk\" - файл *.ark или предварительно подготовленную ARChon папку
	$0 --gui - откроет диалоговое окно поиска
	$0 -h - выводит справку
"

InstallPackages ()
{
sudo apt-get update
sudo apt-get install npm
sudo npm install -g chromeos-apk
}

StartApk ()
{
if [ -d "$FILE_APK" ] #обрабатываем папку
 then FOLDER_APK="$FILE_APK"
      google-chrome --enable-easy-off-store-extension-install --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_APK" 
      #$DIALOG --info --title="$ATTENTION" --text="Пожалуйста, закройте google-chrome и повторите попытку"
fi

if [ -f "$FILE_APK" ] #обрабатываем файл *.apk
 then 
      if [ -w "$(dirname "$FILE_APK")" ]
       then TEMP_FOLDER=$(dirname "$FILE_APK")
      fi   
      cd $TEMP_FOLDER
      export PATH=$PATH:$FOLDER_WITH_NODE
      chromeos-apk "$FILE_APK"
      NAME_FOLDER_APK=$(chromeos-apk "$FILE_APK" | awk '{print $3}')
      echo NAME_FOLDER_APK=$NAME_FOLDER_APK
      FOLDER_APK="$TEMP_FOLDER/$NAME_FOLDER_APK"
      echo FOLDER_APK=$FOLDER_APK
      if [ -d "$FOLDER_APK" ]
       then TEXT_TO_INCLUDE=$(cat "$FOLDER_APK/manifest.json" | grep -m1 name | sed "s/name/message/" | sed "s/,//")
            sed -i "s/\"description\": \"Extension name\"/\"description\": \"Extension name\", ${TEXT_TO_INCLUDE}/g" $FOLDER_APK/_locales/en/messages.json
            google-chrome --enable-easy-off-store-extension-install --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_APK" #&& rm -R "$FOLDER_APK"
            #$DIALOG --info --title="$ATTENTION" --text="Пожалуйста, закройте google-chrome и повторите попытку"
      fi
fi
}

CheckPO () #проверки необходимых для работы программ
{
ERROR_MASSAGE=''

if [ ! -d $FOLDER_WITH_ARCHON ]
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n * Папка $FOLDER_WITH_ARCHON  не существует!")
fi

if [ ! -d $FOLDER_WITH_NODE ]
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n * Папка $FOLDER_WITH_NODE не существует!")
fi

if [ ! -x "`which chromeos-apk`" ] #Проверка наличия chromeos-apk
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n * Не установлен chromeos-apk! Пожалуйста, выполните в терминале команду $0 --install")
fi

if [ ! -x "`which google-chrome`" ] #Проверка наличия google-chrome
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n * Не установлен google-chrome! Пожалуйста, установите google-chrome")
fi

if [ "$ERROR_MASSAGE" != '' ]
 then echo -e "Есть ошибки: $ERROR_MASSAGE"
      exit 1    
fi
}

GuiForm ()
{
FILE_APK=`$DIALOG --file-selection --title="Выбирите файл *.apk "`
if [ $? == 0 ]
 then $0 "$FILE_APK"
      exit 0
 else exit 0
fi
}

case "$FILE_APK" in
            '') echo "Не указан аргумент. Чтобы получить дополнительную информацию, наберите: $0 -h "
                exit 1
                ;;
     -h|--help) echo "$HELP"
                read x
                exit 0
                ;;
     --install) InstallPackages
                ;;
         --gui) CheckPO
                GuiForm
                ;;     
             *) CheckPO
                StartApk
                ;;
esac   

exit 0
