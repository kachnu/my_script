#!/bin/bash
# Скрипт настройки VNC-сервера
# Xfce 4.10
# author: kachnu
# email: ya.kachnu@gmail.com

DIALOG=yad
if ! [[ `which $DIALOG` ]]
   then DIALOG=zenity
fi

case $LANG in # language selection
  uk*|ru*|be*) # UA RU BE locales
               MAIN_LABEL="Настройка удаленного рабочего стола VNC"
               MAIN_TEXT="Выберите действие:"
               
               VNC_INSTALL_VINO="Для работы необходимо установить vino.
Потребуется подключение к Интернет.

Вы хотите произвести установку данного ПО?"
               VNC_VIEW_DESKTOP="Позволить видеть рабочий стол (VNC-сервер)"
               VNC_MANAGE_DESKTOP="Позволить управлять рабочим столом"
               VNC_AUTORUN="Доступ к рабочему столу при загрузке (автозапуск)"
               VNC_PASSWORD="Требовать пароль"
               VNC_PROMPT="Требовать от Вас подтверждение на подключение"
               VNC_ICON="Значок в области уведомлений"
               VNC_PORT="Порт доступа"
               VNC_ENCRYPTION="Шифрование"
               VNC_ROUTE="Автоматически настраивать маршрутизатор"               
               VNC_HELP="Справка"
               
               VNC_ENTER_PASSWORD="Внимание! Cлово 'keyring' - не считается паролем, 
будет использован пароль в брелоке GNOME.
Пустой пароль = 'keyring'
Введите пароль для доступа к Вашему рабочему столу"
               VNC_ENTER_ICON="client - отображать иконку в трее, только при подключении к рабочему столу
never - никогда не отображать иконку
always - всегда отображать иконку"
               ATTENTION="ВНИМАНИЕ!"
               HELP="Данный скрипт позволяет настроить удаленный доступ к рабочему столу с использованием VNC"
               PORT_ALLARM="- уже используется!
               
Выберите другой порт."
               ;;
             *) # All locales
               MAIN_LABEL="Configuring Remote Desktop"
               MAIN_TEXT="Select an action:"
               
               VNC_INSTALL_VINO="To work, you must install vino.
You need to connect to the Internet.

Do you want to install this software?"
               VNC_VIEW_DESKTOP="Let see the desktop (VNC-server)"
               VNC_MANAGE_DESKTOP="Allow control desk"
               VNC_AUTORUN="Access to the desktop at startup (autorun)"
               VNC_PASSWORD="Require password"
               VNC_PROMPT="Require you to confirm the connection"
               VNC_ICON="Icon in the notification area"
               VNC_PORT="Port access"
               VNC_ENCRYPTION="Encryption"
               VNC_ROUTE="Automatically configure the router"               
               VNC_HELP="Help"
               
               VNC_ENTER_PASSWORD="Attention! The word 'keyring' - is not considered as a password,
It will be used in the password keyring GNOME.
Empty password = 'keyring'
Enter the password for access to your desktop"
               VNC_ENTER_ICON="client - to display the tray icon only when you connect to the desktop
never - never display an icon
always - always display the icon"
               ATTENTION="ATTENTION!"
               HELP="This script allows you to configure remote access to the desktop using VNC"
               PORT_ALLARM="- alredy used!
               
Enter another port"
               ;;
esac
#####################################################################
Help () # help window
{
echo -n "$HELP" | $DIALOG --text-info --cancel-label="Back" --title="Help" \
 --width=400 --height=300
}
#####################################################################
InstallVino () # window installing vino
{
(gksudo -- sh -c "
echo '#apt-get update'
apt-get update
echo '#apt-get install -y vino'
apt-get install -y vino
if [ $? = 0 ] 
   then echo '#All be done!'
   else echo '#Some Error!'
fi
sleep 3"
) | $DIALOG --progress --pulsate --auto-close \
--title "Installing vino"
}
#####################################################################
CheckState () # read vino values
{
if [ -x "/usr/lib/vino/vino-server" ] # if vino is install then read values else install vino
 then 
      STATE_VNC_MANAGE_DESKTOP=`dconf read /org/gnome/desktop/remote-access/view-only`
      if [[ $STATE_VNC_MANAGE_DESKTOP == "" ]]
         then STATE_VNC_MANAGE_DESKTOP="true"
      fi
      if [[ $STATE_VNC_MANAGE_DESKTOP == "true" ]]
        then STATE_VNC_MANAGE_DESKTOP="OFF"
        else STATE_VNC_MANAGE_DESKTOP="ON"
      fi

      if [[ $(ps -ela | grep -w $UID | grep vino-server) != "" ]]
         then 
              STATE_VNC_VIEW_DESKTOP="ON"
         else STATE_VNC_VIEW_DESKTOP="OFF"
              STATE_VNC_MANAGE_DESKTOP="OFF"
      fi

      if [ ! -f $HOME/.config/autostart/vino-server.desktop ]
       then STATE_VNC_AUTORUN="OFF"
       else 
            STATE_VNC_AUTORUN=`cat $HOME/.config/autostart/vino-server.desktop | sed "s/ //g" | grep "Hidden=true"`
            if [[ $STATE_VNC_AUTORUN != "" ]]
               then STATE_VNC_AUTORUN="OFF"
               else STATE_VNC_AUTORUN="ON"
            fi
      fi

      STATE_VNC_PASSWORD=`dconf read /org/gnome/desktop/remote-access/authentication-methods`
      if [[ $STATE_VNC_PASSWORD == "" ]]
         then STATE_VNC_PASSWORD="['none']"
      fi
      if [[ $STATE_VNC_PASSWORD == "['none']" ]]
        then STATE_VNC_PASSWORD="OFF"
        else STATE_VNC_PASSWORD="ON"
      fi
      PASSWORD_VNC=$(echo `dconf read /org/gnome/desktop/remote-access/vnc-password| sed "s/'//g"`)
      if [[ $PASSWORD_VNC != "keyring" ]]
        then PASSWORD_VNC=`echo "$PASSWORD_VNC"|base64 -d`
      fi

      STATE_VNC_PROMPT=`dconf read /org/gnome/desktop/remote-access/prompt-enabled`
      if [[ $STATE_VNC_PROMPT == "" ]]
         then STATE_VNC_PROMPT="true"
      fi
      if [[ $STATE_VNC_PROMPT == "true" ]]
        then STATE_VNC_PROMPT="ON"
        else STATE_VNC_PROMPT="OFF"
      fi

      STATE_VNC_ICON=`dconf read /org/gnome/desktop/remote-access/icon-visibility | sed "s/'//g"`
      if [[ $STATE_VNC_ICON == "" ]]
         then STATE_VNC_ICON="client"
      fi
      VNC_ICON_CLIENT="FALSE"
      VNC_ICON_NEVER="FALSE"
      VNC_ICON_ALWAYS="FALSE"
      case $STATE_VNC_ICON in
           "client") VNC_ICON_CLIENT="TRUE"
                     ;;
           "never") VNC_ICON_NEVER="TRUE"
                     ;; 
           "always") VNC_ICON_ALWAYS="TRUE"
                     ;;
      esac

      STATE_VNC_PORT=`dconf read /org/gnome/desktop/remote-access/alternative-port`
      if [[ $STATE_VNC_PORT == "" ]]
         then STATE_VNC_PORT="uint16 5900"
      fi
      STATE_VNC_PORT=`echo $STATE_VNC_PORT | sed "s/uint16 //g"`
      
      STATE_VNC_ENCRYPTION=`dconf read /org/gnome/desktop/remote-access/require-encryption`
      if [[ $STATE_VNC_ENCRYPTION == "" ]]
         then STATE_VNC_ENCRYPTION="true"
      fi
      if [[ $STATE_VNC_ENCRYPTION == "true" ]]
        then STATE_VNC_ENCRYPTION="ON"
        else STATE_VNC_ENCRYPTION="OFF"
      fi

      STATE_VNC_ROUTE=`dconf read /org/gnome/desktop/remote-access/use-upnp`
      if [[ $STATE_VNC_ROUTE == "" ]]
         then STATE_VNC_ROUTE="true"
      fi
      if [[ $STATE_VNC_ROUTE == "true" ]]
        then STATE_VNC_ROUTE="ON"
        else STATE_VNC_ROUTE="OFF"
      fi
 else
      $DIALOG --question --title="$ATTENTION" --text="$VNC_INSTALL_VINO"
      if [ $? -eq "0" ]
         then InstallVino
              MainForm
         else exit 1
      fi
fi
}
#####################################################################
MainForm () # main window
{
# start read vino values
CheckState
# open main window
ANSWER=$($DIALOG --width=450 --height=300 --list --cancel-label="Exit" --title="$MAIN_LABEL" \
      --text="$MAIN_TEXT" \
      --column="" --column="" \
        "$VNC_VIEW_DESKTOP" "$STATE_VNC_VIEW_DESKTOP"\
        "$VNC_MANAGE_DESKTOP" "$STATE_VNC_MANAGE_DESKTOP"\
        "$VNC_AUTORUN" "$STATE_VNC_AUTORUN"\
        "$VNC_PROMPT" "$STATE_VNC_PROMPT"\
        "$VNC_PASSWORD" "$STATE_VNC_PASSWORD"\
        "$VNC_ICON" "$STATE_VNC_ICON"\
        "$VNC_PORT" "$STATE_VNC_PORT"\
        "$VNC_ENCRYPTION" "$STATE_VNC_ENCRYPTION"\
        "$VNC_ROUTE" "$STATE_VNC_ROUTE"\
        "$VNC_HELP" "")
if [ $? == 0 ]
then
 case $ANSWER in
    "$VNC_VIEW_DESKTOP"*) # start/stop vino-server
                case $STATE_VNC_VIEW_DESKTOP in
                     "ON") killall vino-server
                           ;;
                     "OFF") nohup /usr/lib/vino/vino-server --sm-disable &
                           ;;
                           *) MainForm
                           ;;
                esac
                sleep 0.5
                MainForm           
                ;;
    "$VNC_MANAGE_DESKTOP"*) # open manage desktop
                case $STATE_VNC_MANAGE_DESKTOP in
                     "ON") dconf write /org/gnome/desktop/remote-access/view-only true
                           ;;
                     "OFF") dconf write /org/gnome/desktop/remote-access/view-only false
                           ;; 
                           *) MainForm
                           ;;
                esac
                sleep 0.5
                MainForm
                ;;
     "$VNC_AUTORUN"*) # add vino-server to autorun
                case $STATE_VNC_AUTORUN in
                     "ON") rm $HOME/.config/autostart/vino-server.desktop
                           ;;
                     "OFF") cp /usr/share/applications/vino-server.desktop $HOME/.config/autostart/vino-server.desktop 
                           ;; 
                           *) MainForm
                           ;;
                esac
                sleep 0.5
                MainForm           
                ;;
    "$VNC_PASSWORD"*) # on/off password autentification and enter password
                case $STATE_VNC_PASSWORD in
                     "ON") dconf write /org/gnome/desktop/remote-access/authentication-methods "['none']"
                           ;;
                     "OFF") 
                              PASSWORD_VNC=`$DIALOG --entry --title="Enter password" --text="$VNC_ENTER_PASSWORD" --entry-text="$PASSWORD_VNC"`
                              if [ $? == 0 ]
                                 then
                                     if [[ `echo "$PASSWORD_VNC"| sed "s/ //g"` == "" ]]
                                        then PASSWORD_VNC="keyring"
                                     fi
                                     if [[ $PASSWORD_VNC != "keyring" ]]
                                        then PASSWORD_VNC=`echo -n "$PASSWORD_VNC"|base64`
                                     fi
                                     dconf write /org/gnome/desktop/remote-access/vnc-password "'$PASSWORD_VNC'"
                                     dconf write /org/gnome/desktop/remote-access/authentication-methods "['vnc']"
                              fi
                           ;; 
                           *) MainForm
                           ;;
                esac
                sleep 0.5
                MainForm
                ;;
    "$VNC_PROMPT"*) # confirmation Desktop Connection
                case $STATE_VNC_PROMPT in
                     "ON") dconf write /org/gnome/desktop/remote-access/prompt-enabled false
                           ;;
                     "OFF") dconf write /org/gnome/desktop/remote-access/prompt-enabled true
                           ;; 
                           *) MainForm
                           ;;
                esac
                sleep 0.5
                MainForm
                ;;
    "$VNC_PORT"*) # port selection for access
                STATE_VNC_PORT=`$DIALOG --entry --title="Enter access port" --text="Enter port (valid values 5000-50000)" --entry-text="$STATE_VNC_PORT"`
                if [ $? == 0 ]
                   then
                        if [[ $STATE_VNC_PORT == "" ]]
                           then STATE_VNC_PORT="5900"
                        fi
                        # CHEKPORT=$(nmap localhost | grep vnc | grep -w $STATE_VNC_PORT)||\
                        CHEKPORT=$(netstat -anp | grep -w LISTEN | grep "$STATE_VNC_PORT ")
                        if [[ $CHEKPORT != "" ]]
                           then $DIALOG --error --title="$ATTENTION" --text="$STATE_VNC_PORT $PORT_ALLARM"
                           else
                            if [[ $STATE_VNC_PORT == "5900" ]]
                               then dconf write /org/gnome/desktop/remote-access/alternative-port "uint16 $STATE_VNC_PORT"
                                    dconf write /org/gnome/desktop/remote-access/use-alternative-port false
                               else dconf write /org/gnome/desktop/remote-access/alternative-port "uint16 $STATE_VNC_PORT"
                                    dconf write /org/gnome/desktop/remote-access/use-alternative-port true
                            fi
                        fi
                fi
                sleep 0.5
                MainForm
                ;;
    "$VNC_ICON"*) # choice of display icons in the system tray
                STATE_VNC_ICON=`$DIALOG --list --height=200 --title="Enter icon" --text="$VNC_ENTER_ICON" --radiolist --column "" --column "" \
$VNC_ICON_CLIENT "client" \
$VNC_ICON_NEVER "never" \
$VNC_ICON_ALWAYS "always"`
                if [ $? == 0 ]
                  then dconf write /org/gnome/desktop/remote-access/icon-visibility "'$STATE_VNC_ICON'"
                fi
                sleep 0.5
                MainForm
                ;;
    "$VNC_ENCRYPTION"*) # on/off encryption
                case $STATE_VNC_ENCRYPTION in
                     "ON") dconf write /org/gnome/desktop/remote-access/require-encryption false
                           ;;
                     "OFF") dconf write /org/gnome/desktop/remote-access/require-encryption true
                           ;; 
                           *) MainForm
                           ;;
                esac
                sleep 0.5
                MainForm
                ;;
    "$VNC_ROUTE"*) # enable automatic opening of the ports on the router
               case $STATE_VNC_ROUTE in
                     "ON") dconf write /org/gnome/desktop/remote-access/use-upnp false
                           ;;
                     "OFF") dconf write /org/gnome/desktop/remote-access/use-upnp true
                           ;; 
                           *) MainForm
                           ;;
                esac
                sleep 0.5
                MainForm
                ;;
    "$VNC_HELP"*)  # start help window
                Help
                MainForm
                ;;
               *)  
                MainForm 
                ;; 
 esac
else echo Exit; exit 0
fi
}
#####################################################################

# start Main window
MainForm

exit 0
