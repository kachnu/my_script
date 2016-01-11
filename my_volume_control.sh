#!/bin/bash
case $1 in
       --up) LEVEL_VOL=$(amixer set Master 5%+ | grep -m1 -o '...%' | sed 's/\[//' | sed 's/ //')
             notify-send Volume $LEVEL_VOL -i audio-volume-high -t 1
             ;;
     --down) LEVEL_VOL=$(amixer set Master 5%- | grep -m1 -o '...%' | sed 's/\[//' | sed 's/ //')
             notify-send Volume $LEVEL_VOL -i audio-volume-high -t 1
             ;;
     --mute) #LEVEL_VOL=$(amixer set Master toggle | grep -m1 '%' | sed 's/\[/oo/g' | sed 's/\]/oo/g' | sed 's/[ :%]//g' )
             LEVEL_VOL=$(amixer set Master toggle | grep -m1 '%')
             case "$LEVEL_VOL" in
                  *\[off\]*) notify-send Volume OFF -i audio-volume-high -t 1
                            ;;
                   *\[on\]*) notify-send Volume ON -i audio-volume-high -t 1
                           ;;
             esac
             ;;
     --help) echo read help
             ;;     
          *) echo read help
              ;;
esac  
exit 0
