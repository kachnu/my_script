#!/bin/bash

#while true; do
yad --notification --image="multimedia-player" \
--menu '♬ start server!mocp -S\
|☠ stop server!mocp -x\
|▶ play!mocp -p\
|❚❚ pause!mocp -G\
|■ stop!mocp -s\
|>> next!mocp -f\
|<< previous!mocp -p\
|open window!x-terminal-emulator -e mocp'
echo $?
#done
exit 0
