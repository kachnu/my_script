#!/bin/bash
#Скрипт запускается при первом входе пользователя в систему.
#Целью скрипта является создание закладок, ссылок, отображение окна приветсвия, уточнение данных для установки системы.
#author: kachnu
# email: ya.kachnu@yandex.ua

#Создание закладок в Thunar и окне проводника gtk-3
if [ -f "/home/$USER/.gtk-bookmarks" ]; then
   sed -i "s/REPLACEME/${USER}/g" /home/$USER/.gtk-bookmarks
fi
if [ -f "/home/$USER/.config/gtk-3.0/bookmarks" ]; then
   sed -i "s/REPLACEME/${USER}/g" /home/$USER/.config/gtk-3.0/bookmarks
fi

#Создание ссылок на обои
if [ ! -f /home/$USER/images/wallpapers/desktop-base ]; then
   ln -s /usr/share/images/desktop-base /home/$USER/images/wallpapers/desktop-base
   ln -s /usr/share/backgrounds /home/$USER/images/wallpapers/backgrounds
fi

#Уточняем данные о нахождении filesystem.squashfs, необходимо при установке системы. 
#После установки данные строки не будут использоваться.
if [ -f "/etc/pointlinux-installer/install.conf" ]
then
    OLD_WAY=$(cat /etc/pointlinux-installer/install.conf | grep LIVE_MEDIA_SOURCE | sed "s/LIVE_MEDIA_SOURCE = //g")
    if [ ! -f "$OLD_WAY" ]
     then 
      echo "Путь к файлу filesystem.squashfs - $OLD_WAY не верен! Будем искать другой путь к файлу"
      NEW_WAY=$(find /lib/ -name filesystem.squashfs -type f 2>/dev/null)
      echo "Найден путь $NEW_WAY, редактируем /etc/pointlinux-installer/install.conf" 
      sudo sed -i "s|${OLD_WAY}|${NEW_WAY}|g" /etc/pointlinux-installer/install.conf
     else 
      echo "Путь к файлу filesystem.squashfs - $OLD_WAY верен. Никаких изменений не требуется"
    fi
fi

#Преднастройка ПО 
#WPS-office (русский - при славянских локалях, бланк вместо инет шаблонов)
if [ ! -f "/home/$USER/.config/Kingsoft/Office.conf" ] && [ -x "`which wps`" ] ; then
  mkdir -p /home/$USER/.config/Kingsoft/
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[General]
languages=ru_RU

[6.0]
common\wpshomeoptions\default=
common\wpshomeoptions\StartWithHome=0
common\wpshomeoptions\StartWithBlank=1" > /home/$USER/.config/Kingsoft/Office.conf
               ;;
            *) #All locales
			echo "
[6.0]
common\wpshomeoptions\default=
common\wpshomeoptions\StartWithHome=0
common\wpshomeoptions\StartWithBlank=1" > /home/$USER/.config/Kingsoft/Office.conf
               ;;
  esac 
fi
#SMplayer (русский - при славянских локалях, монохромные ярлыки)
if [ ! -f "/home/$USER/.config/smplayer/smplayer.ini" ] && [ -x "`which smplayer`" ] ; then
  mkdir -p /home/$USER/.config/smplayer/
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[gui]
language=ru_RU
iconset=Monochrome" > /home/$USER/.config/smplayer/smplayer.ini
               ;;
            *) #All locales
			echo "[gui]
iconset=Monochrome" > /home/$USER/.config/smplayer/smplayer.ini
               ;;
  esac 
fi
#ocenaudio (русский - при славянских локалях)
if [ ! -f "/home/$USER/.local/share/data/OcenAudio/ocenaudio.cfg" ] && [ -x "`which ocenaudio`" ] ; then
  mkdir -p /home/$USER/.local/share/data/OcenAudio/
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[ocenapp]
language=ru_RU" > /home/$USER/.local/share/data/OcenAudio/ocenaudio.cfg
               ;;
            *) #All locales
			   ;;
  esac 
fi

#masterpdfeditor3  (русский - при славянских локалях)
if [ ! -f "/home/$USER/.config/Code Industry/Master PDF Editor.conf" ] && [ -x "`which masterpdfeditor3 `" ] ; then
  mkdir -p "/home/$USER/.config/Code Industry/"
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[General]
lang=ru_ru" > "/home/$USER/.config/Code Industry/Master PDF Editor.conf"
               ;;
            *) #All locales
			   ;;
  esac 
fi


#Убираем данный скрипт из автозапуска
if [ -f "/home/$USER/.config/autostart/firstrun.desktop" ]; then
   sed -i "s/Hidden=false/Hidden=true/g" /home/$USER/.config/autostart/firstrun.desktop
fi

exit 0
