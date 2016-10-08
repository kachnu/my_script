#!/bin/bash
# Скрипт настройки RDP-сервера (xrdp)
# author: kachnu
# email:  ya.kachnu@yandex.ua

DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
 then
  DIALOG=whiptail
  if [ ! -x "`which "$DIALOG"`" ]
  then DIALOG=dialog
  fi
fi

case $LANG in
  uk*|ru*|be*|*) #UA RU BE locales
               MAIN_LABEL="Настройка удаленного рабочего стола RDP"
               MAIN_TEXT="Выберите действие:"
               START_STOP_RDP="Сервер рабочего стола RDP"
               RESTART_RDP="Перезапустить RDP"
               AUTOSTART_RDP="Автозапуск RDP-сервера"
               PORT_RDP="Порт доступа"
               NEW_KEY_RDP="Новый ключ RSA"
               CRYPT_LEVEL_RDP="Уровень шифрования"
               COLOR_RDP="Глубина цвета"
               HELP_RDP="Справка"
               CRYPT_TEXT="Выберите уровень шифрования подключения"
               EXIT_TEXT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               CHECK_PO="- не найдено!"
               ALLOK="Задание выполнено!"
               HELP="
____________________________________
   Справка
666666
___________________________________"
             
               ;;
esac    

#########################################################
CheckState () # read values
{
if [ -f "/usr/sbin/xrdp" ] # if xrdp is install then read values else install xrdp
 then 
      if [[ $(pidof xrdp) != "" ]]
         then STATE_XRDP="ON"
         else STATE_XRDP="OFF"
      fi
      
      if [[ $(cat /etc/init.d/.depend.start| grep xrdp) != "" ]]
         then STATE_AUTORUN_XRDP="ON"
         else STATE_AUTORUN_XRDP="OFF"
      fi
      
      STATE_PORT_RDP=$(cat /etc/xrdp/xrdp.ini | grep -m 1 port | sed "s/ //g" | sed "s/port=//g")
      STATE_CRYPT_LEVEL_RDP=$(cat /etc/xrdp/xrdp.ini | grep -m 1 crypt_level | sed "s/ //g" | sed "s/crypt_level=//g")
      STATE_COLOR_RDP=$(cat /etc/xrdp/xrdp.ini | grep -m 1 max_bpp | sed "s/ //g" | sed "s/max_bpp=//g")

 else echo "Need install xrdp!"
      read input
fi
}
#########################################################
RestartXrdp ()
{
echo need restart xrdp
sudo systemctl restart xrdp.service
}
#########################################################
MainForm () #Главная форма
{
CheckState
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 15 50\
    8\
        "$START_STOP_RDP" "$STATE_XRDP"\
        "$AUTOSTART_RDP" "$STATE_AUTORUN_XRDP"\
        "$PORT_RDP" "$STATE_PORT_RDP"\
        "$CRYPT_LEVEL_RDP" "$STATE_CRYPT_LEVEL_RDP"\
        "$COLOR_RDP" "$STATE_COLOR_RDP"\
        "$NEW_KEY_RDP" ""\
        "$RESTART_RDP" ""\
        "$HELP_RDP" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
        "$START_STOP_RDP") if [[ "$STATE_XRDP" == "ON" ]]
                             then sudo systemctl stop xrdp.service
                             else sudo systemctl start xrdp.service
                          fi
        ;;
        "$RESTART_RDP") sudo systemctl restart xrdp.service
        ;;
        "$AUTOSTART_RDP") if [[ "$STATE_AUTORUN_XRDP" == "ON" ]]
                             then sudo systemctl disable xrdp.service
                             else sudo systemctl enable xrdp.service
                          fi
        ;;
        "$PORT_RDP") echo 4
        ;;
        "$NEW_KEY_RDP") sudo rm -r /etc/xrdp/rsakeys.ini
                        test -e /etc/xrdp/rsakeys.ini || (umask 077
                        sudo xrdp-keygen xrdp auto
                        sudo chown xrdp /etc/xrdp/rsakeys.ini)
                        RestartXrdp
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
                            STATE_CRYPT_LEVEL_RDP=$(whiptail --title "CRYPT LEVEL" --radiolist \
                            "$CRYPT_TEXT" 15 40 5 \
                            "none" "" $state_none \
                            "low" "" $state_low \
                            "medium" "" $state_medium \
                            "high" "" $state_high 3>&1 1>&2 2>&3)
                            if [ $? != 0 ]; then
                               MainForm
                            fi
                            sudo sed -i "s/^crypt_level.*/crypt_level=${STATE_CRYPT_LEVEL_RDP}/" /etc/xrdp/xrdp.ini
                            RestartXrdp
        
        ;;
        "$COLOR_RDP") echo 7
        ;;
        "$HELP_RDP") echo "$HELP"
                     echo "$EXIT_TEXT"
                     read input
        ;;
esac

MainForm
}
##################################

case $1 in
        *  ) MainForm ;;
esac

exit 0
