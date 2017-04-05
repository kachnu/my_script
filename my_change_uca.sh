#!/bin/bash

UCA=$1
UCA=uca.xml

NEW_UCA=uca_test.xml
NUM_LINE=0 
rm "$NEW_UCA"
cat "$UCA" | while read line; do
 let NUM_LINE=$NUM_LINE+1
 if [[ `echo -e "$line" | grep '<name>'` ]]; then
    let NUM=$NUM_LINE+3
    sed -n -e ${NUM}p $UCA | sed "s;description;name;g" >> "$NEW_UCA"
    sed -n -e ${NUM_LINE}p $UCA  | sed "s;<name;<name xml:lang=\"ru\";g" >> "$NEW_UCA"
 else sed -n -e ${NUM_LINE}p $UCA >> "$NEW_UCA"
 fi
done

exit 0
