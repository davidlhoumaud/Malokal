#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
######################################################################################################

## Définition des fonctions

eventbox1(){
        echo "STATUS@@statusbar1@@Survol de l'image"
}

eventbox2(){
        echo "STATUS@@statusbar1@@Survol du texte"
}

_entry1(){
        echo "STATUS@@statusbar1@@Survol de l'entry"
}

button1(){
        echo "STATUS@@statusbar1@@Survol du bouton"
}

######################################################################################################
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

