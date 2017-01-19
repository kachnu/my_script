#!/bin/bash
#Распаковка deb-пакетов

DEB_LIST=""
for DEB_FILE in "$@"
    do
       if [[ `echo $DEB_FILE | grep deb$` ]]
          then DEB_FOLDER=`echo "$DEB_FILE" | sed "s/.deb$//g"`
               echo "$DEB_FOLDER"
               dpkg -x "$DEB_FILE" "$DEB_FOLDER"
               mkdir "$DEB_FOLDER/DEBIAN"
               dpkg -e "$DEB_FILE" "$DEB_FOLDER/DEBIAN"
          else echo "-----------------------"
               echo "$DEB_FILE - is not deb-file!"
               echo "-----------------------"
               echo "turn Enter to contine"
               read x
       fi
done
exit 0
