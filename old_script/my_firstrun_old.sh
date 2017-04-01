#!/bin/bash
#Скрипт запускается при первом входе пользователя в систему.
#Целью скрипта является создание закладок, ссылок, отображение окна приветсвия, уточнение данных для установки системы.
#author: kachnu
# email: ya.kachnu@yandex.ua

#Создание закладок в Thunar и окне проводника gtk-3
if [ -f "$HOME/.gtk-bookmarks" ]; then
   sed -i "s/REPLACEME/${USER}/g" $HOME/.gtk-bookmarks
fi
if [ -f "$HOME/.config/gtk-3.0/bookmarks" ]; then
   sed -i "s/REPLACEME/${USER}/g" $HOME/.config/gtk-3.0/bookmarks
fi

#Создание ссылок на обои
if [ ! -f $HOME/images/wallpapers/desktop-base ]; then
   ln -s /usr/share/images/desktop-base $HOME/images/wallpapers/desktop-base
   ln -s /usr/share/backgrounds $HOME/images/wallpapers/backgrounds
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
if [ ! -f "$HOME/.config/Kingsoft/Office.conf" ] && [ -x "`which wps`" ] ; then
  mkdir -p $HOME/.config/Kingsoft/
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[General]
languages=ru_RU

[6.0]
common\wpshomeoptions\default=
common\wpshomeoptions\StartWithHome=0
common\wpshomeoptions\StartWithBlank=1" > $HOME/.config/Kingsoft/Office.conf
               ;;
            *) #All locales
			echo "
[6.0]
common\wpshomeoptions\default=
common\wpshomeoptions\StartWithHome=0
common\wpshomeoptions\StartWithBlank=1" > $HOME/.config/Kingsoft/Office.conf
               ;;
  esac 
fi
#SMplayer (русский - при славянских локалях, монохромные ярлыки)
if [ ! -f "$HOME/.config/smplayer/smplayer.ini" ] && [ -x "`which smplayer`" ] ; then
  mkdir -p $HOME/.config/smplayer/
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[gui]
language=ru_RU
iconset=Monochrome" > $HOME/.config/smplayer/smplayer.ini
               ;;
            *) #All locales
			echo "[gui]
iconset=Monochrome" > $HOME/.config/smplayer/smplayer.ini
               ;;
  esac 
fi
#ocenaudio (русский - при славянских локалях)
if [ ! -f "$HOME/.local/share/data/OcenAudio/ocenaudio.cfg" ] && [ -x "`which ocenaudio`" ] ; then
  mkdir -p $HOME/.local/share/data/OcenAudio/
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[ocenapp]
language=ru_RU" > $HOME/.local/share/data/OcenAudio/ocenaudio.cfg
               ;;
            *) #All locales
			   ;;
  esac 
fi

#masterpdfeditor3  (русский - при славянских локалях)
if [ ! -f "$HOME/.config/Code Industry/Master PDF Editor.conf" ] && [ -x "`which masterpdfeditor3 `" ] ; then
  mkdir -p "$HOME/.config/Code Industry/"
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[General]
lang=ru_ru" > "$HOME/.config/Code Industry/Master PDF Editor.conf"
               ;;
            *) #All locales
			   ;;
  esac 
fi

#moc
if [ -f "$HOME/.moc/config" ] && [ -x "$HOME/.moc/onsongchange.sh" ] ; then
    sed -i "/^OnSongChange/s/^OnSongChange = \"\/\"/OnSongChange = \"\/home\/${USER}\/.moc\/onsongchange.sh %a %t %r\"/g" $HOME/.moc/config
fi



#Убираем данный скрипт из автозапуска
if [ -f "$HOME/.config/autostart/firstrun.desktop" ]; then
   sed -i "s/Hidden=false/Hidden=true/g" $HOME/.config/autostart/firstrun.desktop
fi

exit 0
