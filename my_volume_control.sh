#!/bin/bash
# изменение громкости
# author: kachnu
# email: ya.kachnu@yandex.ua

HELP="$0 - script to change the volume. 
Usage:
  $0 [KEY]

Keys:
  -u, --up		volume up
  -d, --down		volume down
  -m, --mute		mute"

for i in `pactl list short sinks | awk '{print $1}'`; do 
  case $1 in
       --up|-u) pactl set-sink-mute $i false; pactl set-sink-volume $i +3%;;
     --down|-d) pactl set-sink-mute $i false; pactl set-sink-volume $i -3%;;
     --mute|-m) pactl set-sink-mute $i toggle;;
             *) echo "$HELP"; exit;;
  esac 
done 
exit 0
