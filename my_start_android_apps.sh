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

#Ссылка на скачивание ChromeAPK
GET_CHROMEAPK="https://docs.google.com/spreadsheets/d/1iIbxaftAu_ho5rv9fUlXSLTzwU6MbKOldsWXyrYiyo8/htmlview?usp=sharing#"

#Присваивание типа текстового редактора
TEXT_EDITOR=geany
' > "$WORK_FOLDER/start_android_apps.conf"
fi

source "$WORK_FOLDER/start_android_apps.conf"

MAIN_LABEL="Запуск android-приложений"
MAIN_TEXT="Выберите действие"
MENU1="Запустить android-приложение *.apk ..."
MENU2="Запустить ChromeAPK из папки ..."
MENU3="Установить необходимые для работы скрипта приложения"
MENU4="Скачать ChromeAPK из Интернет"
MENU5="Настройки"
MENU6="Справка"
ATTENTION="Внимание!"
HELP="НАИМЕНОВАНИЕ
     Скрипт $0 позволяет запустить файлы *.apk и предварительно подготовленные ARChon файлы (указываются папки) 
СИНТАКСИС
	$0 [КЛЮЧ] [Файл или Папка]
КЛЮЧИ
	-h, --help - выводит данное сообщение
	--install - устанавливает необходимые пакеты и программы для работы с *.apk
ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ СКРИПТА
	$0 \"/home/user/Game.apk\" - файл *.apk или предварительно подготовленную ARChon папку
	$0 - запускает gui-форму
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
      read x
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
Хотите скачать необходимые файлы и установить недостающие пакеты?" 
      if [ $? == 0 ]
        then $MY_TERMINAL -e $0 --install
        else exit 0
      fi
fi
}
##########################################
SettingsForm ()
{
echo settings
}
##########################################
MainForm ()
{
ANSWER=$($DIALOG --width=400 --height=300 --list --cancel-label="Exit" --title="$MAIN_LABEL" \
      --text="$MAIN_TEXT" \
      --column="" --column="" \
        1 "$MENU1"\
        2 "$MENU2"\
        3 "$MENU3"\
        4 "$MENU4"\
        5 "$MENU5"\
        6 "$MENU6")
if [ $? == 0 ]
then
 case $ANSWER in
      1) CheckPO
         MessageError
         FILE_APK=`$DIALOG --file-selection --title="Выбирите файл *.apk"`
         if [ $? == 0 ]
            then StartApk
         fi 
         ;;
	  2) CheckPO
         MessageError
         FILE_APK=`$DIALOG --file-selection --directory --title="Выбирите папку"`
         if [ $? == 0 ]
            then StartApk
         fi
	     ;;
	  3) $MY_TERMINAL -e $0 --install
	     MainForm
	     ;;
	  4) x-www-browser "$GET_CHROMEAPK"
         ;;
      5) SettingsForm
         MainForm
         ;;
      6) echo -n "$HELP" | $DIALOG --text-info --cancel-label="Back" --title="Help" --width=400 --height=300
         MainForm
         ;;
      *) MainForm
         ;; 
 esac 
fi
   
}
##########################################
FILE_APK="$1"

case "$FILE_APK" in
            '') MainForm
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
