#!/bin/bash
# управление плеерами следующая/предидущая песня, пауза, дабавить в плейлист и т.д.
# author: kachnu
# email: ya.kachnu@yandex.ua

# в системе должен быть установлен zenity

# список плееров
players_list="audacious mocp deadbeef"

# функция обработки moc
func_deadbeef ()
{
if [[ `which deadbeef` ]]; then
   deadbeef=$(which deadbeef)
   else deadbeef="/opt/deadbeef/bin/deadbeef"
fi

case $1 in
     -a|--append) folder=`zenity --file-selection --directory --title="Select folder"`
                  if [ $? == 0 ]; then
                      $deadbeef --queue "$folder"
                  fi;;
     -r|--previous) $deadbeef --prev;;
     -n|--next) $deadbeef --next;;
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
     -a|--append) folder=`zenity --file-selection --directory --title="Select folder"`
                  if [ $? == 0 ]; then
                      mocp -a "$folder"
                  fi;;
     -r|--previous) mocp -r;;
     -n|--next) mocp -f;;
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
     -a|--append) folder=`zenity --file-selection --directory --title="Select folder"`
                  if [ $? == 0 ]; then                 
                     audacious -e "$folder"
                  fi;;
     -r|--previous) audacious -r;;
     -n|--next) audacious -f;;
     -t|--play-pause) audacious -t;;
     -p|--play) audacious -p;;
     -s|--stop) audacious -s;;
     -q|--quit) killall audacious;;
      *) echo "$HELP"; exit;;
esac
}

HELP="$0 - script to manage players. 
Usage:
  $0 [KEY]

Keys:
  -a, --append 			Append the files/directories/playlists
  -r, --previous 		Play the pRevious song
  -n, --next 			Play the Next song
  -t, --play-pause 		Toggle between playing and paused
  -p, --play 			Start Playing from the first item on the playlist
  -s, --stop 			Stop playing
  -q, --quit			Quit player (kill)
"

# формирование запущенных плееров
run_players=""
for pl in $players_list; do
   if [[ `pidof $pl` ]]; then
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
         -n|--next) ACT="NEXT";;
         -t|--play-pause) ACT="PAUSE";;
         -p|--play) ACT="PLAY";;
         -s|--stop) ACT="STOP";;
         -q|--quit) ACT="KILL";;
         *) echo "$HELP"; exit;;
     esac
     run_players=`echo "$run_players" | sed "s/^ //g" | sed "s/ /\\\n/g" | zenity --list --title="select player" \
                --text="$ACT" --column="" --separator="\n"`
     func_${run_players// /} $1;;
esac

exit 0
