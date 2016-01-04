#!/bin/sh
# Простой скрипт для настройки сглаживания шрифтов в Wine.
#
# Связь с автором: Тарасов Игорь <tarasov.igor@gmail.com>
# немного добелывал: kachnu <ya.kachnu@yandex.ua>

WINE=${WINE:-wine}
WINEPREFIX=${WINEPREFIX:-$HOME/.wine}

#Переменная DIALOG - псевдо-графическое/графическое диалоговое окно, по умолчанию имеет значение - gdialog
#DIALOG=whiptail #
DIALOG=gdialog




if [ ! -x "`which "$WINE"`" ]
then
   case $LANG in
    uk*|ru*|be*) echo "Wine не обнаружен. Он точно установлен? ($WINE)" ;;
              *) echo "Wine not found! ($WINE)";;
   esac
   exit 1
fi

if [ ! -x "`which "$DIALOG"`" ]
then
  DIALOG=whiptail
  if [ ! -x "`which "$DIALOG"`" ]
  then DIALOG=dialog
  fi
fi

TMPFILE=`mktemp` || exit 1

cd $HOME
STATE_DIS=''
STATE_EN=''
STATE_EN_RBG=''
STATE_EN_BRG=''
wine regedit /E HKEY_CURRENT_USER
MODE=`cat HKEY_CURRENT_USER | grep \"FontSmoothing\" | sed "s/[^0-9]//g"`
TYPE=`cat HKEY_CURRENT_USER | grep \"FontSmoothingType\" | sed "s/[^0-9]//g" | sed "s/0000000//g"`
ORIENTATION=`cat HKEY_CURRENT_USER | grep \"FontSmoothingOrientation\" | sed "s/[^0-9]//g" | sed "s/0000000//g"`
if [ $MODE = 0 ] && [ $TYPE = 0 ] && [ $ORIENTATION = 1 ]
 then STATE_DIS='- ON'
fi
if [ $MODE = '' ] && [ $TYPE = '' ] && [ $ORIENTATION = '' ]
 then STATE_DIS='- ON'
fi
if [ $MODE = 2 ] && [ $TYPE = 1 ] && [ $ORIENTATION = 1 ]
 then STATE_EN='- ON'
fi
if [ $MODE = 2 ] && [ $TYPE = 2 ] && [ $ORIENTATION = 1 ]
 then STATE_EN_RBG='- ON'
fi
if [ $MODE = 2 ] && [ $TYPE = 2 ] && [ $ORIENTATION = 0 ]
 then STATE_EN_BRG='- ON'
fi
rm -f HKEY_CURRENT_USER

case $LANG in
   uk*|ru*|be*) #UA RU BE locales 
                MENU_TEXT="Выберите режим сглаживания шрифтов в wine:"
                MENU1="Сглаживание выключено"
                MENU2="Сглаживание градациями серого"
                MENU3="Субпиксельное сглаживание (ClearType) RGB"
                MENU4="Субпиксельное сглаживание (ClearType) BGR"
                ;;
            *) #All locales
                MENU_TEXT="Select the font cleartype in wine:"
                MENU1="Disable cleartype"
                MENU2="Enable cleartype grayscale"
                MENU3="Enable ClearType RGB"
                MENU4="Enable ClearType BGR"
                ;;
esac

$DIALOG --menu \
   "$MENU_TEXT" 13 65\
    4\
        1 "$MENU1 $STATE_DIS"\
        2 "$MENU2 $STATE_EN"\
        3 "$MENU3 $STATE_EN_RBG"\
        4 "$MENU4 $STATE_EN_BRG" 2>$TMPFILE

STATUS=$?
ANSWER=`cat $TMPFILE`

if [ $STATUS != 0 ]
then 
    rm -f $TMPFILE
    exit 1
fi

MODE=0 # 0 = disabled; 2 = enabled
TYPE=0 # 1 = regular;  2 = subpixel
ORIENTATION=1 # 0 = BGR; 1 = RGB

case $ANSWER in
    1) # disable
        ;;
    2) # enable
        MODE=2
        TYPE=1
        ;;
    3) # enable cleartype rgb
        MODE=2
        TYPE=2
        ;;
    4) # enable cleartype bgr
        MODE=2
        TYPE=2
        ORIENTATION=0
        ;;
    *)  rm -f $TMPFILE
        echo "ooops! - $ANSWER"
        exit 1
        ;;
esac

echo "REGEDIT4

[HKEY_CURRENT_USER\Control Panel\Desktop]
\"FontSmoothing\"=\"$MODE\"
\"FontSmoothingOrientation\"=dword:0000000$ORIENTATION
\"FontSmoothingType\"=dword:0000000$TYPE
\"FontSmoothingGamma\"=dword:00000578" > $TMPFILE

case $LANG in
    uk*|ru*|be*) echo -n "Применяю настройки ... ";;
              *) echo -n "Apply the settings ... ";;
esac
$WINE regedit $TMPFILE 2> /dev/null

rm -f $TMPFILE

echo ok
