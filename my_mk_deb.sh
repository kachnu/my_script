#!/bin/bash
FOLDER_LIST=""
for FOLDER in "$@"
    do
       if [ -d "$FOLDER/DEBIAN" ]
          then cd "$FOLDER"
               IFS=$'\n'
               md5sum `find . -type f | grep -v '^[.]/DEBIAN/'` > DEBIAN/md5sums 
               cd ..         
               if [ `which fakeroot` ]
                 then fakeroot dpkg -b "$FOLDER" || read x
                 else echo need enter root password
                      sudo chown -R root:root "$FOLDER"
                      sudo dpkg -b "$FOLDER" || read x
                      sudo chown -R $USER:$USER "$FOLDER"
               fi       
          else echo "-----------------------"
               echo "$FOLDER - is not debian folder!"
               echo "-----------------------"
               echo "turn Enter to contine"
               read x
       fi
done

exit 0
