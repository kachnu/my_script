#!/bin/bash

cd "$(dirname "$0")"
DESKT_FOLDER="."
APPL_FOLDER="/usr/share/applications"

LIST_APPL=`ls $APPL_FOLDER`
LIST_DESKT=`ls $DESKT_FOLDER`
#echo $LIST_APPL
#echo $LIST_DESKT

for DESK in $LIST_DESKT; do
 if [[ `echo "$LIST_APPL"| grep $DESK` ]]; then
    echo $DESK
    sudo cp "$DESKT_FOLDER/$DESK" "$APPL_FOLDER"
    sudo chmod +r "$APPL_FOLDER"
 else echo  ---- $DESK
 fi
done



exit 0
