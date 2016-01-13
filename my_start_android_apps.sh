#!/bin/bash
#Сделано на основании статьи http://vasilisc.com/android-app-in-linux
#Скрипт для запуска android-приложений *.apk, а также подготовленных для запуска файлов ARCon
#author: kachnu
# email: ya.kachnu@yandex.ua

WORK_FOLDER="$HOME/.start_android_apps"

if [ ! -d  "$WORK_FOLDER" ]
 then mkdir -p "$WORK_FOLDER"
fi

if [ ! -f  "$WORK_FOLDER/start_android_apps.conf" ]
 then echo '
#ссылка на скачивание ARCon https://github.com/vladikoff/chromeos-apk/blob/master/archon.md
WGET_ARCON="http://archon.vf.io/ARChon-v1.2-x86_32.zip"

#ссылка на скачивание node https://nodejs.org/download/
WGET_NODE="https://nodejs.org/download/release/latest-v5.x/node-v5.4.0-linux-x86.tar.gz"

#ссылка на скачивание google-chrome https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
WGET_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb"

#указывается путь к папке с ARCon
FOLDER_WITH_ARCHON="$WORK_FOLDER/vladikoff-archon-2d4c947b3f04"

#указывается путь к бинарнику node
FOLDER_WITH_NODE="$WORK_FOLDER/node-v5.4.0-linux-x86/bin"

#Присваивание терминала
MY_TERMINAL="x-terminal-emulator" 

#Присваивание типа графического диалогового окна
DIALOG=zenity

#Присваивание типа текстового редактора
TEXT_EDITOR=geany
' > "$WORK_FOLDER/start_android_apps.conf"
fi

source "$WORK_FOLDER/start_android_apps.conf"

FILE_APK="$1"

HELP="НАИМЕНОВАНИЕ
     Скрипт $0 позволяет запустить файлы *.apk и предварительно подготовленные ARChon файлы (указываются папки) 
СИНТАКСИС
	$0 [КЛЮЧ] [Файл или Папка]
КЛЮЧИ
	-h, --help - выводит данное сообщение
	--install - устанавливает необходимые пакеты и программы для работы с *.apk
	--gui - запуск скрипта в графическом диалоговом окне	
ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ СКРИПТА
	$0 \"/home/user/Game.apk\" - файл *.apk или предварительно подготовленную ARChon папку
	$0 --gui - откроет диалоговое окно поиска
	$0 -h - выводит справку"
##########################################
InstallPackages ()
{
cd "$WORK_FOLDER"
if [ "$ERROR_MASSAGE" != '' ]
 then
   for opt in $ERROR_MASSAGE
   do
    case "$opt" in
    "$FOLDER_WITH_ARCHON") #загрузка и распаковка ARCON
                           FILE_NAME=$(echo "$WGET_ARCON" | sed "s|\(.*\/\)||")
                           if [ -f "$FILE_NAME" ]
                              then unzip "$FILE_NAME"
                              else wget "$WGET_ARCON" && unzip "$FILE_NAME"
                           fi
                           ;;	
      "$FOLDER_WITH_NODE") #загрузка и распаковка node
                            FILE_NAME=$(echo "$WGET_NODE" | sed "s|\(.*\/\)||")
                            if [ -f "$FILE_NAME" ]
                               then tar xvf "$FILE_NAME"
                               else wget "$WGET_NODE" && tar xvf "$FILE_NAME"
                            fi
                           ;;
             chromeos-apk) #установка chromeos-apk
                           sudo apt-get update
                           sudo apt-get install npm
                           sudo npm install chromeos-apk -g
                           ;;
            google-chrome) #установка google-chrome
                           FILE_NAME=$(echo "$WGET_CHROME" | sed "s|\(.*\/\)||")
                           if [ -f "$FILE_NAME" ]
                              then sudo dpkg -i "$FILE_NAME"
                              else wget "$WGET_CHROME" && sudo dpkg -i "$FILE_NAME"
                           fi
                           ;;
     esac
    done                    
 else echo "Все установлено, можно работать!"
fi
}
##########################################
StartApk ()
{
if [ -d "$FILE_APK" ] #обрабатываем папку
 then FOLDER_APK="$FILE_APK"
      google-chrome --profile-directory=Default --enable-easy-off-store-extension-install --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_APK" 
      #$DIALOG --info --title="$ATTENTION" --text="Пожалуйста, закройте google-chrome и повторите попытку"
fi

if [ -f "$FILE_APK" ] #обрабатываем файл *.apk
 then 
      if [ -w "$(dirname "$FILE_APK")" ]
       then WORK_FOLDER=$(dirname "$FILE_APK")
      fi   
      cd $WORK_FOLDER
      export PATH=$PATH:$FOLDER_WITH_NODE
      chromeos-apk "$FILE_APK"
      NAME_FOLDER_APK=$(chromeos-apk "$FILE_APK" | awk '{print $3}')
      echo NAME_FOLDER_APK=$NAME_FOLDER_APK
      FOLDER_APK="$WORK_FOLDER/$NAME_FOLDER_APK"
      echo FOLDER_APK=$FOLDER_APK
      if [ -d "$FOLDER_APK" ]
       then TEXT_TO_INCLUDE=$(cat "$FOLDER_APK/manifest.json" | grep -m1 name | sed "s/name/message/" | sed "s/,//")
            sed -i "s/\"description\": \"Extension name\"/\"description\": \"Extension name\", ${TEXT_TO_INCLUDE}/g" $FOLDER_APK/_locales/en/messages.json
            google-chrome --profile-directory=Default --enable-easy-off-store-extension-install --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_APK" #&& rm -R "$FOLDER_APK"
            #$DIALOG --info --title="$ATTENTION" --text="Пожалуйста, закройте google-chrome и повторите попытку"
      fi
fi
}
##########################################
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
}
##########################################
MessageError ()
{
if [ "$ERROR_MASSAGE" != '' ]
 then echo -e "Есть ошибки: $ERROR_MASSAGE"
      $DIALOG --question --title="$ATTENTION" \
        --text="Есть ошибки: $ERROR_MASSAGE 
Хотите скачать необходимые файлы и установить недостоющие пакеты?" 
      if [ $? == 0 ]
        then $MY_TERMINAL -e $0 --install
        else exit 0
      fi
fi
}
##########################################
GuiForm ()
{
FILE_APK=`$DIALOG --file-selection --title="Выбирите файл *.apk "`
if [ $? == 0 ]
 then StartApk
fi     
}
##########################################
case "$FILE_APK" in
            '') CheckPO
                MessageError
                GuiForm
                ;;
     -h|--help) echo "$HELP"
                read x
                exit 0
                ;;
     --install) CheckPO
                InstallPackages
                ;;   
             *) CheckPO
                MessageError
                StartApk
                ;;
esac   

exit 0
