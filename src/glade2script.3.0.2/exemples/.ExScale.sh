#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
######################################################################################################

############################
### Alternative au scale ###
############################

# Voiçi une alternative au scale avec une progressbar

# 1) Glade
# >>> Créer une progressbar et une boite d'évènement au dessus (pas de signal sur la progressbar)
# >>> Ajouter le callback get_pointer sur le signal button-press-event de la boite d'évènement.

# WIDGET => eventbox1
# SIGNAL => button-press-event
# CALLBACK => get_pointer

######################################################################################################

## Définition des fonctions

btn_ok(){ # Quitte glade2script en conservant les variables
        echo 'EXIT@@SAVE'
}

btn_no(){ # Quitte glade2script
        echo 'EXIT@@'
}

#############
### SCALE ###
#############

_hscale1(){ # Met à jour le scale avec le retour du callback value-changed
        value=$1

        echo "SET@_entry1.set_text('$value')
SET@_progressbar1.set_fraction($(bc <<< "scale=2; $value/100"))"
}

###################
### PROGRESSBAR ###
###################

eventbox1(){ # Récupère le retour de get_pointer (position du clic sur la boite d'évènement)
        pointer=${@#*@}; pointer=${pointer% *}

        echo "GET@_progressbar1.get_allocation()
ITER@@progress" # Récupère la taille de la progressbar (utile si la taille n'est pas statique)
}

progress(){
        set $_progressbar1_get_allocation
        value=$((( $pointer * 100 / ${3%?} ))) # Multiplie la valeur x du clic ($pointer) par 100 et divise le tous par la taille de la barre de progression

        echo "SET@_hscale1.set_value($value)
SET@_progressbar1.set_fraction($(bc <<< "scale=2; $value/100"))" # Met à jour le scale et la progressbar
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
