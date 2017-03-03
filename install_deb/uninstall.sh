#!/bin/bash

cd "$(dirname "$0")"

DEB_LIST=`ls *.deb`
UNINSTALL_LIST=""

for DEB in $DEB_LIST; do
  PACKAGE=`dpkg -I $DEB | grep -m1 Package: | awk '{print $2}'`
  if [[ `dpkg -l $PACKAGE ` ]]; then
     UNINSTALL_LIST=$UNINSTALL_LIST" "$PACKAGE 
  fi
done

if [ -z ${UNINSTALL_LIST// /} ]; then 
   echo ""
   echo "Nothing to remove!"
   echo ""
   echo "Press Enter to exit"
   read x
   exit 0
fi

echo "Purge list: $UNINSTALL_LIST"

sudo apt-get -y purge $UNINSTALL_LIST
sudo apt-get -y autoremove

echo "Press Enter to exit"
read x

exit 0
