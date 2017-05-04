#!/bin/bash
#Скрипт запускается при первом входе пользователя в систему.
#Целью скрипта является создание закладок, ссылок, отображение окна приветсвия, уточнение данных для установки системы.
#author: kachnu
# email: ya.kachnu@yandex.ua

#Создание закладок в Thunar и окне проводника gtk-3
if [ ! -d "$HOME/.config/gtk-3.0" ]; then
   mkdir -p "$HOME/.config/gtk-3.0"
fi
echo "file:///usr/share/applications" >> $HOME/.config/gtk-3.0/bookmarks
if [ -f "$HOME/.config/user-dirs.dirs" ]; then
   MARKS_LIST=`cat "$HOME/.config/user-dirs.dirs" | grep -v \# | grep -v "^XDG_DESKTOP_DIR"| awk -F"=" '{ print $2 }' | sed "s/\"//g"`
   for MARK in $MARKS_LIST
       do
          echo "$MARK" | sed "s|\$HOME|file://${HOME}|g" >> $HOME/.config/gtk-3.0/bookmarks
   done
fi

#Помещаем шаблоны в папку Шаблонов
if [ -f "$HOME/.config/user-dirs.dirs" ] && [ -d "$HOME/templates" ]; then
   TEMPLATES_FOLDER=$(cat "$HOME/.config/user-dirs.dirs" | grep "^XDG_TEMPLATES_DIR"| awk -F"=" '{ print $2 }' | sed "s/\"//g"| sed "s|\$HOME||g")
   mv $HOME/templates/* $HOME/$TEMPLATES_FOLDER
   rm -r "$HOME/templates"
fi

#Копируем ярлык установщика на Рабочий стол
if [ -f "/usr/share/applications/debian-installer-launcher.desktop" ]; then
   DESK_FOLDER=$(cat "$HOME/.config/user-dirs.dirs" | grep "^XDG_DESKTOP_DIR"| awk -F"=" '{ print $2 }' | sed "s/\"//g"| sed "s|\$HOME||g")
   cp /usr/share/applications/debian-installer-launcher.desktop "$HOME/$DESK_FOLDER"
   chmod +x "$HOME/$DESK_FOLDER/debian-installer-launcher.desktop"
fi

##Уточняем данные о нахождении filesystem.squashfs, необходимо при установке системы.
##После установки данные строки не будут использоваться.
#if [ -f "/etc/pointlinux-installer/install.conf" ]
#then
    #OLD_WAY=$(cat /etc/pointlinux-installer/install.conf | grep LIVE_MEDIA_SOURCE | sed "s/LIVE_MEDIA_SOURCE = //g")
    #if [ ! -f "$OLD_WAY" ]
     #then
      #echo "Путь к файлу filesystem.squashfs - $OLD_WAY не верен! Будем искать другой путь к файлу"
      #NEW_WAY=$(find /lib/ -name filesystem.squashfs -type f 2>/dev/null)
      #echo "Найден путь $NEW_WAY, редактируем /etc/pointlinux-installer/install.conf"
      #sudo sed -i "s|${OLD_WAY}|${NEW_WAY}|g" /etc/pointlinux-installer/install.conf
     #else
      #echo "Путь к файлу filesystem.squashfs - $OLD_WAY верен. Никаких изменений не требуется"
    #fi
#fi

#if [ -f "/etc/live-installer/live-installer.conf" ]
#then
    #OLD_WAY=$(cat /etc/live-installer/live-installer.conf | grep live_media_source | sed "s/live_media_source = //g")
    #if [ ! -f "$OLD_WAY" ]
     #then
      #echo "Путь к файлу filesystem.squashfs - $OLD_WAY не верен! Будем искать другой путь к файлу"
      #NEW_WAY=$(find /lib/ -name filesystem.squashfs -type f 2>/dev/null)
      #echo "Найден путь $NEW_WAY, редактируем /etc/live-installer/live-installer.conf"
      #sudo sed -i "s|${OLD_WAY}|${NEW_WAY}|g" /etc/live-installer/live-installer.conf
     #else
      #echo "Путь к файлу filesystem.squashfs - $OLD_WAY верен. Никаких изменений не требуется"
    #fi
#fi


#Убираем блокировку экрана при работе скрин-сейвера
dconf write /apps/light-locker/lock-after-screensaver 'uint32 0'


#Преднастройка ПО

#WPS-office (русский - при славянских локалях)
if [ ! -f "$HOME/.config/Kingsoft/Office.conf" ] && [ -x "`which wps`" ] ; then
  mkdir -p $HOME/.config/Kingsoft/
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[General]
languages=ru_RU" > $HOME/.config/Kingsoft/Office.conf
               ;;
            *) #All locales
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

#masterpdfeditor4  (русский - при славянских локалях)
if [ ! -f "$HOME/.config/Code Industry/Master PDF Editor.conf" ] && [ -x "`which masterpdfeditor4 `" ] ; then
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

# VLC (запуск 1-й копии, не подгонять размеры под видео, не задавать вопрос о мета-инфо по сети)
if [ ! -f "$HOME/.config/vlc/vlcrc" ] && [ -x "`which vlc`" ] ; then
  mkdir -p "$HOME/.config/vlc"
  echo "[qt4] # Qt interface
qt-video-autoresize=0
qt-privacy-ask=0
[core] # core program
one-instance=1" > "$HOME/.config/vlc/vlcrc"
fi

#geany  (кириллица - при славянских локалях)
if [ ! -f "$HOME/.config/geany/geany.conf" ] && [ -x "`which geany`" ] ; then
  mkdir -p "$HOME/.config/geany/"
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[geany]
pref_editor_default_open_encoding=WINDOWS-1251" > "$HOME/.config/geany/geany.conf"
               ;;
            *) #All locales
               ;;
  esac
  echo "[tools]
terminal_cmd=x-terminal-emulator -e /bin/sh %c" >> "$HOME/.config/geany/geany.conf"
fi

#audacious (подбор славянской кодировки)
if [ ! -f "$HOME/.config/audacious/config" ] && [ -x "`which audacious`" ] ; then
  mkdir -p "$HOME/.config/audacious/"
  case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               echo "[audacious]
chardet_detector=russian" > "$HOME/.config/audacious/config"
               ;;
            *) #All locales
               ;;
  esac
fi

##ocenaudio (русский - при славянских локалях)
#if [ ! -f "$HOME/.local/share/data/OcenAudio/ocenaudio.cfg" ] && [ -x "`which ocenaudio`" ] ; then
  #mkdir -p $HOME/.local/share/data/OcenAudio/
  #case $LANG in
  #uk*|ru*|be*) #UA RU BE locales
               #echo "[ocenapp]
#language=ru_RU" > $HOME/.local/share/data/OcenAudio/ocenaudio.cfg
               #;;
            #*) #All locales
               #;;
  #esac
#fi

#moc
if [ -f "$HOME/.moc/config" ] && [ -x "/usr/local/bin/my_moc_info.sh" ] ; then
    echo "OnSongChange = \"/usr/local/bin/my_moc_info.sh -n\"" >> $HOME/.moc/config
fi

#Убираем данный скрипт из автозапуска
if [ -f "$HOME/.config/autostart/firstrun.desktop" ]; then
   sed -i "s/Hidden=false/Hidden=true/g" $HOME/.config/autostart/firstrun.desktop
fi

exit 0
