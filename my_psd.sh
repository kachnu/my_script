#!/bin/bash
#Скрипт является псевдо-графической оболочкой для Profile-sync-daemon
#author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=whiptail #Установка типа графического диалогового окна
TEXT_EDITOR="nano"
TERMINAL="x-terminal-emulator"

if [ ! -x "`which "$DIALOG"`" ]
 then eсho "Not Install - $DIALOG!"
fi

command -v psd >/dev/null 2>&1 || {
echo -e "Profile-sync-daemon not install!" >&2; exit 1; }

if [ ! -f $HOME/.config/psd/psd.conf ]
 then psd
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Ускорение браузера Profile-sync-daemon"
               MAIN_TEXT="Выберите действие:"
               MENU1="Старт/cтоп Profile-sync-daemon"
               MENU2="Автозапуск Profile-sync-daemon"
               MENU3="Состояние"
               MENU4="Редактировать файл настроек"
               MENU5="Очистить резервные копии профилей"
               MENUh="Справка"
               HELP="
Profile-sync-daemon (psd) — небольшой псевдо-демон, предназначенный для переноса профилей браузеров в tmpfs (ОЗУ) и синхронизации с постоянным хранилищем (HDD/SSD) используя rsync.
Демон автоматически производит резервные копии на случай возникновения сбоев.
Цели psd:
 1) Простота в использовании.
 2) Уменьшение износа жесткого диска.
 3) Увеличение скорости работы браузера.
Профили, кэш, и прочие пользовательские данные браузера переносятся с помощью psd в tmpfs (ОЗУ), соответственно операции ввода/вывода браузера перенаправляются в оперативную память.
Таким образом, уменьшается износ жесткого диска, повышается отказоустойчивость и скорость работы браузера.
* Опционально включите использование overlayfs для улучшения скорости синхронизации и уменьшить количество необходимой памяти. 
Для этого используйте переменную USE_OVERLAYFS. 
Пользователю понадобятся sudo права доступа к /usr/bin/psd-overlay-helper для использования этой опции, а также ядро должно поддерживать overlayfs версии 22 или новее. 
Смотрите FAQ на https://wiki.archlinux.org/index.php/Profile-sync-daemon.
* Опционально укажите названия веб-браузеров, профили которых необходимо перенести в ОЗУ, посредством массива BROWSERS. 
Если в этой переменной ничего не указано, по умолчанию перенесутся все найденные профили поддерживаемых браузеров.
* По необходимости можете указать путь к tmpfs разделу с помощью переменной VOLATILE.
* По необходимости можете выключить создание резервных копий профиля (не рекоммендуется) с помощью переменной USE_BACKUPS.
Читайте https://wiki.archlinux.org/index.php/Profile-sync-daemon
"
              ;;
            *) #all locales
               MAIN_LABEL="Browser Acceleration Profile-sync-daemon"
               MAIN_TEXT="Select an action:"
               MENU1="Start/Stop Profile-sync-daemon"
               MENU2="Autostart Profile-sync-daemon"
               MENU3="Status"
               MENU4="Edit the configuration file"
               MENU5="Clear backup profiles"
               MENUh="Help"
               HELP="
Profile-sync-daemonAUR is a tiny pseudo-daemon designed to manage browser profile(s) in tmpfs and to periodically sync back to the physical disc (HDD/SSD).
This is accomplished by an innovative use of rsync to maintain synchronization between a tmpfs copy and media-bound backup of the browser profile(s).
Additionally, psd features several crash recovery features.
Since the profile(s), browser cache*, etc. are relocated into tmpfs (RAM disk), the corresponding I/O associated with using the browser is also redirected from the physical drive to RAM, thus reducing wear to the physical drive and also greatly improving browser speed and responsiveness.
https://wiki.archlinux.org/index.php/Profile-sync-daemon
"
              ;;
esac
##########################
CheckState ()
{
STATE_RUN1=$(psd p | grep "Systemd service" | grep "inactive")
if [ "$STATE_RUN1" != '' ]
 then STATE_RUN="OFF"
 else STATE_RUN="ON"
fi

STATE_RUN2=$(psd p | grep "Systemd service" | grep "unknown")
if [ "$STATE_RUN2" != '' ]
 then STATE_RUN="NO INFO"
fi

if [ -f $HOME/.config/systemd/user/default.target.wants/psd.service ]
 then STATE_AUTO="ON"
 else STATE_AUTO="OFF"
fi
}
##########################
MainForm ()
{
CheckState	
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 15 60\
    7\
        1 "$MENU1 - $STATE_RUN"\
        2 "$MENU2 - $STATE_AUTO"\
        3 "$MENU3"\
        4 "$MENU4"\
        5 "$MENU5"\
        h "$MENUh" 3>&1 1>&2 2>&3)
if [ $? == 0 ]
then
 case $ANSWER in
    1)  clear
        if [ "$STATE_RUN" != "ON" ]
         then echo "START Profile-sync-daemon"
              systemctl --user start psd
         else echo "STOP Profile-sync-daemon"
              systemctl --user stop psd
        fi
        sleep 1
        MainForm
        ;;
    2)  clear
        if [ "$STATE_AUTO" = "ON" ]
         then systemctl --user disable	psd
         else systemctl --user enable psd
        fi 
        MainForm
        ;;
    3)  clear
        psd p
        echo "Push Enter to Main menu"
        read x
        MainForm
        ;;
    4) $TEXT_EDITOR $HOME/.config/psd/psd.conf
        MainForm
        ;;
    5)  clear
        psd c
        echo "Push Enter to Main menu"
        read x
        MainForm
        ;;
    h)  clear
        echo "$HELP" 
        echo "Push Enter to Main menu"
        read x
        MainForm
        ;;
    *)  MainForm 
        ;; 
 esac
else echo Exit; exit 0
fi

}
##########################

MainForm

exit 0
