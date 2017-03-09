#!/bin/bash
if [ -f /etc/systemd/network/99-default.link ] || [ -h /etc/systemd/network/99-default.link ] ; then
     echo "Enter password to provide New network device name - enp2s0, wlp3s0 "
     sudo rm /etc/systemd/network/99-default.link
     echo "New network name (enp2s0, wlp3s0 ) - ACTIVE!"
     echo "Need REBOOT!"
else   
     echo "Enter password to provide Old network device name - eth0, wlan0"
     sudo ln -s /dev/null /etc/systemd/network/99-default.link
     echo "Old network name (eth0, wlan0) - ACTIVE!"
     echo "Need REBOOT!"
fi

echo -n "Do you wont reboot now? 
(y, yes - to reboot, * - to exit)"
read x
case $x in 
  y| yes) echo 11111 
     sudo reboot;;
esac
exit 0
