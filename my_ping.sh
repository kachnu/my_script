#!/bin/bash
# script for ping http://xxxx.yyy.zz/abcd (https, ftp)

DEST=$1
if [[ $(echo $DEST | grep /) ]]; then
      CLEAR_DEST=$(echo $DEST | awk -F\/ '{print $3}')
     /bin/ping $CLEAR_DEST
else /bin/ping $DEST
fi

exit 0
