#!/bin/bash
TIME=200
SITE_WEB="http://rutracker.org/forum/viewforum.php?f=1379"
DIRECTORY_TO_SAVE="$HOME/tmp/web_tmp"
FILE_NAME="web_turget"
SEACH_TEXT="Debian 8 Xfce Custom"
INDEX_TEXT="span"
TIME_MESSAGE=6000

if ! [ -d $DIRECTORY_TO_SAVE ]
 then mkdir -p $DIRECTORY_TO_SAVE
fi

rm $DIRECTORY_TO_SAVE/$FILE_NAME
wget --output-document="$DIRECTORY_TO_SAVE/$FILE_NAME" "$SITE_WEB"
OLD_INFO=$(cat "$DIRECTORY_TO_SAVE/info_file")
NEW_INFO=$(cat "$DIRECTORY_TO_SAVE/$FILE_NAME" | grep -A 10 "$SEACH_TEXT" | grep "$INDEX_TEXT")
echo OLD_INFO=$OLD_INFO
echo NEW_INFO=$NEW_INFO

if [[ "$NEW_INFO" != "$OLD_INFO" ]]
 then 
 beep
 MASSAGE_TEXT="+++++++ НА RUTRECKER НАПИСАЛИ СООБЩЕНИЕ! +++++++"
 notify-send -t "$TIME_MESSAGE" "$MASSAGE_TEXT"
 google-chrome --app=$SITE_WEB
 echo "$NEW_INFO" > $DIRECTORY_TO_SAVE/info_file
fi

sleep $TIME
$0
exit 0
