#Zenity progress bar dialog
(
gksudo -- sh -c "
echo '#apt-get update'
apt-get update
echo '#apt-get install -y vino'
apt-get install -y vino
if [ $? = 0 ] 
   then echo '#All be done!'
   else echo '#Some Error!'
fi
sleep 3"
) | zenity --progress --pulsate --auto-close \
--title "Installing vino"

