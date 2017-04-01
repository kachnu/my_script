#!/bin/bash
DIALOG=yad
while true; do
$DIALOG --notification --image="multimedia-player" \
--menu '♬ start server!mocp -S\
|☠ stop server!mocp -x\
|▶ play!mocp -p\
|❚❚ pause!mocp -G\
|■ stop!mocp -s\
|>> next!mocp -f\
|<< previous!mocp -p\
|open window!x-terminal-emulator -e mocp\
|info on panel!'
case $? in
 0) $DIALOG --question --title="Close moc-applet" --text="Close moc-applet?" 
    if [ $? == 0 ]; then break; fi;;
 252) x-terminal-emulator -e mocp&;;
 *) echo $?;;
esac
done

exit 0
