#!/bin/bash

cd "$(dirname "$0")"

error_apt ()
{
echo -e "

The list of packages is not updated.
Packages are not installed.
Check your network connection and try again.

Press Enter to exit"
read x

exit 1
}
sudo apt-get update || error_apt
sudo dpkg -i *.deb
sudo apt-get -y install -f

echo "Press Enter to exit"
read x

exit 0
