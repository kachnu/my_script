#!/bin/bash
#Скрипт выбора WM, управление compiz metacity xfwm4
#Xfce 4.10
#author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=zenity #Установка типа графического диалогового окна

if [ ! -x "`which "$DIALOG"`" ] #Проверка наличия zenity
 then eсho "Not Install - $DIALOG!"
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
#####################################################################
CheckNameThemes () #Функция проверки пробелов в именах тем
{
THEME_LIST=$(find /usr/share/themes/ -name metacity-1 | sed "s/\/metacity-1/\//g" | grep ' ')
THEME_LIST_HOME=$(find ~/.local/share/themes -name metacity-1 | sed "s/\/metacity-1/\//g" | grep ' ')
if [[ "$THEME_LIST" != '' || "$THEME_LIST_HOME" != '' ]]
 then
 echo Themes metacity problem "$THEME_LIST" "$THEME_LIST_HOME"
 NEW_NAME_LIST=$(echo "$THEME_LIST" | sed "s/ /_/g" )
 NEW_NAME_LIST_HOME=$(echo "$THEME_LIST_HOME" | sed "s/ /_/g" )
 $DIALOG --question --title="$ATTENTION" \
        --text="$CHECK_NAME_TEXT
from
$THEME_LIST $THEME_LIST_HOME
to
$NEW_NAME_LIST $NEW_NAME_LIST_HOME
"
if [ $? == 0 ]
 then
  if [[ "$THEME_LIST" != '' ]]
  then
   echo "$THEME_LIST" | while read line
   do
   gksudo mv "$line" $(echo "$line" | sed "s/ /_/g")
   done
  fi
  if [[ "$THEME_LIST_HOME" != '' ]]
  then
   echo "$THEME_LIST_HOME" | while read line
   do
   mv "$line" $(echo "$line" | sed "s/ /_/g")
   done
  fi
 fi
else
  echo Themes metacity - OK
fi
}
#####################################################################
AddAutostart () #Функция добавления в автозагрузку
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument autostart error; exit 1
fi
sed -i "s/${1}/${1}/g" $CONFIG_FILE
sed -i "s/compiz/${1}/g" $CONFIG_FILE
sed -i "s/metacity/${1}/g" $CONFIG_FILE
sed -i "s/xfwm4/${1}/g" $CONFIG_FILE
sed -i "s|<value type=\"string\" value=\"ccp\"/>||g" $CONFIG_FILE
if [[ $1 = "compiz" ]]
 then
   if [[ $(compiz --version) = "compiz 0.8.4" ]]
   then sed -i "s|value=\"compiz\"/>|value=\"compiz\"/><value type=\"string\" value=\"ccp\"/>|g" $CONFIG_FILE
 fi
fi
$DIALOG --info --title="$ATTENTION" \
              --text="$1 $ADDAUTOSTART"
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
THEME_NOW=$(dconf read /org/gnome/desktop/wm/preferences/theme | sed "s/'//g" | sed "s|/|\\\/|g" )
#echo Сейчас установлена тема - $THEME_NOW
THEME_LIST=$(find /usr/share/themes/ -name metacity-1 | sed "s/\/usr\/share\/themes\//FALSE /g" | sed "s/\/metacity-1//g")
if [[ -d ~/.local/share/themes ]]
 then THEME_LIST_HOME1=$(find ~/.local/share/themes -name metacity-1 | sed "s| |\\\ |g" | sed "s/\/home\/\(.*\)\/.local\/share\/themes\//FALSE /g" | sed "s/\/metacity-1//g" )
fi
if [[ -d ~/.themes ]]
 then THEME_LIST_HOME2=$(find ~/.themes -name metacity-1 | sed "s| |\\\ |g" | sed "s/\/home\/\(.*\)\/.local\/share\/themes\//FALSE /g" | sed "s/\/metacity-1//g" )
fi
THEME_LIST=$(echo $THEME_LIST; echo $THEME_LIST_HOME1; echo $THEME_LIST_HOME2)
THEME_LIST=$(echo $THEME_LIST | sed "s/FALSE ${THEME_NOW} /TRUE ${THEME_NOW} /g")
#echo Общий список тем - $THEME_LIST
THEME_METACITY=$($DIALOG --width=400 --height=300 --list --cancel-label="Back" --radiolist \
       --title="$THEME_LABEL" \
       --text="$THEME_TEXT" \
       --column="" --column="Name" \
	   $THEME_LIST )
if [ $? == 0 ]
 then
  #echo Выбрана тема - $THEME_METACITY
  dconf write /org/gnome/desktop/wm/preferences/theme "'$THEME_METACITY'"
  #gsettings set org.gnome.desktop.wm.preferences theme $THEME_METACITY
  gconftool-2 --set --type string /apps/metacity/general/theme $THEME_METACITY
  gconftool-2 --set --type string /desktop/gnome/interface/gtk_theme $THEME_METACITY
  ThemeMetacity
 else SetMetacity
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
    *)  echo "ooops! - $ANSWER"
        exit 1
        ;;
 esac
else MainForm
fi
}
#####################################################################
SyncWP ()
{
 if [[ $STATE_COMPIZ != '' ]]
         then 
             FILE_CONF_COMPIZ=$(cat ~/.config/compiz/compizconfig/config | grep profile | sed "s/profile = //")
             if [[ $FILE_CONF_COMPIZ == '' ]]
             then FILE_CONF_COMPIZ="Default"
             fi
             WP_VERT=$(cat ~/.config/compiz/compizconfig/$FILE_CONF_COMPIZ.ini | grep s0_vsize | sed "s/s0_vsize =//" | sed "s/ //g")
             if [[ $WP_VERT == '' ]]
              then WP_VERT='1'
             fi
             WP_HOR=$(cat ~/.config/compiz/compizconfig/$FILE_CONF_COMPIZ.ini | grep s0_hsize | sed "s/s0_hsize =//" | sed "s/ //g")
             if [[ $WP_HOR == '' ]]
              then WP_HOR='1'
             fi             
             WP_ALL=$[$WP_VERT*$WP_HOR]
             echo "*****************
             RABSTOLOV - $WP_ALL"
             WP_DEF=$(cat ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml | grep workspace_count)
             WP_NEW="    <property name=\"workspace_count\" type=\"int\" value=\"$WP_ALL\"/>"
             sed -i "s|${WP_DEF}|${WP_NEW}|g" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
fi	
}
#####################################################################
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
    1) # Run compiz
        WM=compiz
        echo Run $WM
        Check $WM
        $WM --replace &
        xfce4-panel -r
        sleep 1
        MainForm
        ;;
    2) # Run metacity
        WM=metacity
        echo Run $WM
        Check $WM
        $WM --replace &
        xfce4-panel -r
        sleep 1
        MainForm
        ;;
    3) # Run xfwm4
        WM=xfwm4
        echo Run $WM
        Check $WM                        
        $WM --replace &
        xfce4-panel -r
        sleep 1
        MainForm
        ;;
    4) # Settings compiz
        echo Settings compiz
        Check ccsm
        ccsm
        MainForm
        ;;
    5) # Settings metacity
        echo Settings metacity
        Check dconf-editor
        #Check gconftool-2
        CheckNameThemes
        SetMetacity
        ;;
    6) # Add to autostart compiz
        WM=compiz
        echo Add $WM to autostart
        Check $WM
        AddAutostart $WM
        MainForm
        ;;
    7) # Add to autostart metacity
        WM=metacity
        echo Add $WM to autostart
        Check $WM
        AddAutostart $WM
        MainForm
        ;;
    8) # Add to autostart xfwm4
        WM=xfwm4
        echo Add $WM to autostart
        Check $WM
        AddAutostart $WM
        MainForm
        ;;
    9) # Help
        Help
        MainForm
        ;;
   "")  MainForm 
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
