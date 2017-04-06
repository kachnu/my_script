#!/bin/bash
#Скрипт выбора WM, управление compiz metacity xfwm4
#Xfce 4.10, 4.12
#author: kachnu
# email: ya.kachnu@yandex.ua

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

if [[ -d ~/.local/share/themes && ! -d ~/.themes ]]
  then ln -s ~/.local/share/themes ~/.themes
fi
if [[ -d ~/.themes && ! -d ~/.local/share/themes ]]
  then ln -s ~/.themes ~/.local/share/themes
fi

THEME_NOW=$(dconf read /org/gnome/desktop/wm/preferences/theme | sed "s/'//g" | sed "s|/|\\\/|g")

THEME_LIST=$(find /usr/share/themes/ -name metacity-1 | sed "s/\/usr\/share\/themes\//\!/g" | sed "s/\/metacity-1//g")
if [[ -d ~/.local/share/themes ]]
  then THEME_LIST_HOME1=$(find ~/.local/share/themes -name metacity-1 | sed "s/\/home\/\(.*\)\/.local\/share\/themes\/\!/g" | sed "s/\/metacity-1//g" )
fi
if [[ -d ~/.themes ]]
  then THEME_LIST_HOME2=$(find ~/.themes -name metacity-1 | sed "s/\/home\/\(.*\)\/.themes\/\!/g" | sed "s/\/metacity-1//g")
fi

THEME_LIST=$(echo "$THEME_LIST"; echo "$THEME_LIST_HOME1"; echo "$THEME_LIST_HOME2")
THEME_LIST=$(echo "$THEME_LIST" | sort | sed "/^$/d")
THEME_LIST=$THEME_NOW"!"$(echo $THEME_LIST | sed 's/ \!/\!/g' | sed 's/^\!//g')

BUTTON_R="Right"
BUTTON_L="Left"
if [[ `dconf read /org/gnome/desktop/wm/preferences/button-layout | grep \'close` ]]; then
     BUTTON=$BUTTON_L
     BUTTON_LIST=$BUTTON_L'!'$BUTTON_R
else BUTTON=$BUTTON_R
     BUTTON_LIST=$BUTTON_R'!'$BUTTON_L
fi
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
   then echo Argument autostart error; exit 1
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
if [ -z "$1" ]
   then echo Argument autostart error; exit 1
   else THEME=$1
fi
dconf write /org/gnome/desktop/wm/preferences/theme "'$THEME'"
dconf write /org/gnome/metacity/theme/name "'$THEME'"
gconftool-2 --set --type string /apps/metacity/general/theme $THEME
gconftool-2 --set --type string /desktop/gnome/interface/gtk_theme $THEME
notify-send -i dialog-information "$THEME" "theme activated"
}
########################################################################
SetButton ()
{
if [ -z "$1" ]
   then echo Argument autostart error; exit 1
   else BUTTON=$1
fi

case $BUTTON in
     $BUTTON_R) dconf write /org/gnome/desktop/wm/preferences/button-layout "'menu:minimize,maximize,close'"
                  gconftool-2 --set --type string /apps/metacity/general/button_layout "menu:minimize,maximize,close" ;;
     $BUTTON_L) dconf write /org/gnome/desktop/wm/preferences/button-layout "'close,maximize,minimize:menu'"
                  gconftool-2 --set --type string /apps/metacity/general/button_layout "close,maximize,minimize:menu";;
      *) echo ---"$BUTTON"----;;
esac
notify-send -i dialog-information "$BUTTON" "button activated"
}
########################################################################
MainForm ()
{
CheckState

SETTINGS=`$DIALOG --window-icon=preferences-system-windows --center --title="Manager WM" \
--form --separator="," \
--field=" Run WM::CB" "$WM_RUN_LIST" \
--field=" Autorun WM::CB" "$WM_AUTO_LIST" \
--field=" Theme window::CB" "$THEME_LIST" \
--field=" Button window::CB" "$BUTTON_LIST" \
--field=" Settings compiz:BTN" ccsm`

if [ $? != 0 ]; then exit; fi

NEW_WM_RUN=`echo $SETTINGS | awk -F',' '{print $1}'`
NEW_WM_AUTO=`echo $SETTINGS | awk -F',' '{print $2}'`
NEW_THEME=`echo $SETTINGS | awk -F',' '{print $3}'`
NEW_BUTTON=`echo $SETTINGS | awk -F',' '{print $4}'`

if [ "$NEW_WM_RUN" != "$WM_RUN" ]; then StartWm $NEW_WM_RUN "$WM_RUN"; fi
if [ "$NEW_WM_AUTO" != "$WM_AUTO" ]; then AddAutostart "$NEW_WM_AUTO"; fi
if [ "$NEW_THEME" != "$THEME_NOW" ]; then SetTheme "$NEW_THEME"; fi
if [ "$NEW_BUTTON" != "$BUTTON" ]; then SetButton "$NEW_BUTTON"; fi

MainForm
}
########################################################################
DefaultSettings

MainForm

exit 0
