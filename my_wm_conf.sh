#!/bin/bash
#Скрипт выбора WM, управление compiz metacity xfwm4
#Xfce 4.10, 4.12
#author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=zenity #Установка типа графического диалогового окна

if [ ! -x "`which "$DIALOG"`" ] #Проверка наличия zenity
 then eсho "Not Install - $DIALOG!"
      exit 1
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Управление WM"
               MAIN_TEXT="Выберите действие:"
               MENU1="Включить эффекты compiz"
               MENU2="Включить metacity"
               MENU3="Включить xfwm4"
               MENU4="Настроить compiz"
               MENU5="Настроить окна metacity (compiz)"
               MENU6="Добавить compiz в автозапуск"
               MENU7="Добавить metacity в автозапуск"
               MENU8="Добавить xfwm4 в автозапуск"
               MENU9="Справка"
               ADDAUTOSTART="- добавлен в автозагрузку!"
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

if [[ $(dconf read /org/gnome/desktop/wm/preferences/button-layout) == '' ]]
 then dconf write /org/gnome/desktop/wm/preferences/button-layout "'menu:minimize,maximize,close'"
fi

gconftool-2 --set --type boolen /apps/gwd/use_metacity_theme True

dconf write /org/gnome/metacity/theme/type "'metacity'"
}
#####################################################################
Check () #Функция проверки ПО
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument check error; exit 1
fi

if [ ! -x "`which "$1"`" ] #Проверка наличия ПО
 then echo $1 - not found!
      $DIALOG --info --title="$ATTENTION" --text="$1 $CHECK_PO $1"
      MainForm
fi
}
#####################################################################
AddAutostart () #Функция добавления в автозагрузку
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument autostart error; exit 1
 else WM=$1
fi
Check $WM
echo Add $WM to autostart
xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command --force-array -t string -s $WM --create
#$DIALOG --info --title="$ATTENTION" --text="$WM_CELECT $ADDAUTOSTART"
}
#####################################################################
ThemeMetacity () #Выбор оформления окон для metacity и compiz
{
if [[ -d ~/.local/share/themes && ! -d ~/.themes ]]
  then ln -s ~/.local/share/themes ~/.themes
fi
if [[ -d ~/.themes && ! -d ~/.local/share/themes ]]
  then ln -s ~/.themes ~/.local/share/themes
fi

THEME_NOW=$(dconf read /org/gnome/desktop/wm/preferences/theme | sed "s/'//g" | sed "s|/|\\\/|g")
#echo Сейчас установлена тема - "$THEME_NOW"

THEME_LIST=$(find /usr/share/themes/ -name metacity-1 | sed "s/\/usr\/share\/themes\//FALSE /g" | sed "s/\/metacity-1//g")
if [[ -d ~/.local/share/themes ]]
  then THEME_LIST_HOME1=$(find ~/.local/share/themes -name metacity-1 | sed "s/\/home\/\(.*\)\/.local\/share\/themes\//FALSE /g" | sed "s/\/metacity-1//g" )
fi
if [[ -d ~/.themes ]]
  then THEME_LIST_HOME2=$(find ~/.themes -name metacity-1 | sed "s/\/home\/\(.*\)\/.themes\//FALSE /g" | sed "s/\/metacity-1//g")
fi
THEME_LIST=$(echo "$THEME_LIST"; echo "$THEME_LIST_HOME1"; echo "$THEME_LIST_HOME2")
THEME_LIST=$(echo "$THEME_LIST" | sort)
THEME_LIST=$(echo "$THEME_LIST" | sed "/^$/d" | sed "s/FALSE ${THEME_NOW}$/TRUE ${THEME_NOW}/g")
#echo -e "Общий список тем - $THEME_LIST"

THEME_METACITY=$(echo "$THEME_LIST" | sed "s/FALSE /FALSE\n/g" | sed "s/TRUE /TRUE\n/g" | $DIALOG --width=400 --height=300 --list --cancel-label="Back" --radiolist \
       --title="$THEME_LABEL" \
       --text="$THEME_TEXT" \
       --column="" --column="Name")
if [ $? == 0 ]
 then  #echo Выбрана тема - $THEME_METACITY
       dconf write /org/gnome/desktop/wm/preferences/theme "'$THEME_METACITY'"
       #gsettings set org.gnome.desktop.wm.preferences theme $THEME_METACITY  
       dconf write /org/gnome/metacity/theme/name "'$THEME_METACITY'"
       gconftool-2 --set --type string /apps/metacity/general/theme $THEME_METACITY
       gconftool-2 --set --type string /desktop/gnome/interface/gtk_theme $THEME_METACITY
       ThemeMetacity
 else  SetMetacity
fi
}
#####################################################################
SetMetacity () #Окно настройки metacity
{
ANSWER=$($DIALOG --width=400 --height=300 --list --cancel-label="Back" --title="$META_LABEL" \
      --text="$META_TEXT" \
      --column="" --column="" \
        1 "$MENU_META1"\
        2 "$MENU_META2"\
        3 "$MENU_META3"\
        4 "$MENU_META4"\
        5 "$MENU_META5"\
        6 "$MENU_META6")
if [ $? == 0 ]
then
 case $ANSWER in
    1)  echo "Select Theme"
        ThemeMetacity
        ;;
    2)  echo "Button ->"
        dconf write /org/gnome/desktop/wm/preferences/button-layout "'menu:minimize,maximize,close'"
        gconftool-2 --set --type string /apps/metacity/general/button_layout "menu:minimize,maximize,close"
        SetMetacity
        ;;
    3)  echo "Button <-"
        dconf write /org/gnome/desktop/wm/preferences/button-layout "'close,maximize,minimize:menu'"
        gconftool-2 --set --type string /apps/metacity/general/button_layout "close,maximize,minimize:menu"
        SetMetacity
        ;;
    4)  echo "Settings dconf"
        dconf-editor
        ;;
    5)  echo "Settings gconf"
        gconf-editor
        ;;  
    6)  echo "Set font xfwm4"
        if [[ -f $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml ]]
         then THEME_FONT=$(grep -i "title_font" $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/<property name="title_font" type="string" value="//g' | sed 's/"\/>//g')
              gconftool-2 --set --type string /apps/metacity/general/titlebar_font "$THEME_FONT"
              dconf write /org/gnome/desktop/wm/preferences/titlebar-uses-system-font "false"
              dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'$THEME_FONT'"
        fi 
        SetMetacity
        ;; 
 esac
else MainForm
fi
}
#####################################################################
CheckState () #Проверяет какой WM запущен и какой добавлен в автозагрузку
{
STATE_COMPIZ=''
STATE_METACITY=''
STATE_XFWM4=''
AUTO_COMPIZ=''
AUTO_METACITY=''
AUTO_XFWM4=''
NUMBER_WORKSPACE=''

if pidof compiz > /dev/null; then 
      STATE_COMPIZ="- ON"
      if [ -f "$HOME/.config/compiz/compizconfig/config" ]; then
         profile=$(cat $HOME/.config/compiz/compizconfig/config | grep profile | awk -F= '{print $2}'| sed "s/ //g")
         if [[ $profile = '' ]]; then profile='Default'; fi
         s0_hsize=$(cat $HOME/.config/compiz/compizconfig/$profile.ini | grep s0_hsize | awk -F= '{print $2}'| sed "s/ //g")
         s0_vsize=$(cat $HOME/.config/compiz/compizconfig/$profile.ini | grep s0_vsize | awk -F= '{print $2}'| sed "s/ //g")
      fi 
      if [ -f "$HOME/.config/compiz-1/compizconfig/config" ]; then
         profile=$(cat $HOME/.config/compiz-1/compizconfig/config | grep profile | awk -F= '{print $2}'| sed "s/ //g")
         if [[ $profile = '' ]]; then profile='Default'; fi
         s0_hsize=$(cat $HOME/.config/compiz-1/compizconfig/$profile.ini | grep s0_hsize | awk -F= '{print $2}'| sed "s/ //g")
         s0_vsize=$(cat $HOME/.config/compiz-1/compizconfig/$profile.ini | grep s0_vsize | awk -F= '{print $2}'| sed "s/ //g")
      fi 
      if [[ $s0_hsize = '' ]]; then s0_hsize=2; fi
      if [[ $s0_vsize = '' ]]; then s0_vsize=1; fi

      let NUMBER_WORKSPACE=$s0_hsize*$s0_vsize
fi

if pidof metacity > /dev/null
 then STATE_METACITY="- ON"
      NUMBER_WORKSPACE=`dconf read /org/gnome/desktop/wm/preferences/num-workspaces`
fi

if pidof xfwm4 > /dev/null
 then STATE_XFWM4="- ON"
      NUMBER_WORKSPACE=`xfconf-query -c xfwm4 -p /general/workspace_count`
fi

WM_CHOSE=`xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command`
case $WM_CHOSE in
 *compiz*) AUTO_COMPIZ="- ON";;
 *metacity*) AUTO_METACITY="- ON";;
 *xfwm4*) AUTO_XFWM4="- ON";;
esac
}
#####################################################################
StartWm () #Запуск WM
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument autostart error; exit 1
 else WM=$1
fi
Check $WM
CheckState
echo Run $WM
case $WM in
 compiz)   sed -i "/^s0_hsize/d" $HOME/.config/compiz/compizconfig/$profile.ini
           sed -i "/^s0_vsize/d" $HOME/.config/compiz/compizconfig/$profile.ini
           sed -i "s|\[core\]|\[core\]\ns0_hsize=${NUMBER_WORKSPACE}\ns0_vsize=1|g" $HOME/.config/compiz/compizconfig/$profile.ini
        
           sed -i "/^s0_hsize/d" $HOME/.config/compiz-1/compizconfig/$profile.ini
           sed -i "/^s0_vsize/d" $HOME/.config/compiz-1/compizconfig/$profile.ini
           sed -i "s|\[core\]|\[core\]\ns0_hsize=${NUMBER_WORKSPACE}\ns0_vsize=1|g" $HOME/.config/compiz-1/compizconfig/$profile.ini
           ;;
 metacity) dconf write /org/gnome/desktop/wm/preferences/num-workspaces $NUMBER_WORKSPACE 
           ;;
 xfwm4)    xfconf-query -c xfwm4 -p /general/workspace_count -s $NUMBER_WORKSPACE
           ;;
esac


$WM --replace &
xfce4-panel -r
sleep 1
#notify-send -i dialog-information $WM
}
#####################################################################
MainForm () #Функция главного окна
{
CheckState
ANSWER=$($DIALOG --width=400 --height=300 --list --cancel-label="Exit" --title="$MAIN_LABEL" \
      --text="$MAIN_TEXT" \
      --column="" --column="" \
        1 "$MENU1 $STATE_COMPIZ"\
        2 "$MENU2 $STATE_METACITY"\
        3 "$MENU3 $STATE_XFWM4"\
        4 "$MENU4"\
        5 "$MENU5"\
        6 "$MENU6 $AUTO_COMPIZ"\
        7 "$MENU7 $AUTO_METACITY"\
        8 "$MENU8 $AUTO_XFWM4"\
        9 "$MENU9")
if [ $? == 0 ]
then
 case $ANSWER in
    1)  StartWm compiz;;
    2)  StartWm metacity;;
    3)  StartWm xfwm4;;
    4)  echo Settings compiz
        Check ccsm
        ccsm 1>/dev/null;;
    5)  echo Settings metacity
        Check dconf-editor
        #Check gconftool-2
        SetMetacity;;
    6)  AddAutostart compiz;;
    7)  AddAutostart metacity;;
    8)  AddAutostart xfwm4;;
    9)  echo -n "$HELP" | zenity --text-info --cancel-label="Back" --title="Help" \
        --width=400 --height=300;;
 esac
 MainForm
else echo Exit; exit 0
fi
}
#####################################################################
DefaultSettings
MainForm

exit 0
