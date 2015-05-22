#!/bin/bash
##############################################################################################
if [[ $1 != 1 ]]; then
    cd "$( cd "$(dirname $0)"; pwd )"
    ./Malokal -g ./malokal.glade -s "$0 1" -d --gtkbuilder --webkit='jamendo,_box_jamendo'  -t '@@tw_library@@ICON%%2|Track%%editable|Titre%%editable|Album%%editable|Artist%%editable|Genre%%editable|Année%%editable|Durée|HIDE|FadeIn%%editable|FadeOut%%editable' -t '@@tw_current@@|Track%%editable|Titre%%editable|Album%%editable|Artist%%editable|Genre%%editable|Année%%editable|Durée|HIDE|FadeIn%%editable|FadeOut%%editable' -t '@@tw_calendar_days@@Diffusion%%editable|Playlist%%editable|Mode%%editable'
    exit
fi
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
###############################################################################################
#Initialisation des scripts
. includes/fileconfig.inc
. includes/library.inc
. includes/calendar.inc
. includes/current.inc
. includes/preview.inc
. includes/player.inc
. includes/systray.inc
. includes/gui_basic.inc
. includes/mode.inc
. includes/pref_malokal.inc
. includes/pref_odyo.inc
. includes/init.inc
echo "TREE@@LOAD@@tw_library@@library.tvl"
##########################################################################################
while read ligne; do
    if [[ "$ligne" =~ GET@ ]]; then
       eval ${ligne#*@}
       echo "DEBUG => in boucle bash :" ${ligne#*@}
    else
       echo "DEBUG=> in bash NOT GET" $ligne
       $ligne
   fi 
done < <(while true; do
    read entree < $FIFO
    [[ "$entree" == "QuitNow" ]] && break
     echo $entree   
done)
exit
