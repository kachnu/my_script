#!/bin/bash
FILE="$HOME/.config/user-dirs.dirs"

if ! [ -f "$HOME/.config/user-dirs.dirs" ]; then exit 1; fi

if ! [ -f "$HOME/.config/user-dirs.dirs.bak" ]; then
    echo backup $HOME/.config/user-dirs.dirs
    cp "$HOME/.config/user-dirs.dirs" "$HOME/.config/user-dirs.dirs.bak"
fi

HELP="$0 - script for rename home folders.

Usage:
  $0 [KEY]

Keys:
  -en 	English name folder
  -loc 	Local name folder
"

case $1 in
    -en)
        echo make tmp user-dir
        #sed -e 's/XDG_DESKTOP_DIR=.*/XDG_DESKTOP_DIR=\"$HOME\/Desktop\"/g' $FILE
        echo > "$HOME/.config/user-dirs.dirs.tmp"
        while read LINE; do
            if [[ $LINE =~ ^XDG ]]; then
                XDG_TEXT=`echo $LINE | awk -F= '{print $1}'`
                LOC_FOLDER=`echo $LINE | awk -F/ '{print $2}' | sed 's/\"//g'`
                EN_FOLDER=`echo $XDG_TEXT | awk -F_ '{print $2}' | sed 's@[^ ]*@\L&@g' | sed 's@[^ ]*@\u&@1'`
                echo rename "$HOME/$LOC_FOLDER" to "$HOME/$EN_FOLDER"
                mv -f "$HOME/$LOC_FOLDER" "$HOME/$EN_FOLDER"
                echo $XDG_TEXT\=\"\$HOME\/$EN_FOLDER\" >> "$HOME/.config/user-dirs.dirs.tmp"
            else echo $LINE >> "$HOME/.config/user-dirs.dirs.tmp"
            fi
        done < $FILE

        echo mv tmp user-dir to real user-dir
        mv "$HOME/.config/user-dirs.dirs.tmp" "$FILE"
        ;;
   -loc)
        echo recover user-dirs from "$HOME/.config/user-dirs.dirs.tmp"
        mv "$HOME/.config/user-dirs.dirs.bak" "$FILE"
        while read LINE; do
            if [[ $LINE =~ ^XDG ]]; then
                XDG_TEXT=`echo "$LINE" | awk -F= '{print $1}'`
                LOC_FOLDER=`echo "$LINE" | awk -F/ '{print $2}' | sed 's/\"//g'`
                EN_FOLDER=`echo "$XDG_TEXT" | awk -F_ '{print $2}' | sed 's@[^ ]*@\L&@g' | sed 's@[^ ]*@\u&@1'`
                echo rename "$HOME/$EN_FOLDER" to "$HOME/$LOC_FOLDER"
                mv -f "$HOME/$EN_FOLDER" "$HOME/$LOC_FOLDER" 
            fi
        done < $FILE
         ;;
       *)
         echo -e "$HELP"
         exit 1
         ;;
esac

echo make new bookmarks
#sleep 2
rm $HOME/.config/gtk-3.0/bookmarks
echo "file:///usr/share/applications" >> $HOME/.config/gtk-3.0/bookmarks
MARKS_LIST=`cat "$HOME/.config/user-dirs.dirs" | grep -v \# | grep -v "^XDG_DESKTOP_DIR" | awk -F"=" '{ print $2 }' | sed "s/\"//g"`
IFS=$'\n'
for MARK in "$MARKS_LIST"; do 
    echo "$MARK" | sed "s|\$HOME|file://${HOME}|g" >> $HOME/.config/gtk-3.0/bookmarks
done

#echo clear empty folder
#DESKTOP_FOLDER=`cat "$HOME/.config/user-dirs.dirs" | grep "^XDG_DESKTOP_DIR" | awk -F/ '{ print $2 }' | sed "s/\"//g"`
#find "$HOME/$DESKTOP_FOLDER/" -type d -empty -exec rmdir {} \;

exit 0
