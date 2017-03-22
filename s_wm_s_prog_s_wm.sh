#!/bin/bash
PROG=$1
WM_LIST="xfwm4 compiz metacity"
for WM in $WM_LIST; do
  if [[ `pgrep -u $USER $WM` ]]; then break; fi
done
xfwm4 --replace &
$PROG
$WM --replace &
exit 0
