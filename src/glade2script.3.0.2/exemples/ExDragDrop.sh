#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

## Définition des fonctions

################
### EVENTBOX ###
################

# L'utilisation de boites d'évènements (eventbox) est nécessaire içi, car les images et les labels ne
# possèdent pas de signaux.


eventbox1()
{ # Affiche la sélection du treeview dans l'eventbox1
[[ "$1" =~ ^drop@ ]] && echo "SET@_label_modif.set_text('''$(cut -d '@' -f1 --complement <<< $@)''')"
echo 'ok'
}
eventbox2()
{ # Affiche l'image droppé dans l'eventbox2
if [[ "$1" =~ ^drop@ ]]; then
    path=$(sed 's@.*file://@@' <<< $1)
    echo "IMG@@_image1@@$path@@100@@100"
fi
echo 'ok'
}

################
### TREEVIEW ###
################

treeview1()
{ # Informe la barre de statut de l'élément droppé
echo "STATUS@@statusbar1@@treeview1 $@"
}
treeview2()
{ # Informe la barre de statut de l'élément droppé
echo "STATUS@@statusbar1@@treeview2 $@"
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
