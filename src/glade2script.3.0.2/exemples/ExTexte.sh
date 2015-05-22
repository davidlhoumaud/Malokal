#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
######################################################################################################

## Déclaration des fonctions

btn_insert(){ # Insert les balises <u> </u> autour de la sélection
        echo 'TEXT@@AUTOUR@@_textview1@@<u>@@</u>'
}

_filechoose(){ # Récupère le fichier sélectionné
        # SIGNAL => selection-changed
        # CALLBACK => on_clicked
        echo 'GET@_filechoose.get_filename()'
}

btn_load(){ # Charge le fichier
        echo "TEXT@@LOAD@@_textview1@@$_filechoose_get_filename"
}

btn_save(){ # Enregistre le treeview (fichier chargé, avec modif eventuelle) dans une variable
        echo "COLOR@@eventbox1.modify_bg@@gtk.STATE_NORMAL@@red
COLOR@@_filechoose.modify_bg@@gtk.STATE_NORMAL@@red
TEXT@@HIZO@@_textview1"
}

_textview1(){
        echo "_______$@"
}

######################################################################################################
#set -f
while read ligne; do
    if [[ "$ligne" =~ GET@ ]]; then
       eval ${ligne#*@}
       echo "DEBUG => in boucle bash :" ${ligne#*@}
    else
       echo "DEBUG=> in bash NOT GET" $ligne # ${ligne/\*/\\\*}
       #${ligne/\*/\\\*} #
       $ligne
   fi
done < <(while true; do
    read entree < $FIFO
    [[ "$entree" == "QuitNow" ]] && break
     echo $entree
done)
exit
