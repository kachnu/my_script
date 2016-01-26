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
WGET_ARCHON_ALTERNATIVE="http://www.ex.ua/load/219729766"

#ссылка на скачивание node https://nodejs.org/download/
WGET_NODE="https://nodejs.org/download/release/v5.4.1/node-v5.4.1-linux-x86.tar.gz"

#альтернативная ссылка на node, загрузка произойдет если главная ссылка будет нерабочей
WGET_NODE_ALTERNATIVE="http://www.ex.ua/load/219729841"

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

#присваивание файлового менеджера
MY_FM=thunar
' > "$WORK_FOLDER/start_android_apps.conf"
fi
MAIN_LABEL="Запуск android-приложений"
MAIN_TEXT="Выберите действие"
MENU1="Запустить android-приложение *.apk ..."
MENU2="Запустить ChromeAPK из папки ..."
MENU3="Установить необходимые приложения"
MENU4="Скачать ChromeAPK из Интернет"
MENU5="Редактировать файл настроек"
MENU6="Открыть папку с ярлыками Chrome"
MENU7="Открыть рабочую папку скрипта"
MENU8="Справка"
ATTENTION="Внимание!"
FOLDER_NOT_FOUND="папка не найдена!"
NOT_INSTALL="не установлено!"
QUESTION_INSTALL="Хотите скачать необходимые файлы и установить недостающие пакеты?"
QUESTION_KILL_CHROME="Для запуска android-приложения необходимо закрыть Chrome.\\n
Вы согласны закрыть Chrome сейчас?"
HELP="НАИМЕНОВАНИЕ
     Скрипт $0 позволяет запустить файлы *.apk и предварительно подготовленные ARChon файлы ChromeAPK (указываются папки) 
СИНТАКСИС
	$0 [КЛЮЧ] [Файл или Папка]
КЛЮЧИ
	-h, --help - выводит данное сообщение
	--install - устанавливает необходимые пакеты и программы для работы с *.apk
ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ СКРИПТА
	$0 \"/home/user/Game.apk\" - файл *.apk или предварительно подготовленную ARChon папку
	$0 - запускает gui-форму
	$0 -h - выводит справку
Для запуска ChromeAPK обязательным является наличие ARChon и google-chrome для запуска *.apk необходимо также chromeos-apk и nodejs
"
;;
*)  #All locales
if [ ! -f  "$WORK_FOLDER/start_android_apps.conf" ]
 then echo '
#download link ARCHON https://github.com/vladikoff/chromeos-apk/blob/master/archon.md
WGET_ARCHON="http://archon.vf.io/ARChon-v1.2-x86_32.zip"

#Alternative link to ARCHON, loading will happen if the main link is broken
WGET_ARCHON_ALTERNATIVE="http://www.ex.ua/load/219729766"

#download link node https://nodejs.org/download/
WGET_NODE="https://nodejs.org/download/release/v5.4.1/node-v5.4.1-linux-x86.tar.gz"

#Alternative link to the node, the download will happen if the main link is broken
WGET_NODE_ALTERNATIVE="http://www.ex.ua/load/219729841"

#download link google-chrome https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
WGET_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb"

#download link ChromeAPK
GET_CHROMEAPK="https://docs.google.com/spreadsheets/d/1iIbxaftAu_ho5rv9fUlXSLTzwU6MbKOldsWXyrYiyo8/htmlview?usp=sharing#"

#path to ARCHON
FOLDER_WITH_ARCHON="$WORK_FOLDER/vladikoff-archon-2d4c947b3f04"

#path to node
FOLDER_WITH_NODE="$WORK_FOLDER/node-v5.4.1-linux-x86/bin"

#parameter that indicates what to do with folders * .android:
#"yes" - folder will be deleted after closing the android- app , any other value - folders will remain untouched
#by default, this parameter is not specified
DEL_FOLDER_ANDROID=no

#parameter that indicates where the folder will be created * .android working with * .apk
#by default, this parameter is not defined , and folders * .android will be created in the same place where the * .apk file
SAVE_ANDROID_FOLDER=

#terminal assignment
MY_TERMINAL="x-terminal-emulator" 

#assigning a graphical dialog box
DIALOG=zenity

#assigning a text editor
TEXT_EDITOR=geany

#Assignment File Manager
MY_FM=thunar
' > "$WORK_FOLDER/start_android_apps.conf"
fi
MAIN_LABEL="Running android- apps"
MAIN_TEXT="Select an action"
MENU1="Start android- app * .apk ..."
MENU2="Start ChromeAPK folder ..."
MENU3="Install the required applications"
MENU4="Download from the Internet ChromeAPK"
MENU5="Edit the configuration file"
MENU6="Open the folder with Chrome shortcuts"
MENU7="Open the working directory of the script"
MENU8="Help"
ATTENTION="Attention!"
FOLDER_NOT_FOUND="folder not found!"
NOT_INSTALL="not installed!"
QUESTION_INSTALL="Want to download the files and install the missing packages ?"
QUESTION_KILL_CHROME="To launch android- application is necessary to close Chrome.\\n
You agree to close the Chrome now?"
HELP="NAME
     The script allows you to run $0 *.apk files and pre- prepared files ARChon ChromeAPK (specified folder)
SYNTAX
	$0 [ KEY ] [ File or Folder]
KEYS
	-h, --help - displays this message
	--install - installs the required packages and programs to work with * .apk
EXAMPLES OF SCRIPT
	$0 \"/home/user/Game.apk\" - *.apk file or folder previously prepared ARChon
	$0 - launches the gui- shape
	$0 -h - displays help
To start ChromeAPK required is the presence of ARChon and google-chrome to run * .apk must also chromeos-apk and nodejs
"
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
                   ARCHON) #загрузка и распаковка ARCHON
                           FILE_NAME=$(echo "$WGET_ARCHON" | sed "s|\(.*\/\)||")
                           FILE_NAME_ALTERNATIVE=$(echo "$WGET_ARCHON_ALTERNATIVE" | sed "s|\(.*\/\)||")
                           if [ -f "$FILE_NAME" ] || [ -f "$FILE_NAME_ALTERNATIVE" ]
                              then unzip "$FILE_NAME" || FILE_NAME="$FILE_NAME_ALTERNATIVE"
                                   unzip -n "$FILE_NAME"
                              else wget "$WGET_ARCHON" || wget "$WGET_ARCHON_ALTERNATIVE"
                                   unzip "$FILE_NAME" || FILE_NAME="$FILE_NAME_ALTERNATIVE"
                                   unzip -n "$FILE_NAME"
                           fi
                           #Добавление актуальной информации о папке с ARCHON в конфигурационный файл start_android_apps.conf
                           NEW_FOLDER_WITH_ARCHON=$(unzip -l "$FILE_NAME" | grep -A3 "Name" | grep -m1 "0" | awk '{print $4}')
                           if [ -d $NEW_FOLDER_WITH_ARCHON ]
                            then echo "Add FOLDER_WITH_ARCHON=\"\$WORK_FOLDER/$NEW_FOLDER_WITH_ARCHON\" to start_android_apps.conf"
                                 sed -i "s|FOLDER_WITH_ARCHON=.*|FOLDER_WITH_ARCHON=\"\$WORK_FOLDER/${NEW_FOLDER_WITH_ARCHON}\"|g" start_android_apps.conf
                           fi
                           ;;	
                      NODE) #загрузка и распаковка node
                            FILE_NAME=$(echo "$WGET_NODE" | sed "s|\(.*\/\)||")
                            FILE_NAME_ALTERNATIVE=$(echo "$WGET_NODE_ALTERNATIVE" | sed "s|\(.*\/\)||")
                            if [ -f "$FILE_NAME" ] || [ -f "$FILE_NAME_ALTERNATIVE" ]
                               then tar -xvf "$FILE_NAME" || FILE_NAME="$FILE_NAME_ALTERNATIVE"
                                    tar -xvf "$FILE_NAME"
                               else wget "$WGET_NODE" || wget "$WGET_NODE_ALTERNATIVE"
                                    tar -xvf "$FILE_NAME" || FILE_NAME="$FILE_NAME_ALTERNATIVE"
                                    tar -xvf "$FILE_NAME"
                            fi
                           #Добавление актуальной информации о папке с node в конфигурационный файл start_android_apps.conf
                           NEW_FOLDER_WITH_NODE=$(tar -tvf "$FILE_NAME" | grep -m1 "0" | awk '{print $6}')
                           if [ -d $NEW_FOLDER_WITH_NODE ]
                            then echo "Add FOLDER_WITH_NODE=\"\$WORK_FOLDER/$NEW_FOLDER_WITH_NODE\" to start_android_apps.conf"
                                 sed -i "s|FOLDER_WITH_NODE=.*|FOLDER_WITH_NODE=\"\$WORK_FOLDER/${NEW_FOLDER_WITH_NODE}bin\"|g" start_android_apps.conf
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
              sleep 1
        else exit 0
      fi
fi
}
##########################################
CheckPO () #проверки необходимых для работы программ
{
ERROR_MASSAGE=''

if [ ! -d $FOLDER_WITH_ARCHON ] || [[ $FOLDER_WITH_ARCHON = '' ]] #Проверка наличия ARCHON
 then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n - ARCHON $FOLDER_WITH_ARCHON - $FOLDER_NOT_FOUND")
fi

if [ "$1" = "full" ]
   then
        if [ ! -d $FOLDER_WITH_NODE ] || [[ $FOLDER_WITH_NODE = '' ]] #Проверка наличия NODE
           then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n - NODE $FOLDER_WITH_NODE - $FOLDER_NOT_FOUND")
        fi

        if [ ! -x "`which chromeos-apk`" ] #Проверка наличия chromeos-apk
           then ERROR_MASSAGE=$(echo -e "$ERROR_MASSAGE \\n - chromeos-apk - $NOT_INSTALL")
        fi
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
        then InstallPackages
        else exit 0
      fi
fi
}
##########################################
StartApk ()
{
if [ -d "$FILE_APK" ] #обрабатываем папку
 then FOLDER_ANDROID="$FILE_APK"
      CheckPO
      MessageError
      KillChrome
      google-chrome --enable-webgl --ignore-gpu-blacklist --enable-easy-off-store-extension-install --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_ANDROID" 
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
      CheckPO full
      MessageError
      export PATH=$PATH:$FOLDER_WITH_NODE
      chromeos-apk "$FILE_APK"
      NAME_FOLDER_APK=$(chromeos-apk "$FILE_APK" | awk '{print $3}')
      echo NAME_FOLDER_APK=$NAME_FOLDER_APK
      FOLDER_ANDROID="$WORK_FOLDER/$NAME_FOLDER_APK"
      echo FOLDER_ANDROID=$FOLDER_ANDROID
      if [ -d "$FOLDER_ANDROID" ]
       then TEXT_TO_INCLUDE=$(cat "$FOLDER_ANDROID/manifest.json" | grep -m1 name | sed "s/name/message/" | sed "s/,//")
            sed -i "s/\"description\": \"Extension name\"/\"description\": \"Extension name\", ${TEXT_TO_INCLUDE}/g" $FOLDER_ANDROID/_locales/en/messages.json
            KillChrome
            google-chrome --enable-webgl --ignore-gpu-blacklist --enable-easy-off-store-extension-install --load-extension="$FOLDER_WITH_ARCHON" --load-and-launch-app="$FOLDER_ANDROID" && \
            if [ $DEL_FOLDER_ANDROID == 'yes' ]
               then rm -R "$FOLDER_ANDROID"
            fi
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
        6 "$MENU6"\
        7 "$MENU7"\
        8 "$MENU8")
if [ $? == 0 ]
then
 case $ANSWER in
      1) FILE_APK=`$DIALOG --file-selection --title="Open *.apk"`
         if [ $? == 0 ]
            then StartApk
            else MainForm
         fi 
         ;;
	  2) FILE_APK=`$DIALOG --file-selection --directory --title="Open folder"`
         if [ $? == 0 ]
            then StartApk
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
      6) $MY_FM "$HOME/.local/share/applications"
         MainForm
         ;;
      7) $MY_FM "$WORK_FOLDER" 
         MainForm
         ;;
      8) echo -n "$HELP" | $DIALOG --text-info --cancel-label="Back" --title="Help" --width=400 --height=300
         MainForm
         ;;
      *) MainForm
         ;; 
 esac
 else exit 0 
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
     --install) CheckPO full
                InstallPackages
                ;;   
             *) CheckPO
                MessageError
                KillChrome
                StartApk
                ;;
esac   

exit 0
