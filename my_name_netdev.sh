#!/bin/bash

case $LANG in
    ru*|ua*|be*) NEW_ND_NAME="Использовать НОВЫЕ имена сетевых устройств - enp2s0, wlp3s0"
                 OLD_ND_NAME="Использовать СТАРЫЕ имена сетевых устройств - eth0, wlan0"
                 REBOOT="Чтобы изменения вступили в силу, необходима перезагрузка.
Хотите выполнить перезагрузку сейчас?
(y, yes - перезагрузить; * - выйти)";;
              *) NEW_ND_NAME="Provide NEW network device names - enp2s0, wlp3s0"
                 OLD_ND_NAME="Provide OLD network device names - eth0, wlan0"
                 REBOOT="For the changes to take effect, you need reboot.
Do you want reboot now?
(y, yes - reload; * - quit)";;
esac

if [ -f /etc/systemd/network/99-default.link ] || [ -h /etc/systemd/network/99-default.link ] ; then
     #provide new name
     echo "$NEW_ND_NAME"
     sudo rm /etc/systemd/network/99-default.link
else #provide old name  
     echo "$OLD_ND_NAME"
     sudo ln -s /dev/null /etc/systemd/network/99-default.link
fi

echo -n "$REBOOT"

read x
case $x in 
  y*) sudo reboot;;
esac
exit 0
