#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################
            
chemin="$(cd "$(dirname "$0")";pwd)"
echo $chemin
###Pour exporter la librairie de gettext.
set -a
source gettext.sh
set +a
export TEXTDOMAIN=Test    # ici le nom du .mo, .glade, ....
export TEXTDOMAINDIR="${chemin}/locale"
. gettext.sh
chargetextview() {
    for i in {0..1000}
      do
	echo "TEXT@@END@@_textview@@oueehh\n"
        sleep 0.2
      done
    echo "TIMER@@STOP@@refresh"
}
refresh() {
    echo  'SET@_progress.pulse()'
    echo "GET@myvar"
}
button1() {
echo 'GEO@@GET@@window1'
echo 'GET@window1.get_position()'
}
#echo "TIMER@@START@@100@@refresh"
#chargetextview &
echo "EXEC@@self.gui.myvar='yesss'"
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
