#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

### Déclaration des fonctions

btn_go(){
        for n in {0..50}; do
                echo  "TEXT@@END@@_textview1@@Ligne $n du log ...\\n" # Ajoute chaque ligne l'une en dessous de l'autre
                sleep 0.01
        done

        echo "TEXT@@END@@_textview1@@Terminé !\\n" # Ajoute une dernière ligne
}

btn_clear(){ # Efface la dernière ligne
        echo "TEXT@@DELEND@@_textview1"
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
