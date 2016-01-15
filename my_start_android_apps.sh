#!/bin/bash
#Сделано на основании статьи http://vasilisc.com/android-app-in-linux
#Скрипт для запуска android-приложений *.apk, а также подготовленных для запуска файлов ARCHON
#author: kachnu
# email: ya.kachnu@yandex.ua

WORK_FOLDER="$HOME/.start_android_apps"

if [ ! -d  "$WORK_FOLDER" ]
 then mkdir -p "$WORK_FOLDER"
fi

case "$LANG" in
uk*|ru*|be*) #UA RU BE locales
if [ ! -f  "$WORK_FOLDER/start_android_apps.conf" ]
 then echo '
#ссылка на скачивание ARCHON https://github.com/vladikoff/chromeos-apk/blob/master/archon.md
WGET_ARCHON="http://archon.vf.io/ARChon-v1.2-x86_32.zip"

#альтернативная ссылка на ARCHON, загрузка произойдет если главная ссылка будет нерабочей
WGET_ARCHON_ALTERNATIVE=

#ссылка на скачивание node https://nodejs.org/download/
WGET_NODE="https://nodejs.org/download/release/v5.4.1/node-v5.4.1-linux-x86.tar.gz"

#альтернативная ссылка на node, загрузка произойдет если главная ссылка будет нерабочей
WGET_NODE_ALTERNATIVE=

#ссылка на скачивание google-chrome https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
WGET_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb"

#ссылка на скачивание ChromeAPK
GET_CHROMEAPK="https://docs.google.com/spreadsheets/d/1iIbxaftAu_ho5rv9fUlXSLTzwU6MbKOldsWXyrYiyo8/htmlview?usp=sharing#"

#путь к папке с ARCHON
FOLDER_WITH_ARCHON="$WORK_FOLDER/vladikoff-archon-2d4c947b3f04"

#путь к бинарнику node
FOLDER_WITH_NODE="$WORK_FOLDER/node-v5.4.1-linux-x86/bin"

#параметр который указывает, что делать с папками *.android:
#"yes" - папки будут удаляться после закрытия android-приложения, любое другое значение - папки будут оставаться нетронутыми
# по умолчанию данный параметр не задан
DEL_FOLDER_ANDROID=no

#параметр который указывает, где будут создаваться папки *.android при работе с *.apk
#по умолчанию данный параметр не задан, и папки *.android будут создаваться там же где и файл *.apk
SAVE_ANDROID_FOLDER=

#присваивание терминала
MY_TERMINAL="x-terminal-emulator" 

#присваивание типа графического диалогового окна
DIALOG=zenity

#присваивание типа текстового редактора
TEXT_EDITOR=geany
' > "$WORK_FOLDER/start_android_apps.conf"
fi
MAIN_LABEL="Запуск android-приложений"
MAIN_TEXT="Выберите действие"
MENU1="Запустить android-приложение *.apk ..."
MENU2="Запустить ChromeAPK из папки ..."
MENU3="Установить необходимые приложения"
MENU4="Скачать ChromeAPK из Интернет"
MENU5="Редактирование файла настроек"
MENU6="Справка"
ATTENTION="Внимание!"
FOLDER_NOT_FOUND="папка не найдена!"
NOT_INSTALL="не установлено!"
QUESTION_INSTALL="Хотите скачать необходимые файлы и установить недостающие пакеты?"
QUESTION_KILL_CHROME="Для запуска android-приложения необходимо закрыть Chrome.\\n
Вы согласны закрыть Chrome сейчас?"
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
;;
*)  #All locales
;;
esac

source "$WORK_FOLDER/start_android_apps.conf"

##########################################
InstallPackages ()
{
cd "$WORK_FOLDER"
if [ "$ERROR_MASSAGE" != '' ]
 then
    for opt in $ERROR_MASSAGE
    do
    case "$opt" in
    "$FOLDER_WITH_ARCHON") #загрузка и распаковка ARCHON
                           FILE_NAME=$(echo "$WGET_ARCHON" | sed "s|\(.*\/\)||")
                           FILE_NAME_ALTERNATIVE=$(echo "$WGET_ARCHON_ALTERNATIVE" | sed "s|\(.*\/\)||")
                           if [ -f "$FILE_NAME" ] || [ -f "$FILE_NAME_ALTERNATIVE" ] 
                              then echo $FILE_NAME
                                   unzip "$FILE_NAME" || unzip "$FILE_NAME_ALTERNATIVE"
                              else wget "$WGET_ARCHON" || wget "$WGET_ARCHON_ALTERNATIVE"
                                   unzip "$FILE_NAME" || unzip "$FILE_NAME_ALTERNATIVE"
                           fi
                           #if [ $?!=0 ]
                              #then FILE_NAME=$(echo "$WGET_ARCHON_ALTERNATIVE" | sed "s|\(.*\/\)||")
                                   #if [ -f "$FILE_NAME" ]
                                     #then unzip "$FILE_NAME"
                                     #else wget "$WGET_ARCHON_ALTERNATIVE" && unzip "$FILE_NAME"
                                   #fi
                           #fi
                           #NEW_FOLDER_WITH_ARCHON=$(unzip -l "$FILE_NAME" | grep -A3 "Name" | grep -m1 "0" | awk '{print $4}')
                           #echo $NEW_FOLDER_WITH_ARCHON
                           #if [ -d $NEW_FOLDER_WITH_ARCHON ]
                            #then 
                             #echo $FOLDER_WITH_ARCHON
                             #sed -i "FOLDER_WITH_ARCHON=|s|!FOLDER_WITH_ARCHON=|${NEW_FOLDER_WITH_ARCHON}|" start_android_apps.conf && echo iouoiuoiuoiu
                           #fi
                           ;;	
      "$FOLDER_WITH_NODE") #загрузка и распаковка node
                            FILE_NAME=$(echo "$WGET_NODE" | sed "s|\(.*\/\)||")
                            FILE_NAME_ALTERNATIVE=$(echo "$WGET_NODE_ALTERNATIVE" | sed "s|\(.*\/\)||")
                            if [ -f "$FILE_NAME" ] || [ -f "$FILE_NAME_ALTERNATIVE" ] 
                               then tar xvf "$FILE_NAME" || tar xvf "$FILE_NAME_ALTERNATIVE"
                               else wget "$WGET_NODE" || wget "$WGET_NODE_ALTERNATIVE"
                                    tar xvf "$FILE_NAME" || tar xvf "$FILE_NAME_ALTERNATIVE"
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
    echo Enter to exit!
    read x
 else echo "Все установлено, можно работать!"
      echo "All install!"
      echo "Enter to exit!"
      read x
fi
}
##########################################
KillChrome ()
{
if pidof chrome > /dev/null
 then  
 $DIALOG --question --title="$ATTENTION" \
        --text="$QUESTION_KILL_CHROME" 
      if [ $? == 0 ]
        then  killall chrome
        else exit 0
      fi
fi
}
##########################################
StartApk ()
{
if [ -d "$FILE_APK" ] #обрабатываем папку
 then FOLDER_ANDROID="$FILE_APK"
      google-chrome --enable-easy-off-store-extension-install --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_ANDROID" 
fi

if [ -f "$FILE_APK" ] #обрабатываем файл *.apk
 then 
      if [ -w "$(dirname "$FILE_APK")" ]
       then WORK_FOLDER=$(dirname "$FILE_APK")
      fi
      if [ -w "$SAVE_ANDROID_FOLDER" ]
       then WORK_FOLDER=$SAVE_ANDROID_FOLDER
      fi   
      cd $WORK_FOLDER
      export PATH=$PATH:$FOLDER_WITH_NODE
      chromeos-apk "$FILE_APK"
      NAME_FOLDER_APK=$(chromeos-apk "$FILE_APK" | awk '{print $3}')
      echo NAME_FOLDER_APK=$NAME_FOLDER_APK
      FOLDER_ANDROID="$WORK_FOLDER/$NAME_FOLDER_APK"
      echo FOLDER_ANDROID=$FOLDER_ANDROID
      if [ -d "$FOLDER_ANDROID" ]
       then TEXT_TO_INCLUDE=$(cat "$FOLDER_ANDROID/manifest.json" | grep -m1 name | sed "s/name/message/" | sed "s/,//")
            sed -i "s/\"description\": \"Extension name\"/\"description\": \"Extension name\", ${TEXT_TO_INCLUDE}/g" $FOLDER_ANDROID/_locales/en/messages.json
            google-chrome --enable-easy-off-store-extension-install --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_ANDROID" && \
            if [ $DEL_FOLDER_ANDROID == 'yes' ]
               then rm -R "$FOLDER_ANDROID"
            fi
      fi
fi
}
##########################################
CheckPO () #проверки необходимых для работы программ
{
ERROR_MASSAGE=''

if [ ! -d $FOLDER_WITH_ARCHON ] #Проверка наличия ARCHON
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n - $FOLDER_WITH_ARCHON - $FOLDER_NOT_FOUND")
fi

if [ ! -d $FOLDER_WITH_NODE ] #Проверка наличия NODE
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n - $FOLDER_WITH_NODE - $FOLDER_NOT_FOUND")
fi

if [ ! -x "`which chromeos-apk`" ] #Проверка наличия chromeos-apk
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n - chromeos-apk - $NOT_INSTALL")
fi

if [ ! -x "`which google-chrome`" ] #Проверка наличия google-chrome
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n - google-chrome - $NOT_INSTALL")
fi
}
##########################################
MessageError ()
{
if [ "$ERROR_MASSAGE" != '' ]
 then echo -e "ERROR: $ERROR_MASSAGE"
      $DIALOG --question --title="$ATTENTION" \
        --text="ERROR: $ERROR_MASSAGE \\n \\n $QUESTION_INSTALL" 
      if [ $? == 0 ]
        then $MY_TERMINAL -e $0 --install
        else exit 0
      fi
fi
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
         FILE_APK=`$DIALOG --file-selection --title="Open *.apk"`
         if [ $? == 0 ]
            then KillChrome
                 StartApk
            else MainForm
         fi 
         ;;
	  2) CheckPO
         MessageError
         FILE_APK=`$DIALOG --file-selection --directory --title="Open folder"`
         if [ $? == 0 ]
            then KillChrome
                 StartApk
            else MainForm
         fi
	     ;;
	  3) $MY_TERMINAL -e $0 --install
	     MainForm
	     ;;
	  4) x-www-browser "$GET_CHROMEAPK" &
	     MainForm
         ;;
      5) $TEXT_EDITOR "$WORK_FOLDER/start_android_apps.conf"
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
                KillChrome
                StartApk
                ;;
esac   

exit 0
