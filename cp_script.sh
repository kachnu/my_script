#!/bin/bash

SOURSE_DIR="."
REMOTE_DIR="$HOME/mydistr/mydistr_root/usr/local/bin"
for SOUR in `ls $SOURSE_DIR`; do
    for REM in `ls $REMOTE_DIR`; do
        if [ "$REM" = "$SOUR" ]; then
           sudo cp "$SOURSE_DIR/$SOUR" "$REMOTE_DIR/$REM" && sudo chmod +x "$REMOTE_DIR/$REM"
           echo "new $REMOTE_DIR/$REM"
        fi
    done
done

echo ""
echo "Push Enter"
read x

exit 0
