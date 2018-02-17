#!/bin/bash
# Скрипт настройки RDP-сервера (xrdp)
# author: kachnu
# email:  ya.kachnu@gmail.com

DIALOG=whiptail

if [ ! -x "`which "$DIALOG"`" ]
   then DIALOG=dialog
fi

case $LANG in
  uk*|ru*|be*) # UA RU BE locales
               MAIN_LABEL="Настройка удаленного рабочего стола RDP"
               MAIN_TEXT="Выберите действие:"
               START_STOP_RDP="Сервер рабочего стола RDP"
               RESTART_RDP="Перезапустить RDP-сервер"
               AUTOSTART_RDP="Автозапуск RDP-сервера"
               PORT_RDP="* Порт доступа"
               NEW_KEY_RDP="* Новый ключ RSA"
               CRYPT_LEVEL_RDP="* Уровень шифрования"
               COLOR_RDP="* Глубина цвета"
               FORK_RDP="* Новая сесcия для других ПК"
               EDIT_XRDP="* Редактировать xrdp.ini"
               RULE_START_X="Права на запуск Х сервера"
               HELP_RDP="Справка"
               FORK_TEXT="Выберите хотите ли открывать новую сессию:
  yes - при доступе с другого ПК будет начата новая сессия
  no - при повторном доступе пользователя с другого ПК, пользователь попадет в ранее открытую сессию"
               CRYPT_TEXT="Выберите уровень шифрования подключения"
               COLOR_TEXT="Выберите глубину цвета"
               PORT_TEXT="Введите порт доступа (1024-49151)
Пустое значение = порт по умолчанию 3389
Вы не сможете продолжить, если выбрали уже занятый порт"
               EXIT_TEXT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               HELP="
____________________________________
   Справка
Данный скрипт предназначен для гибкой настройки RDP-сервера (на базе xrdp).
* - отмечены настройки, применение которых требует перезагрузки RDP-сервера.
Обратите внимание, что при перезагрузке RDP - все запущенные сеансы будут закрыты.

Если по какой-то причине сервер не стартует попробуйте создать новый ключ RSA, воспользуйтесь пунктом:
 - $NEW_KEY_RDP

Если не возможно подключиться через Xorg, воспользуйтесь пунктом: 
 - $RULE_START_X
в появившемся окне выберете 'Кто угодно' или отредактируейте файл /etc/X11/Xwrapper.config с параметром allowed_users=anybody
___________________________________"
               ;;
              *) # All locales
                 MAIN_LABEL="Setting up Remote Desktop RDP"
                 MAIN_TEXT="Select an action:"
                 START_STOP_RDP="Server Desktop RDP"
                 RESTART_RDP="Restart RDP server"
                 AUTOSTART_RDP="Autorun RDP server"
                 PORT_RDP="* Port access"
                 NEW_KEY_RDP="* New RSA key"
                 CRYPT_LEVEL_RDP="* Crypt level"
                 COLOR_RDP="* Color depth"
                 FORK_RDP="* New Session to other PCs"
                 EDIT_XRDP="* Edit xrdp.ini"
                 RULE_START_X="X server startup rights"
                 HELP_RDP="Help"
                 FORK_TEXT="Select whether you want to open a new session:
  yes - the new session will be started when you access from another PC
  no - during the second user access from another PC, the user will get in before an open session"
                 CRYPT_TEXT="Select the connection encryption level"
                 COLOR_TEXT="Select a color depth"
                 PORT_TEXT="Enter the access port (1024-49151)
Empty value = default port 3389
You can not continue if selected an already busy port"
                 EXIT_TEXT="
Press Enter to go to the main menu"
                 ATTENTION="ATTENTION!"
                 HELP="
____________________________________
   HELP
This script is intended for RDP-server, flexible settings (based on xrdp).
* - Marked settings, the use of which requires a restart of the RDP-server.
Note that when you restart the RDP - all open sessions will be closed.

If for some reason the server does not start, try to create a new RSA key, use the following:
 - $NEW_KEY_RDP
 
If it is not possible to connect via Xorg, use:
 - $RULE_START_X
in the window that appears, select Anyone or edit the file /etc/X11/Xwrapper.config with the parameter allowed_users=anybody


___________________________________"
esac    

#########################################################
CheckState () # read values
{
if [ -f "/usr/sbin/xrdp" ] # if xrdp is install then read values else install xrdp
   then 
      #if [[ $(pidof xrdp) != "" ]]
         #then STATE_XRDP="ON"
         #else STATE_XRDP="OFF"
      #fi
     
      #if [ -f "/etc/init.d/xrdp" ]
         #then STATE_AUTORUN_XRDP="ON"
         #else 
             #if [[ $(cat /etc/init.d/.depend.start| grep xrdp) != "" ]]
                #then STATE_AUTORUN_XRDP="ON"
                #else STATE_AUTORUN_XRDP="OFF"
             #fi
      #fi
      
      if [[ $(systemctl status xrdp | grep running) != '' ]]
         then STATE_XRDP="ON"
         else STATE_XRDP="OFF"
      fi
      
            
      if [[ $(systemctl is-enabled xrdp) == 'enabled' ]]
         then STATE_AUTORUN_XRDP="ON"
         else STATE_AUTORUN_XRDP="OFF"
      fi
          
      STATE_PORT_RDP=$(cat /etc/xrdp/xrdp.ini | grep -m 1 port= | sed "s/ //g" | sed "s/port=//g")
      STATE_CRYPT_LEVEL_RDP=$(cat /etc/xrdp/xrdp.ini | grep -m 1 crypt_level= | sed "s/ //g" | sed "s/crypt_level=//g")
      STATE_COLOR_RDP=$(cat /etc/xrdp/xrdp.ini | grep -m 1 max_bpp= | sed "s/ //g" | sed "s/max_bpp=//g")
      STATE_FORK_RDP=$(cat /etc/xrdp/xrdp.ini | grep -m 1 fork= | sed "s/ //g" | sed "s/fork=//g")
   else echo "Need install xrdp!"
      read input
fi
}
#########################################################
NewKey ()
{
test -e /etc/xrdp/rsakeys.ini || (echo Gen key RSA for RDP
umask 077
sudo xrdp-keygen xrdp auto
sudo chown xrdp /etc/xrdp/rsakeys.ini)
}
#########################################################
RestartXrdp () # Start reset xrdp
{
echo Hard restart xrdp and xrdp-sesman
echo Stop xrdp and xrdp-sesman
sudo systemctl stop xrdp-sesman.service || read x  
sudo systemctl stop xrdp.service || read x
echo Start xrdp and xrdp-sesman
sudo systemctl start xrdp.service || read x
sudo systemctl start xrdp-sesman.service || read x
sleep 2
}
#########################################################
MainForm () # Main form
{
CheckState
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 18 50\
    11\
        "$START_STOP_RDP" "$STATE_XRDP"\
        "$AUTOSTART_RDP" "$STATE_AUTORUN_XRDP"\
        "$PORT_RDP" "$STATE_PORT_RDP"\
        "$CRYPT_LEVEL_RDP" "$STATE_CRYPT_LEVEL_RDP"\
        "$COLOR_RDP" "$STATE_COLOR_RDP"\
        "$FORK_RDP" "$STATE_FORK_RDP"\
        "$NEW_KEY_RDP" ""\
        "$EDIT_XRDP" ""\
        "$RESTART_RDP" ""\
        "$RULE_START_X" ""\
        "$HELP_RDP" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then echo Exit ; exit 0
fi
case $ANSWER in
        "$START_STOP_RDP") if [[ "$STATE_XRDP" == "ON" ]]
                             then sudo systemctl stop xrdp-sesman.service
                                  sudo systemctl stop xrdp.service
                             else sudo systemctl start xrdp.service || (sudo dpkg-reconfigure xrdp && sudo systemctl start xrdp.service)
                                  sudo systemctl start xrdp-sesman.service
                           fi
                           sleep 2
        ;;
        "$RESTART_RDP") RestartXrdp
        ;;
        "$AUTOSTART_RDP") if [[ "$STATE_AUTORUN_XRDP" == "ON" ]]
                             then sudo systemctl disable xrdp.service
                                  sudo systemctl disable xrdp-sesman.service
                             else sudo systemctl enable xrdp.service
                                  sudo systemctl enable xrdp-sesman.service
                          fi
                          sleep 1
        ;;
        "$PORT_RDP") while true; do
                           STATE_PORT_RDP=$($DIALOG --title "Access port" --inputbox "$PORT_TEXT" 14 60 $STATE_PORT_RDP 3>&1 1>&2 2>&3)
                           if [ $? != 0 ]
                              then MainForm; break
                           fi
                           if [[ "$STATE_PORT_RDP" == "" ]]
                              then STATE_PORT_RDP=3389
                           fi
                           if [[ "$STATE_PORT_RDP" -ge 1024 ]] && [[ "$STATE_PORT_RDP" -le 49151 ]]
                              then CHEKPORT=$(netstat -anp | grep -w LISTEN | grep "$STATE_PORT_RDP ")
                                   if [[ $CHEKPORT == "" ]]
                                      then break
                                   fi
                           fi
                     done
                     IZMENA=$(cat /etc/xrdp/xrdp.ini | grep -m 1 port=)
                     sudo sed -i "s/${IZMENA}/port=${STATE_PORT_RDP}/" /etc/xrdp/xrdp.ini
                     # sudo sed -i "s/^ListenPort.*/ListenPort=${STATE_PORT_RDP}/" /etc/xrdp/sesman.ini
        ;;
        "$NEW_KEY_RDP") sudo rm -r /etc/xrdp/rsakeys.ini
                        NewKey
        ;;
        "$CRYPT_LEVEL_RDP") state_none="OFF"
                            state_low="OFF"
                            state_low="OFF"
                            state_medium="OFF"
                            state_high="OFF"
                            state_fips="OFF"
                            case $STATE_CRYPT_LEVEL_RDP in
                                none) state_none="ON";;
                                low) state_low="ON";;
                                medium) state_medium="ON";;
                                high) state_high="ON";;
                                fips) state_fips="ON";;
                            esac
                            STATE_CRYPT_LEVEL_RDP=$($DIALOG --title "CRYPT LEVEL" --radiolist \
                            "$CRYPT_TEXT" 15 40 5 \
                            "none" "" $state_none \
                            "low" "" $state_low \
                            "medium" "" $state_medium \
                            "high" "" $state_high 3>&1 1>&2 2>&3)
                            if [ $? != 0 ]; then
                               MainForm
                            fi
                            sudo sed -i "s/^crypt_level.*/crypt_level=${STATE_CRYPT_LEVEL_RDP}/" /etc/xrdp/xrdp.ini
        ;;
        "$COLOR_RDP") state_8="OFF"
                      state_15="OFF"
                      state_16="OFF"
                      state_24="OFF"
                      state_32="OFF"
                      case $STATE_COLOR_RDP in
                           "8") state_8="ON";;
                           "15") state_15="ON";;
                           "16") state_16="ON";;
                           "24") state_24="ON";;
                           "32") state_32="ON";;
                      esac
                      STATE_COLOR_RDP=$($DIALOG --title "COLOR LEVEL" --radiolist \
                            "$COLOR_TEXT" 15 30 5 \
                            "8" "" "$state_8"\
                            "15" "" "$state_15"\
                            "16" "" "$state_16"\
                            "24" "" "$state_24"\
                            "32" "" "$state_32" 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]; then
                        MainForm
                     fi
                     sudo sed -i "s/^max_bpp.*/max_bpp=${STATE_COLOR_RDP}/" /etc/xrdp/xrdp.ini
        ;;
        "$FORK_RDP")  state_y="OFF"
                      state_n="OFF"
                      case $STATE_FORK_RDP in
                           "no"|0|"false") state_n="ON";;
                           "yes"|1|"true") state_y="ON";;
                      esac
                      STATE_FORK_RDP=$($DIALOG --title "FORK STATE" --radiolist \
                            "$FORK_TEXT" 15 50 2 \
                            "yes" "" "$state_y"\
                            "no" "" "$state_n" 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]; then
                        MainForm
                     fi
                     sudo sed -i "s/^fork.*/fork=${STATE_FORK_RDP}/" /etc/xrdp/xrdp.ini
        ;;
        "$RULE_START_X" ) sudo dpkg-reconfigure xserver-xorg-legacy
        ;;
        "$EDIT_XRDP") sudo nano /etc/xrdp/xrdp.ini
        ;;
        "$HELP_RDP") echo "$HELP"
                     echo "$EXIT_TEXT"
                     read input
        ;;
esac

MainForm
}
##################################
# If not found /etc/xrdp/rsakeys.ini - gen new key
NewKey 

# Call main form
MainForm 

exit 0
