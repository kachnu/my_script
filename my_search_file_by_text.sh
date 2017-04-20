#!/bin/bash
#Скрипт по поиску ФАЙЛОВ содержащих ФРАЗУ, т.е. мы задает фразу и скрипт выводит список файлов которые содержат заданную фразу.
#author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=yad
if ! [[ `which $DIALOG` ]]
   then DIALOG=zenity
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Поиск ФАЙЛА по ФРАЗЕ"
               MAIN_TEXT="Будем искать в"
               MENU1="Начать поиск"
               MENU2="Задать место поиска"
               MENU3="Справка"
               ATTENTION="ВНИМАНИЕ!"
               SEARCH_TEXT="Введите фразу для поиска"
               DIRECTORY_TEXT="Место поиска"
               ERROR_DIR="Укажите МЕСТО поиска"
               ERROR_WORD="Укажите ФРАЗУ для поиска"
               HELP="НАИМЕНОВАНИЕ
	$0 - это скрипт по поиску ФАЙЛОВ содержащих ФРАЗУ, т.е. мы задает фразу и скрипт выводит список файлов которые содержат занную фразу.

СИНТАКСИС
	$0 [КЛЮЧ] [ФРАЗА] [ПУТЬ]

КЛЮЧИ
	-h, --help - выводит данное сообщение
	--gui - запуск скрипта в графическом диалоговом окне

РЕЗУЛЬТАТ РАБОТЫ СКРИПТА
	результатом является список файлов содержащих заданную фразу
	формат результата - <адрес файла>:<номер строки в файле>:<содержание строки>

ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ СКРИПТА
	$0 \"КОРОВА МИЛКА\" /home/user - выведет список файлов в /home/user содержащих фразу КОРОВА МИЛКА.
Если фраза содержит пробелы, необходимо брать её в двойные ковычки \" \"
	$0 --gui - откроет диалоговое окно поиска
	$0 -h - выводит справку"
               ;;
            *) #All locales
               MAIN_LABEL="FILE Search for the phrase"
               MAIN_TEXT="We will seek to"
               MENU1="Start Search"
               MENU2="Select the search way"
               MENU3="Help"
               ATTENTION="ATTENTION!"
               SEARCH_TEXT="Enter search phrase"
               DIRECTORY_TEXT="Location search"
               ERROR_DIR="Specify where find"
               ERROR_WORD="Enter search phrase"
               HELP="NAME
	$0 - is a script for the Search for files containing the phrase. We asked the phrase and the script displays a list of files that contain the phrase.
SYNOPSIS
	$0 [KEY] [PHRASE] [WAY]

KEY
	-h, --help - displays this message
	--gui - Running the script in a graphical dialog box

Results of the script
	Еhe result is a list of files containing the specified phrase
	The result format - <address file>:<the line number in the file>:<line content>

EXAMPLES OF SCRIPT
	$0 \"Milka COW\" /home/user - will list the files in home/user containing the phrase Milka COW.
If the phrase contains spaces , you must take it in double quotes \" \"
	$0 --gui - Open the search dialog
	$0 -h - displays help"
               ;;
esac

###############################################
Help ()
{
echo "$HELP"
}
###############################################
GuiForm ()
{
if [ $DIALOG  == "zenity" ]; then
    DIRECTORY="$1"
    ANSWER=$($DIALOG --width=400 --height=300 --list --cancel-label="Exit" --title="$MAIN_LABEL" \
          --text="$MAIN_TEXT $DIRECTORY" \
          --column="" --column="" \
            1 "$MENU1"\
            2 "$MENU2"\
            3 "$MENU3" )
    if [ $? == 0 ]
    then
      case $ANSWER in
        1*) SEARCH_WORD=`$DIALOG --entry --cancel-label="Back" --title="Seach" --text="$SEARCH_TEXT" --entry-text="$SEARCH_WORD" `
           if [ $? != 0 ]
           then GuiForm "$DIRECTORY"
           fi
           if [[ $DIRECTORY == '' ]]
           then $DIALOG --info --title="$ATTENTION" --text="$ERROR_DIR"
                GuiForm "$DIRECTORY"
           fi
           if [[ $SEARCH_WORD == '' ]]
           then $DIALOG --info --title="$ATTENTION" --text="$ERROR_WORD"
                GuiForm "$DIRECTORY"
           fi
           grep -EHnr "$SEARCH_WORD" "$DIRECTORY" | $DIALOG --text-info --cancel-label="Back" --title="LIST" \
     --width=400 --height=300
           GuiForm "$DIRECTORY"
           ;;
        2*) DIRECTORY=`$DIALOG --file-selection --directory --title="$DIRECTORY_TEXT" --filename="$DIRECTORY"`
           GuiForm "$DIRECTORY"
           ;;
        3*) Help | $DIALOG --text-info --cancel-label="Back" --title="Help" --width=400 --height=300
           GuiForm "$DIRECTORY"
           ;;
        *) echo oops!-$ANSWER
           exit 1
           ;;
     esac
    else echo Exit ; exit 0
    fi
else
    SEARCH_WORD=`echo $* | awk -F',' '{print $1}'`
    DIRECTORY=`echo $* | awk -F',' '{print $2}'`
    INFO=`yad --width=300 --window-icon=gtk-find --title="$MAIN_LABEL" \
    --form --separator="," \
    --field="Text:" "$SEARCH_WORD" \
    --field="Folder::DIR" "$DIRECTORY"`
    if [ $? != 0 ]; then exit; fi
    SEARCH_WORD=`echo $INFO | awk -F',' '{print $1}'`
    DIRECTORY=`echo $INFO | awk -F',' '{print $2}'`
    grep -EHnr --color "$SEARCH_WORD" "$DIRECTORY" | $DIALOG --text-info --width=600 --height=300 \
    --window-icon=gtk-find --title="$MAIN_LABEL"
    GuiForm "$SEARCH_WORD"",""$DIRECTORY"
fi
}
###############################################
MainScript ()
{
case "$1" in
    -h|--help) Help
               exit 0
               ;;
        --gui|'') GuiForm "${2}"
               exit 0
               ;;
            *) SEARCH_WORD="$1"
               #echo "Будем искать фразу: $SEARCH_WORD"
               ;;
esac
DIRECTORY="${2}"
#echo "Будем искать в папке: $DIRECTORY"
grep -EHnr --color "$SEARCH_WORD" "$DIRECTORY"
}
###############################################
MainScript "$1" "${2}"

exit 0
