#!/bin/bash
#Скрипт по сохранению/открытию (ранее сохраненных) настроек xfce
#Xfce 4.10
#author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=zenity #Установка типа графического диалогового окна

FOLDER=~/.backup-xfce #Назначение рабочей папки для скрипта

if [ ! -x "`which "$DIALOG"`" ] #Проверка наличия zenity
 then eсho "Not Install $DIALOG!"
fi

if [ ! -d $FOLDER ]
 then mkdir $FOLDER
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Сохранение/восстановление настроек Xfce"
               MAIN_TEXT="Выберите действие:"
               MENU1="Сохранить настройки xfce"
               MENU2="Открыть сохраненные архивы настроек xfce"
               MENU3="Применить настройки вида Gnome2 (Mate)"
               MENU4="Применить настройки вида Xfce"
               MENU5="Применить настройки вида Windows"
               MENU6="Применить настройки вида Default"
               SAVE_LABEL="Выбор настроек для сохранения"
               SAVE_TEXT="Сохранение конфигурации xfce"
               SAVE_MENU1="Автоматически запускаемые приложения"
               SAVE_MENU2="Все настройки xfconf 
(хоткеи, питание, панель, фм,
темы курсоров, окон, шрифтов и т.д.)"
               SAVE_MENU3="Настройки терминала"
               SAVE_MENU4="Настройки ярлыков панели"
               SAVE_MENU5="Настройки Thunar"
               SAVE_MENU6="Настройки conky"
               SAVE_MENU7="Настройки xscreensaver"
               SAVE_MENU8="Настройки dconf"
               SAVE_MENU9="Использование собственного списка"
               OK_SAVE="Настройки xfce сохранены в файл"
               OPEN_LABEL="Открытие архива настроек xfce"
               ERROR_FOUND_ARCHIVE="- отсутствует! Необходимо найти самостоятельно"
               ERROR_ARCHIVE="- файл не является архивным. 
Укажите корректный архив настроек!"
               ATTENTION="ВНИМАНИЕ!"
               COPY_TEXT="Будут скопированы файлы:"
               RESTART_TEXT="Для корректного копирования и применения настроек, необходимо:
- остановка xfce4-panel
- перезапуск Xfce.

Сохраните открытые документы!!!
     
Применить настройки и перезапустить Xfce?"
               BACKUP_TEXT="#Это список файлов которые будут скопированы при создании резервной копии
#Файлы должны находиться в домашней директории
#Пример формата записей:
#~/tmp
#/home/user/tmp
#\$HOME/tmp"
               ;;
            *) #all locales
               MAIN_LABEL="Save / restore settings Xfce"
               MAIN_TEXT="Select an action:"
               MENU1="Save settings xfce"
               MENU2="Open files saved settings xfce"
               MENU3="Apply setting type Gnome2 (Mate)"
               MENU4="Apply setting type Xfce"
               MENU5="Apply setting type Windows"
               MENU6="Apply setting type Default"
               SAVE_LABEL="Choosing to save the settings"
               SAVE_TEXT="Save Configuration xfce"
               SAVE_MENU1="Start automatically"
               SAVE_MENU2="All settings xfconf"
               SAVE_MENU3="Terminal settings"
               SAVE_MENU4="Settings shortcuts panel"
               SAVE_MENU5="Settings Thunar"
               SAVE_MENU6="Settings conky"
               SAVE_MENU7="Settings xscreensaver"
               SAVE_MENU8="Settings dconf"
               SAVE_MENU9="Use your own backup-list"
               OK_SAVE="Xfce settings saved in the file"
               OPEN_LABEL="Open archive settings xfce"
               ERROR_FOUND_ARCHIVE="- Missing! You need to find yourself"
               ERROR_ARCHIVE="- the file is not an archive. 
Please enter a valid archive settings!"
               ATTENTION="ATTENTION!"
               COPY_TEXT="Files will be copied:"
               RESTART_TEXT="To correctly copy and apply the settings, you must:
- stop xfce4-panel
- restart Xfce.

Save open documents !!!
     
Apply the settings and restart Xfce?"
               BACKUP_TEXT="#This is a list of files to be copied during backup
#The files must be in the home directory
#An example of the format of records:
#~/tmp
#/home/user/tmp
#\$HOME/tmp"
              ;;
esac  


#####################################################################
XfceRestart () #Функция применения настроек и перезапуска Xfce (демона lightdm)
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument xfcerestart error; exit 1
fi
FILE_OPEN=$1
$DIALOG --question --title="$ATTENTION" \
        --text="$RESTART_TEXT" 
     
if [ $? == 0 ]
 then
 # Применение настроек и перезапуск
 xfce4-panel -q
 #rm -r ~/.config/xfce4/xfconf/xfce-perchannel-xml
 #rm -r ~/.config/xfce4/panel
 
 #Распаковываются настройки из $FILE_OPEN !
 tar xvf $FILE_OPEN -C ~/
 gksudo service lightdm restart
  if [ $? != 0 ]
  then 
   # Ввод пароля отклонен, перезапуск отложен
   xfce4-panel
   exit 1
 fi
 else
 # Перезапуск Xfce отложен. Настройки не применены
 MainForm
fi
}
#####################################################################
BackupList ()
{
BACKUP_LIST=$FOLDER/backup-list.txt

if [ ! -f $BACKUP_LIST ] #Проверка существования backup-list.txt
 then echo "$BACKUP_TEXT" > $BACKUP_LIST
fi
# Редактирование $BACKUP_LIST
ORIG_LIST=$(cat "$BACKUP_LIST")
EDIT_LIST=$(echo -n "$ORIG_LIST" | zenity --text-info --editable --title="Edit $BACKUP_LIST" \
            --width=550 --height=500 ) 
if [ "$EDIT_LIST" != "" ]
 then echo -n "$EDIT_LIST" > $BACKUP_LIST
fi
CP_LIST=$(cat $BACKUP_LIST | sed "/#/d" | sed "s/\~\///g" | sed 's/\/home\/[^/]*\///g' | sed "s/\$HOME\///g")
echo -n "$CP_LIST" > $FOLDER/backup-list.tmp
echo " " >> $FOLDER/backup-list.tmp
cat $FOLDER/backup-list.tmp | while read file_name 
 do 
 if [ -f ~/$file_name ]
  then
   # $file_name - это файл
   DIR_WAY=$(dirname ~/$file_name | sed 's/\/home\/[^/]*\///g' )
   mkdir -p $FOLDER/tmp_folder/$DIR_WAY
   cp -R ~/$file_name $FOLDER/tmp_folder/$DIR_WAY
  else
   if [ -d ~/$file_name ]
   then
   # $file_name - это папка
   mkdir -p $FOLDER/tmp_folder/$file_name 
   cp -R ~/$file_name/* $FOLDER/tmp_folder/$file_name
   else echo Directory or file $file_name not found
   fi
 fi  
 done
rm $FOLDER/backup-list.tmp
}
#####################################################################cp -R "~/$file_name" $FOLDER/tmp_folder; 
Check () #Функция проверки архивов и предупреждения пользователя об изменениях
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument check error; exit 1
fi

if [ ! -f $1 ] #Проверка существования файла-архива
 then 
 $DIALOG --info --title="$ATTENTION" \
              --text="$1 $ERROR_FOUND_ARCHIVE"
 OpenSettings
fi

FILE_LIST=$(tar --list -f $1) #Формирование списка файлов в архиве
if [ $? != 0 ] #Если список файлов архива невозможно создать, значит указан неверный архив - находим верный.
  then
  $DIALOG --info --title="$ATTENTION" \
              --text="$1 $ERROR_ARCHIVE"
  OpenSettings
fi

echo -n "$FILE_LIST" | zenity --text-info --title="$ATTENTION $COPY_TEXT" \
--width=400 --height=300 

if [ $? != 0 ]
 then MainForm 
fi
}
#####################################################################
SaveSettings () #Функция сохранения настроек Xfce в архив
{
rm -r $FOLDER/tmp_folder
mkdir $FOLDER/tmp_folder

ANSWER=$($DIALOG --title="$SAVE_LABEL" --width=400 --height=300 --list --cancel-label="Back" --checklist --multiple \
--column="" --column="" --column="" \
FALSE "1" "$SAVE_MENU1" \
TRUE "2" "$SAVE_MENU2" \
FALSE "3" "$SAVE_MENU3" \
TRUE "4" "$SAVE_MENU4" \
FALSE "5" "$SAVE_MENU5" \
FALSE "6" "$SAVE_MENU6" \
FALSE "7" "$SAVE_MENU7" \
FALSE "8" "$SAVE_MENU8" \
FALSE "9" "$SAVE_MENU9" )

if [ $? != 0 ]
 then MainForm
fi 

for ((i=0;$i<${#ANSWER};i=i+2)) #Чтение из переменной ANSWER по 2 символа
do  
 case $(echo ${ANSWER:$i:2} | tr -d \|) in # Из прочитанных 2 символов переменной удаляется символ "|"
    1)  echo "Save autostart"
        mkdir -p $FOLDER/tmp_folder/.config/autostart
        cp ~/.config/autostart/* $FOLDER/tmp_folder/.config/autostart
        ;;
    2)  echo "Save all xfconf configuration"
        mkdir -p $FOLDER/tmp_folder/.config/xfce4/xfconf
        cp -R ~/.config/xfce4/xfconf/xfce-perchannel-xml $FOLDER/tmp_folder/.config/xfce4/xfconf
        ;;
    3)  echo "Save terminal configuration"
        mkdir -p $FOLDER/tmp_folder/.config/xfce4
        cp -R ~/.config/xfce4/terminal $FOLDER/tmp_folder/.config/xfce4
        ;;
    4)  echo "Save panel configuration"
        mkdir -p $FOLDER/tmp_folder/.config/xfce4
        cp -R ~/.config/xfce4/panel $FOLDER/tmp_folder/.config/xfce4
        ;;
    5)  echo "Save Thunar configuration"
        mkdir -p $FOLDER/tmp_folder/.config/Thunar
        cp -R ~/.config/Thunar $FOLDER/tmp_folder/.config/Thunar
        ;; 
    6)  echo "Save conky configuration"
        cp -R ~/.conky $FOLDER/tmp_folder/
        ;;   
    7)  echo "Save xscreensaver configuration"
        cp -R ~/.xscreensaver $FOLDER/tmp_folder/
        ;;
    8)  echo "Save dconf configuration"
        mkdir -p $FOLDER/tmp_folder/.config
        cp -R ~/.config/dconf $FOLDER/tmp_folder/.config
        ;; 
    9)  echo "Save from file-list"
        BackupList
        ;; 
    *)  echo oops! - $(echo ${ANSWER:$i:2} | tr -d \|) 
        exit 1
        ;;    
 esac
done 

# Создание архива *.tar.gz с настройками Xfce
FILE_SAVE=`$DIALOG  --file-selection --title="$SAVE_TEXT" --save --filename=$FOLDER/`
if [ $? == 0 ]
 then  
   cd $FOLDER/tmp_folder/
   tar czpvf $FILE_SAVE\.tar.gz ./
   rm -r $FOLDER/tmp_folder
   $DIALOG --info --title="$ATTENTION" \
              --text="$OK_SAVE $FILE_SAVE\.tar.gz"
   MainForm
 else 
   SaveSettings
fi
}
#####################################################################
OpenSettings () #Функция открытия архива настроек
{
if [ -z "$1" ] #Если не задан аргумент ф-ции (архив) - находим самостоятельно
then 
  FILE_OPEN=`$DIALOG  --file-selection --title="$OPEN_LABEL" --filename=$FOLDER/`
  if [ $? != 0 ]
   then MainForm
  fi
else 
  FILE_OPEN=$FOLDER/$1
fi
Check $FILE_OPEN
XfceRestart $FILE_OPEN
}
#####################################################################
MainForm () #Функция главного окна
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
    1)  echo "Save xfce configuration"
        SaveSettings
        ;;
    2)  echo "Open xfce configuration"
        OpenSettings
        ;;
    3)  echo "Open xfce configuration like Gmone2 (Mate)"
        OpenSettings gnome2.tar.gz
        ;;
    4)  echo "Open xfce configuration like XFCE"
        OpenSettings xfce.tar.gz
        ;;
    5)  echo "Open xfce configuration like Windows"
        OpenSettings windows.tar.gz
        ;;    
    6)  echo "Open xfce configuration Default"
        OpenSettings default.tar.gz
        ;;
   "")  MainForm 
        ;;   
    *)  echo oops! - $ANSWER
        exit 1
        ;;
 esac
else echo Exit; exit 0
fi
}
#####################################################################

MainForm

exit 0
