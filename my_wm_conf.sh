#!/bin/bash
#Скрипт выбора WM, управление compiz metacity xfwm4
#Xfce 4.10, 4.12
#author: kachnu
# email: ya.kachnu@gmail.com

DIALOG=yad

CHECK_PO_LIST="$DIALOG dconf gconftool-2 notify-send xfce4-panel xfconf-query"
for PO in $CHECK_PO_LIST; do
    if ! [[ `which $PO` ]]; then echo "Not found $PO"; exit 1; fi
done

CHECK_WM_LIST="compiz metacity xfwm4"
WM_LIST=""
for WM in $CHECK_WM_LIST; do
    if [[ `which  $WM` ]]; then WM_LIST=$WM_LIST' '$WM; fi
done

TEXT_WM="WM"
TEXT_AUTO="Autostart WM"
TEXT_THEME="Theme"
TEXT_BUTTON="Button window"
TEXT_SETTINGS="Settings"
BUTTON_R="Right"
BUTTON_L="Left"

########################################################################
DefaultSettings ()
{
#set window decor
dconf write /org/gnome/metacity/theme/type "'metacity'"
gconftool-2 --set --type boolen /apps/gwd/use_metacity_theme True
if [[ -x /usr/bin/gtk-window-decorator ]]
    then gconftool-2 --set --type string /apps/compiz/plugins/decoration/allscreens/options/command "/usr/bin/gtk-window-decorator --replace"
fi
#set Default theme matacity
DEFAULT_THEME="Default-4.10"
if [[ -d /usr/share/themes/$DEFAULT_THEME/metacity-1 ]]; then
    if [[ $(dconf read /org/gnome/desktop/wm/preferences/theme | sed "s/'//g" | sed "s|/|\\\/|g" ) == '' ]]
        then dconf write /org/gnome/desktop/wm/preferences/theme "'$DEFAULT_THEME'"
    fi
    if [[ $(dconf read /org/gnome/metacity/theme/name | sed "s/'//g" | sed "s|/|\\\/|g" ) == '' ]]
        then dconf write /org/gnome/metacity/theme/name "'$DEFAULT_THEME'"
    fi
    if [[ $(gconftool-2 --get /apps/metacity/general/theme ) == '' ]]
        then gconftool-2 --set --type string /apps/metacity/general/theme  "$DEFAULT_THEME"
    fi
fi
#set button-layout
if [[ $(gconftool-2 --get /apps/metacity/general/button_layout ) == '' ]]
    then gconftool-2 --set --type string /apps/metacity/general/button_layout "menu:minimize,maximize,close"
fi
if [[ $(dconf read /org/gnome/desktop/wm/preferences/button-layout) == '' ]]
    then dconf write /org/gnome/desktop/wm/preferences/button-layout "'menu:minimize,maximize,close'"
fi
#set font
if [[ $(gconftool-2 --get /apps/metacity/general/titlebar_font ) == '' ]]
    then gconftool-2 --set --type string /apps/metacity/general/titlebar_font "Sans Bold 9"
fi
#set link for themes
if [[ -d ~/.local/share/themes && ! -d ~/.themes ]]
    then ln -s ~/.local/share/themes ~/.themes
fi
if [[ -d ~/.themes && ! -d ~/.local/share/themes ]]
    then ln -s ~/.themes ~/.local/share/themes
fi
}
########################################################################
CheckState ()
{
WM_RUN=''
WM_NOT_RUN=''
for WM in $WM_LIST; do
  if [[ `pgrep -u $USER $WM` ]]; then WM_RUN=$WM
  else if [ -z $WM_NOT_RUN ]; then WM_NOT_RUN=$WM
       else WM_NOT_RUN=$WM_NOT_RUN'!'$WM
       fi
  fi
done
WM_RUN_LIST=$WM_RUN'!'$WM_NOT_RUN

WM_AUTO_INFO=`xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command | awk '{print $NF}'`
WM_NOT_AUTO=''
for WM in $WM_LIST; do
  if [[ `echo $WM_AUTO_INFO | grep $WM` ]]; then WM_AUTO=$WM
  else if [ -z $WM_NOT_AUTO ]; then WM_NOT_AUTO=$WM
          else WM_NOT_AUTO=$WM_NOT_AUTO'!'$WM
       fi
  fi
done
WM_AUTO_LIST=$WM_AUTO'!'$WM_NOT_AUTO

THEME_LIST=''
THEME_NOW=''
case $WM_RUN in
    compiz)
    WM_THEME="metacity"
    THEME_FOLDER="metacity-1"
    THEME_NOW=$(dconf read /org/gnome/desktop/wm/preferences/theme | sed "s/'//g" | sed "s|/|\\\/|g")
    if [[ `dconf read /org/gnome/desktop/wm/preferences/button-layout | grep \'close` ]]; then
         BUTTON=$BUTTON_L
         BUTTON_LIST=$BUTTON_L'!'$BUTTON_R
    else BUTTON=$BUTTON_R
         BUTTON_LIST=$BUTTON_R'!'$BUTTON_L
    fi
    TEXT_PROG="compiz"
    PROG="ccsm"
    ;;
    metacity)
    THEME_TYPE=$(dconf read /org/gnome/metacity/theme/type | sed "s/'//g" | sed "s|/|\\\/|g")
    if [ "$THEME_TYPE" = "gtk" ]; then
         echo "eba!shodelat?"
         WM_THEME=$THEME_TYPE
         THEME_FOLDER="gtk-3.0"
         THEME_NOW=$(dconf read /org/gnome/metacity/theme/name | sed "s/'//g" | sed "s|/|\\\/|g")
    else WM_THEME=$THEME_TYPE
         THEME_FOLDER="metacity-1"
         THEME_NOW=$(dconf read /org/gnome/desktop/wm/preferences/theme | sed "s/'//g" | sed "s|/|\\\/|g")
    fi
    if [[ `dconf read /org/gnome/desktop/wm/preferences/button-layout | grep \'close` ]]; then
         BUTTON=$BUTTON_L
         BUTTON_LIST=$BUTTON_L'!'$BUTTON_R
    else BUTTON=$BUTTON_R
         BUTTON_LIST=$BUTTON_R'!'$BUTTON_L
    fi
    TEXT_PROG="dconf"
    PROG="dconf-editor"
    ;;
    xfwm4)
    WM_THEME="xfwm4"
    THEME_FOLDER="xfwm4"
    THEME_NOW=$(xfconf-query -c xfwm4 -p /general/theme)
    if [[ `xfconf-query -c xfwm4 -p /general/button_layout | grep ^C` ]]; then
         BUTTON=$BUTTON_L
         BUTTON_LIST=$BUTTON_L'!'$BUTTON_R
    else BUTTON=$BUTTON_R
         BUTTON_LIST=$BUTTON_R'!'$BUTTON_L
    fi
    TEXT_PROG="xfwm4"
    PROG="xfwm4-settings"
    ;;
esac
THEME_LIST=$(find /usr/share/themes/ -name $THEME_FOLDER | sed "s/\/usr\/share\/themes\//\!/g" | sed "s/\/${THEME_FOLDER}//g")
if [[ -d ~/.local/share/themes ]]
    then THEME_LIST_HOME1=$(find ~/.local/share/themes -name ${THEME_FOLDER} | sed "s/\/home\/\(.*\)\/.local\/share\/themes\//\!/g" | sed "s/\/${THEME_FOLDER}//g")
fi
if [[ -d ~/.themes ]]
    then THEME_LIST_HOME2=$(find ~/.themes -name $THEME_FOLDER | sed "s/\/home\/\(.*\)\/.themes\//\!/g" | sed "s/\/${THEME_FOLDER}//g")
fi
THEME_LIST=$(echo "$THEME_LIST"; echo "$THEME_LIST_HOME1"; echo "$THEME_LIST_HOME2")
THEME_LIST=$(echo "$THEME_LIST" | sort | sed "/^$/d")
THEME_LIST=$THEME_NOW"!"$(echo $THEME_LIST | sed 's/ \!/\!/g' | sed 's/^\!//g')
}
########################################################################
AddAutostart ()
{
if [ -z "$1" ]
   then echo Argument autostart error; exit 1
   else WM=$1
fi
xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command --force-array -t string -s $WM --create
notify-send -i dialog-information "$WM" "add to autostart"
}
########################################################################
StartWm ()
{
if [ -z "$1" ]
   then echo Argument start wm error; exit 1
   else WM=$1
fi

if ! [ -z "$2" ]; then WM_RUN=$2
   NUMBER_WORKSPACE=''
   case $WM_RUN in
     compiz)   if [ -f "$HOME/.config/compiz/compizconfig/config" ]; then
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
               let NUMBER_WORKSPACE=$s0_hsize*$s0_vsize;;
     metacity) NUMBER_WORKSPACE=`dconf read /org/gnome/desktop/wm/preferences/num-workspaces`;;
     xfwm4)    NUMBER_WORKSPACE=`xfconf-query -c xfwm4 -p /general/workspace_count`;;
   esac

   case $WM in
     compiz)   if [ -f "$HOME/.config/compiz/compizconfig/config" ]; then
                  profile=$(cat $HOME/.config/compiz/compizconfig/config | grep profile | awk -F= '{print $2}'| sed "s/ //g")
                  if [[ $profile = '' ]]; then profile='Default'; fi
                  sed -i "/^s0_hsize/d" $HOME/.config/compiz/compizconfig/$profile.ini
                  sed -i "/^s0_vsize/d" $HOME/.config/compiz/compizconfig/$profile.ini
                  sed -i "s|\[core\]|\[core\]\ns0_hsize=${NUMBER_WORKSPACE}\ns0_vsize=1|g" $HOME/.config/compiz/compizconfig/$profile.ini
               fi
               if [ -f "$HOME/.config/compiz-1/compizconfig/config" ]; then
                  profile=$(cat $HOME/.config/compiz-1/compizconfig/config | grep profile | awk -F= '{print $2}'| sed "s/ //g")
                  if [[ $profile = '' ]]; then profile='Default'; fi
                  sed -i "/^s0_hsize/d" $HOME/.config/compiz-1/compizconfig/$profile.ini
                  sed -i "/^s0_vsize/d" $HOME/.config/compiz-1/compizconfig/$profile.ini
                  sed -i "s|\[core\]|\[core\]\ns0_hsize=${NUMBER_WORKSPACE}\ns0_vsize=1|g" $HOME/.config/compiz-1/compizconfig/$profile.ini
               fi;;
     metacity) dconf write /org/gnome/desktop/wm/preferences/num-workspaces $NUMBER_WORKSPACE;;
     xfwm4)    xfconf-query -c xfwm4 -p /general/workspace_count -s $NUMBER_WORKSPACE;;
   esac
fi

$WM --replace &
xfce4-panel -r
sleep 1
notify-send -i dialog-information "$WM" "started"
}
########################################################################
SetTheme ()
{
if [ -z "$1" ] || [ -z "$2" ]
   then echo Argument theme error; exit 1
   else THEME=$1; WM=$2
fi
case $WM in
    compiz|metacity)
    dconf write /org/gnome/desktop/wm/preferences/theme "'$THEME'"
    dconf write /org/gnome/metacity/theme/name "'$THEME'"
    gconftool-2 --set --type string /apps/metacity/general/theme $THEME
    gconftool-2 --set --type string /desktop/gnome/interface/gtk_theme $THEME
    ;;
    xfwm4) xfconf-query -c xfwm4 -p /general/theme -s "$THEME";;
esac
notify-send -i dialog-information "$THEME" "theme activated"
}
########################################################################
SetButton ()
{
if [ -z "$1" ]
   then echo Argument button error; exit 1
   else BUTTON=$1
fi

case $BUTTON in
     $BUTTON_R) xfconf-query -c xfwm4 -p /general/button_layout -s "O|SHMC"
                xfconf-query -c xsettings -p /Gtk/DecorationLayout -s "menu:minimize,maximize,close"
                dconf write /org/gnome/desktop/wm/preferences/button-layout "'menu:minimize,maximize,close'"
                gconftool-2 --set --type string /apps/metacity/general/button_layout "menu:minimize,maximize,close" ;;
     $BUTTON_L) xfconf-query -c xfwm4 -p /general/button_layout -s "CMH|SO"
                xfconf-query -c xsettings -p /Gtk/DecorationLayout -s "close,maximize,minimize:menu"
                dconf write /org/gnome/desktop/wm/preferences/button-layout "'close,maximize,minimize:menu'"
                gconftool-2 --set --type string /apps/metacity/general/button_layout "close,maximize,minimize:menu";;
      *) echo ---"$BUTTON"----;;
esac
notify-send -i dialog-information "$BUTTON" "button activated"
}
########################################################################
MainForm ()
{
CheckState

SETTINGS=`$DIALOG --window-icon=preferences-system-windows \
--center --title="Manager WM" \
--form --separator="," \
--field="$TEXT_WM:CB" "$WM_RUN_LIST" \
--field=":LBL" "" \
--field="$TEXT_AUTO:CB" "$WM_AUTO_LIST" \
--field="$TEXT_THEME $WM_THEME:CB" "$THEME_LIST" \
--field="$TEXT_BUTTON:CB" "$BUTTON_LIST" \
--field="$TEXT_SETTINGS $TEXT_PROG:FBTN" $PROG`

if [ $? != 0 ]; then exit; fi

#echo $SETTINGS

NEW_WM_RUN=`echo $SETTINGS | awk -F',' '{print $1}'`
NEW_WM_AUTO=`echo $SETTINGS | awk -F',' '{print $3}'`
NEW_THEME=`echo $SETTINGS | awk -F',' '{print $4}'`
NEW_BUTTON=`echo $SETTINGS | awk -F',' '{print $5}'`

if [ "$NEW_WM_RUN" != "$WM_RUN" ] && ! [[ `echo $SETTINGS | grep " "` ]]; then StartWm "$NEW_WM_RUN" "$WM_RUN"; fi
if [ "$NEW_WM_AUTO" != "$WM_AUTO" ]; then AddAutostart "$NEW_WM_AUTO"; fi
if [ "$NEW_THEME" != "$THEME_NOW" ] && [ "$NEW_WM_RUN" = "$WM_RUN" ] && [ "$NEW_BUTTON" != "(null)" ]; then SetTheme "$NEW_THEME" "$WM_RUN"; fi
if [ "$NEW_BUTTON" != "$BUTTON" ] && [ "$NEW_BUTTON" != "(null)" ]; then SetButton "$NEW_BUTTON" "$WM_RUN"; fi

MainForm
}
########################################################################
DefaultSettings

MainForm

exit 0
