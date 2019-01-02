#!/bin/bash
# script for ping http://xxxx.yyy.zz/abcd (https, ftp)

DEST=$1
CLEAR_DEST=$(echo $DEST | awk -F\/ '{print $3}')
/bin/ping $CLEAR_DEST

exit 0
