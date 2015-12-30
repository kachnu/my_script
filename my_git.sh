#!/bin/bash
#Скрипт git
#author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=zenity #Установка типа графического диалогового окна

if [ ! -x "`which "$DIALOG"`" ] #Проверка наличия zenity
 then eсho "Not Install - $DIALOG!"
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="GIT"
               MAIN_TEXT="Выберите действие:"
               MENU1="Создать_репозиторий_(git_init)"
               MENU2="Клонировать_репозиторий_(git_clone)"
               MENU3="Добавить файл в репозирорий (git add)"
               MENU4="Создать снимок репозитория (git commit)"
               MENU5="Отправить в сетевое хранилище (git push)"
               MENU6="Статистика"
               MENU7=""
               MENU8="Настройки"
               MENU9="Справка"
               ATTENTION="ВНИМАНИЕ!"
               META_LABEL="Настройка окон metacity (compiz)"
               META_TEXT=$MAIN_TEXT
               MENU_META1="Выбор темы оформления окон"
               MENU_META2="Кнопки управления окном справа"
               MENU_META3="Кнопки управления окном слева"
               MENU_META4="Тонкая настройка dconf"
               MENU_META5="Тонкая настройка gconf"
               MENU_META6="Установить шрифт заголовка как в xfwm4"
               THEME_LABEL="Список тем"
               THEME_TEXT="Выберите тему:"
               CHECK_PO="- не найдено!
Установите пакеты для работы -"
               CHECK_NAME_TEXT="Были найдены папки (темы) название, которых содержат ПРОБЕЛЫ.
Наличие пробелов в названии, может повлиять на правильность формирования списка тем.

Вы согласны переименовать папки?"
               HELP="Данный скрипт позволяет управлять оконными менеджерами (WM)

В системе 3 оконных менеджера:
1) xfwm4 - стандартный WM для Xfce
2) metacity - оконный менеджер среды GNOME
3) compiz - композитный менеджер окон для X Window System

Одновременно в системе работает только один WM.

xfwm4 настраивается стандартными инструментами Xfce
Настройки хранятся в домашней папке ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml

metacity настраивается с помощью утилиты dconf-editor
compiz настраивается с помощью утилиты ccsm, а само окно к кнопками развернуть, свернуть и т.д. - с помощью dconf-editor (gconf-editor)
Настройки metacity и compiz хранятся в ~/.config/dconf/user
При работе metacity или compiz инструменты настройки xfwm4 НЕДОСТУПНЫ.
Темы окон metacity (compiz) хранятся в:
/usr/share/themes/ -глобальные темы
~/.local/share/themes - локальные темы, доступные только пользователю
Одним из условий правильного формирования списка тем является отсутствие ПРОБЕЛОВ в названии папки-темы."
               ;;
            *) #All locales
               MAIN_LABEL="Manager WM"
               MAIN_TEXT="Select an action:"
               MENU1="Run compiz effects"
               MENU2="Run metacity"
               MENU3="Run xfwm4"
               MENU4="Settings compiz"
               MENU5="Settings windows metacity (compiz)"
               MENU6="Add compiz to autostart"
               MENU7="Add metacity to autostart"
               MENU8="Add в to autostart"
               MENU9="Help"
               ADDAUTOSTART="- add to autostart!"
               ATTENTION="ATTENTION!"
               META_LABEL="Configuring windows metacity (compiz)"
               META_TEXT=$MAIN_TEXT
               MENU_META1="Choosing themes windows"
               MENU_META2="Control buttons on the right"
               MENU_META3="Control buttons on the left "
               MENU_META4="Start dconf"
               MENU_META5="Start gconf"
               MENU_META6="Set font xfwm4"
               THEME_LABEL="Themes list"
               THEME_TEXT="Select theme:"
               CHECK_PO="- not found!
Install packages for -"
               CHECK_NAME_TEXT="Were found folder name that contains spaces.
The presence of spaces in the title, could affect the correctness of the list.

You agree to rename a folder?"
               HELP="This script allows you to control window managers (WM)

The system 3 window manager :
1) xfwm4 - WM standard for Xfce
2) metacity - the GNOME window manager
3) compiz - composite window manager for the X Window System

At the same time the system is only one WM.

xfwm4 adjusted standard tools Xfce
The settings are stored in your home folder ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml

metacity configured using the utility dconf-editor
compiz is configured using a utility ccsm

When using metacity or compiz configuration tools xfwm4 unavailable.
Topics windows metacity (compiz) is stored in:
/usr/share/themes/ -global themes
~/.local/share/themes - local themes
One of the conditions for the proper formation of the list is the lack of spaces in the folder theme."
               ;;
esac


CONFIG_FILE=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
if [ -f $CONFIG_FILE ] #проверяем существование файла xfce4-session.xml, если не существует - создаем новый
 then sed -i 's/<property name="Client0_Command" type="empty"\/>/<property name="Client0_Command" type="array"> <value type="string" value="xfwm4"\/> <\/property>/g' $CONFIG_FILE
 else cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml $CONFIG_FILE
fi

#####################################################################
Help () #Помощь
{
echo -n "$HELP" | zenity --text-info --cancel-label="Back" --title="Help" \
 --width=400 --height=300
}
#####################################################################
DefaultSettings ()
{
if [[ $(dconf read /org/gnome/desktop/wm/preferences/theme | sed "s/'//g" | sed "s|/|\\\/|g" ) == '' ]]
 then dconf write /org/gnome/desktop/wm/preferences/theme "'Default'"
fi
if [[ $(gconftool-2 --get /apps/metacity/general/theme ) == '' ]]
 then gconftool-2 --set --type string /apps/metacity/general/theme  "Default"
fi
if [[ $(gconftool-2 --get /apps/metacity/general/button_layout ) == '' ]]
 then gconftool-2 --set --type string /apps/metacity/general/button_layout "menu:minimize,maximize,close"
fi
if [[ $(gconftool-2 --get /apps/metacity/general/titlebar_font ) == '' ]]
 then gconftool-2 --set --type string /apps/metacity/general/titlebar_font "Sans Bold 9"
fi	
if [[ -x /usr/bin/gtk-window-decorator ]]
then gconftool-2 --set --type string /apps/compiz/plugins/decoration/allscreens/options/command "/usr/bin/gtk-window-decorator --replace"
fi
}
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

CheckState ()
{
STATE_COMPIZ=''
STATE_METACITY=''
STATE_XFWM4=''
AUTO_COMPIZ=''
AUTO_METACITY=''
AUTO_XFWM4=''

if pidof compiz > /dev/null
 then STATE_COMPIZ="- ON"
fi

if pidof metacity > /dev/null
 then STATE_METACITY="- ON"
fi

if pidof xfwm4 > /dev/null
 then STATE_XFWM4="- ON"
fi	

if [[ $(cat "$CONFIG_FILE" | grep compiz) != '' ]]
 then AUTO_COMPIZ="- ON"
fi

if [[ $(cat "$CONFIG_FILE" | grep metacity) != '' ]]
 then AUTO_METACITY="- ON"
fi

if [[ $(cat "$CONFIG_FILE" | grep xfwm4) != '' ]]
 then AUTO_XFWM4="- ON"
fi
}
#####################################################################
MainForm () #Функция главного окна
{
Check git	

MENU_ALL=''
for i in 1 2 3 4 5 6 7 8 9; do
 echo $i
 SUB_MENU=$(eval echo $(echo "\$MENU$i"))
 echo $SUB_MENU
 if [[ "$SUB_MENU" != '' ]]
   then
   #MENU_ALL=$( echo "$MENU_ALL$SUB_MENU ")
   MENU_ALL=$( echo "$MENU_ALL$(echo $(echo "\$MENU$i"),) ")
 fi 
done
echo -e $MENU_ALL   
ANSWER=$($DIALOG --width=400 --height=300 --list --cancel-label="Exit" --title="$MAIN_LABEL" \
      --text="$MAIN_TEXT" \
      --column="" \
      $MENU_ALL)
if [ $? == 0 ]
then
 case $ANSWER in
    "$MENU1" ) # Run compiz
        WM=compiz
        echo Run $WM
        Check $WM
        $WM --replace &
        xfce4-panel -r
        sleep 1
        MainForm
        ;;
    "$MENU2" ) # Run metacity
        WM=metacity
        echo Run $WM
        Check $WM
        $WM --replace &
        xfce4-panel -r
        sleep 1
        MainForm
        ;;
    "$MENU3") # Run xfwm4
        WM=xfwm4
        echo Run $WM
        Check $WM                        
        $WM --replace &
        xfce4-panel -r
        sleep 1
        MainForm
        ;;
    "$MENU4" ) # Settings compiz
        echo Settings compiz
        Check ccsm
        ccsm
        MainForm
        ;;
    "$MENU5" ) # Settings metacity
        echo Settings metacity
        Check dconf-editor
        #Check gconftool-2
        CheckNameThemes
        SetMetacity
        ;;
    "$MENU6" ) # Add to autostart compiz
        WM=compiz
        echo Add $WM to autostart
        Check $WM
        AddAutostart $WM
        MainForm
        ;;
    "$MENU7" ) # Add to autostart metacity
        WM=metacity
        echo Add $WM to autostart
        Check $WM
        AddAutostart $WM
        MainForm
        ;;
    "$MENU8" ) # Add to autostart xfwm4
        WM=xfwm4
        echo Add $WM to autostart
        Check $WM
        AddAutostart $WM
        MainForm
        ;;
    "$MENU9" ) # Help
        Help
        MainForm
        ;;
    *)  echo "ooops!- $ANSWER"
        exit 1
        ;;
 esac
else echo Exit; exit 0
fi
}
#####################################################################
DefaultSettings
MainForm

exit 0
