#!/bin/bash
# управление плеерами следующая/предидущая песня, пауза, дабавить в плейлист и т.д.
# author: kachnu
# email: ya.kachnu@yandex.ua

# в системе должен быть установлен yad или zenity
DIALOG=yad
if ! [[ `which $DIALOG` ]]
   then DIALOG=zenity
fi

# список плееров
players_list="audacious mocp deadbeef clementine banshee rhythmbox amarok"

# функция обработки amarok
func_amarok ()
{
case $1 in
     -a|--append) folder=`$DIALOG --file-selection --directory --title="Add to playlist"`
                  if [ $? == 0 ]; then                 
                     amarok -a "$folder"
                  fi;;
     -r|--previous) amarok -r;;
     -f|--next) amarok -f;;
     -t|--play-pause) amarok -t;;
     -p|--play) amarok -p;;
     -s|--stop) amarok -s;;
     -q|--quit) killall amarok;;
      *) echo "$HELP"; exit;;
esac
}

# функция обработки rhythmbox
func_rhythmbox ()
{
case $1 in
     -a|--append) folder=`$DIALOG --file-selection --directory --title="Add to playlist"`
                  if [ $? == 0 ]; then
                      rhythmbox-client --enqueue "$folder"
                  fi;;
     -r|--previous) rhythmbox-client --previous;;
     -f|--next) rhythmbox-client --next;;
     -t|--play-pause) rhythmbox-client --play-pause;;
     -p|--play) rhythmbox-client --play;;
     -s|--stop) rhythmbox-client--stop;;
     -q|--quit) killall rhythmbox;;
      *) echo "$HELP"; exit;;
esac
}

# функция обработки banshee
func_banshee ()
{
case $1 in
     -a|--append) $DIALOG --info --title="Attention" --text="Not supported add files";;
     -r|--previous) banshee --previous;;
     -f|--next) banshee --next;;
     -t|--play-pause) banshee --toggle-playing;;
     -p|--play) banshee --play;;
     -s|--stop) banshee --stop;;
     -q|--quit) killall banshee;;
      *) echo "$HELP"; exit;;
esac
}

# функция обработки clementine
func_clementine ()
{
case $1 in
     -a|--append) folder=`$DIALOG --file-selection --directory --title="Add to playlist"`
                  if [ $? == 0 ]; then
                       clementine -a "$folder"
                  fi;;
     -r|--previous) clementine -r;;
     -f|--next) clementine -f;;
     -t|--play-pause) clementine -t;;
     -p|--play) clementine -p;;
     -s|--stop) clementine -s;;
     -q|--quit) killall clementine;;
      *) echo "$HELP"; exit;;
esac
}

# функция обработки deadbeef 
func_deadbeef ()
{
if [[ `which deadbeef` ]]; then
   deadbeef=$(which deadbeef)
   else deadbeef="/opt/deadbeef/bin/deadbeef"
fi

case $1 in
     -a|--append) folder=`$DIALOG --file-selection --directory --title="Add to playlist"`
                  if [ $? == 0 ]; then
                      $deadbeef --queue "$folder"
                  fi;;
     -r|--previous) $deadbeef --prev;;
     -f|--next) $deadbeef --next;;
     -t|--play-pause) $deadbeef --toggle-pause;;
     -p|--play) $deadbeef --play;;
     -s|--stop) $deadbeef --stop;;
     -q|--quit) kill $(pidof deadbeef);;
      *) echo "$HELP"; exit;;
esac
}

# функция обработки moc
func_mocp ()
{
case $1 in
     -a|--append) folder=`$DIALOG --file-selection --directory --title="Add to playlist"`
                  if [ $? == 0 ]; then
                      mocp -a "$folder"
                  fi;;
     -r|--previous) mocp -r;;
     -f|--next) mocp -f;;
     -t|--play-pause) mocp -G;;
     -p|--play) mocp -p;;
     -s|--stop) mocp -s;;
     -q|--quit) killall mocp;;
      *) echo "$HELP"; exit;;
esac
}

# функция обработки audacious
func_audacious ()
{
case $1 in
     -a|--append) folder=`$DIALOG --file-selection --directory --title="Add to playlist"`
                  if [ $? == 0 ]; then                 
                     audacious -e "$folder"
                  fi;;
     -r|--previous) audacious -r;;
     -f|--next) audacious -f;;
     -t|--play-pause) audacious -t;;
     -p|--play) audacious -p;;
     -s|--stop) audacious -s;;
     -q|--quit) killall audacious;;
      *) echo "$HELP"; exit;;
esac
}

HELP="$0 - script to manage players.

Work whith players:
  $players_list

Usage:
  $0 [KEY]

Keys:
  -a, --append 		Append the files/directories/playlists
  -r, --previous 	Play the previous song
  -f, --next 		Play the next song
  -t, --play-pause 	Toggle between playing and paused
  -p, --play 		Start playing from the first item on the playlist
  -s, --stop 		Stop playing
  -q, --quit		Quit player (kill)
"

# формирование списка запущенных плееров
run_players=""
for pl in $players_list; do
   if [[ `pgrep -u $USER  $pl` ]]; then
     run_players="$run_players $pl"
   fi
done

# если нет запушенных плееров - выходим, если их несколько - даем возможность выбрать к какому именно плееру относится действие
case `echo $run_players | awk '{print NF}'` in
  0) echo "not run player"; exit 1;;
  1) func_${run_players// /} $1;;
  *) case $1 in
         -a|--append) ACT="ADD FOLDER";;
         -r|--previous) ACT="PREVIOUS";;
         -f|--next) ACT="NEXT";;
         -t|--play-pause) ACT="PAUSE";;
         -p|--play) ACT="PLAY";;
         -s|--stop) ACT="STOP";;
         -q|--quit) ACT="KILL";;
         *) echo "$HELP"; exit;;
     esac
     run_players=`echo "$run_players" | sed "s/^ //g" | sed "s/ /\\\n/g" | $DIALOG --list --title="select player" \
                --text="$ACT" --column="" --separator="\n"`
     func_${run_players// /} $1;;
esac

exit 0
