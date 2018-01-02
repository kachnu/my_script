#!/usr/bin/env bash
# онлайн перевод выделенного фрагмента текста
# author: kachnu
# email: ya.kachnu@gmail.com

# загружаем файл настроек, если его нет - создаем
CONF_FILE="$HOME/.config/translate.conf"
source "$CONF_FILE"
if [ $? != 0 ]
 then 
      echo 'LNG="en"' > "$CONF_FILE"
      echo 'COPY="true"' >> "$CONF_FILE"
      echo 'WINDOW="true"' >> "$CONF_FILE"
      echo 'NOTIFY="true"' >> "$CONF_FILE"
      echo 'SOURCE="true"' >> "$CONF_FILE"
      source "$CONF_FILE"
fi

OPT=$1
LNG2=$2
SCRIPT_WAY=`readlink -e "$0"`
SEPAR="\n ######################### \n"

settings ()
{
# проверяем установлен ли yad
if ! [ `which yad` ]; then echo "Need yad"; exit 1; fi

# список языков uk-українська, ru-русский, be-беларуска, en-english
LNG_LIST="en!uk!ru!be"

yad --window-icon=accessories-dictionary --title="Settings translate" \
--form --separator="," \
--field="Language::CB" "$LNG!$LNG_LIST" \
--field="Translate to clipboard::CB" "$COPY!true!false" \
--field="Translate to window::CB" "$WINDOW!true!false" \
--field="Translate to notify::CB" "$NOTIFY!true!false" \
--field="Print source text::CB" "$SOURCE!true!false" | while read line; do
    LNG=`echo $line | awk -F',' '{print $1}'`
    COPY=`echo $line | awk -F',' '{print $2}'`
    WINDOW=`echo $line | awk -F',' '{print $3}'`
    NOTIFY=`echo $line | awk -F',' '{print $4}'`
    SOURCE=`echo $line | awk -F',' '{print $5}'`
    
    echo "LNG=\"$LNG\"" > "$CONF_FILE"
    echo "COPY=\"$COPY\"" >> "$CONF_FILE"
    echo "WINDOW=\"$WINDOW\"" >> "$CONF_FILE"
    echo "NOTIFY=\"$NOTIFY\"" >> "$CONF_FILE"
    echo "SOURCE=\"$SOURCE\"" >> "$CONF_FILE"
done
source "$CONF_FILE"
}

trans ()
{
text="$(xsel -o)"
answer="$(wget -U "Mozilla/5.0" -qO - "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$LNG&dt=t&q=\
$(echo $text | sed "s/[\"'<>#]//g")" || echo "__\",\"Check network!!!" )"

translate="$(echo "$answer" | awk -F"null,\"" '{print $1}' \
| awk -F".[[,]\"" '{ i=2; while (i<=NF) {print $i ; i=i+2}}' | awk -F",null" '{print $1}')"
}

AppletTrans ()
{
if ! [ `which yad` ]; then echo "Need yad"; exit 1; fi
while true; do
yad --notification --image="accessories-dictionary" --menu \
"Translate!$SCRIPT_WAY\
|Русский!$SCRIPT_WAY -l ru\
|Українська!$SCRIPT_WAY -l uk\
|Беларуска!$SCRIPT_WAY -l be\
|English!$SCRIPT_WAY -l en\
|Settings!$SCRIPT_WAY -s"
case $? in
 0) yad --question --title="Close  applet" --text="Close translate applet?" 
    if [ $? == 0 ]; then break; fi;;
 252) $SCRIPT_WAY;;
 *) echo $?;;
esac
done
}

case $OPT in
    -a) AppletTrans;;
    -s) settings;;
    -l) sed -i '/^LNG/d' "$CONF_FILE"
        echo "LNG=\"$LNG2\"" >> "$CONF_FILE";;
    -h) #clear
       echo -e "Script `basename $SCRIPT_WAY` to translate

Options
    -a   start Applet 
    -l   set language
    -s   settings"
    ;;
    *) trans

	# отображение исходного текста
	if [ "$SOURCE" = "false" ]
	  then text=' '
	       SEPAR=' '
	fi
	
	# сохранить перевод в буфер обмена
	if [ "$COPY" = "true" ]
	  then echo "$translate" | xclip -selection clipboard
	fi
	
	# вывести во всплывающем сообщении
	if [ "$NOTIFY" = "true" ]
	  then notify-send -t 10000 --icon=info "$text" "$translate"
	fi
	
	# вывести в окне
	if [ "$WINDOW" = "true" ]
	   then echo -e "$text$SEPAR$translate" | zenity --text-info --title="Translation" --width=600 --height=400
	fi;;

esac

exit 0



