#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

### Définition des fonctions

button1(){ # Afifiche le bouton
        echo "SET@_button2.show()"
}

_button2(){ # Cache le bouton
        echo "SET@_button2.hide()"
}


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
