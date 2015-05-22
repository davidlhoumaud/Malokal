#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
######################################################################################################

## Définition des fonctions

_entry1(){
        # Il est tout à fait possible d'utiliser deux icones actives sur un entry
        # SIGNAL => icon_press
        # CALLBACK => on_entry
        # De cette façon, il ne reste plus qu'à filtrer le retour.

        case ${1%@*} in
                primary) # Première icone
                        echo "SET@_entry1.set_text('')" ;;
                secondary) # Seconde icone
                        echo "SET@_entry1.set_text('Surprise !')" ;;
                        *) # Quitte glade2script en conservant les variables (utilisation statique)
                        echo 'EXIT@@SAVE'
        esac
}

btn_no(){ # Quitte glade2script
        echo 'EXIT@@'
}
echo "SET@window1.connect('draw', self.expose)"
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
