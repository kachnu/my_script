#!/bin/bash
FOLDER_LIST=""
for FOLDER in "$@"
    do
       if [ -d "$FOLDER/DEBIAN" ]
          then echo need enter root password
               sudo chown -R root:root "$FOLDER"
               sudo dpkg -b "$FOLDER"
               sudo chown -R $USER:$USER "$FOLDER"
          else echo "-----------------------"
               echo "$FOLDER - is not debian folder!"
               echo "-----------------------"
               echo "turn Enter to contine"
               read x
       fi
done

exit 0
