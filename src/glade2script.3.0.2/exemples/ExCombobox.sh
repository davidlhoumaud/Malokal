#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

#################################
### À savoir sur les combobox ###
#################################

## 1) Glade
# >>> Créer un combobox ou un comboboxentry (pas besoin de rajouter un _ devant le nom, exemple combobox1)
# >>> Utiliser le callback on_combo avec le signal changed, si vous voulez agir lors d'un changement d'item.

# SIGNAL => changed
# CALLBACK => on_menu

## 2) Script d'appel (go_*)
# >>> Afin de pouvoir utiliser des images ou icones dans les combobox, il faut les déclarer au lancement de glade2script (voir le fichier go_ExCombobox.sh)

### ATTENTION ###
# Vous n'êtes pas obligé de déclarer les combobox, dans ce cas, vous ne pourrez pas utiliser d'icones ou d'images
# Il existe deux bug dans glade avec les combobox, voir la doc pour plus d infos.

#############################################################################################

## Définition des fonctions

window1(){ # Quitte glade2script en conservant les variables
        echo 'EXIT@@SAVE'
}

#################
### COMBOBOX1 ###
#################

btn_first(){ # Supprime la première entrée du combobox1
        echo "SET@combobox1.remove_text(0)
SET@combobox1.set_active(0)"
}

btn_last(){ # Supprime la dernière entrée du combobox1
        echo "COMBO@@DELEND@@combobox1
SET@combobox1.set_active(0)"
}

btn_clear(){ # Vide les deux combobox
        echo "COMBO@@CLEAR@@combobox1,combobox2"
}

_entry_ajout(){ # Ajoute le contenu de l'entry, avec une icone, dans le combobox1
        # WIDGET => btn_ajout
        # SIGNAL => clicked
        # CALLBACK => on_entry
        # DONNEE UTILISATEUR => _entry_ajout
        # RETOUR = Contenue de l'entry

        # Permet, lors d'un clic sur le bouton Ajouter (btn_ajout), de récupérer le contenue de l'entrée (_entry_ajout).

        echo "COMBO@@END@@combobox1@@<i><b>$@</b></i>|gtk-find
COMBO@@FINDSELECT@@combobox1@@<i><b>$@</b></i>$"

        # À noter l'utilisation d'une ER (expression régulière, $), en fin de commande, pour ne pas avoir de mauvaise surprise !
}

#################
### COMBOBOX2 ###
#################

btn_add(){ # Ajoute un item, avec image, dans le combobox2
        echo "COMBO@@IMG@@combobox2@@<i><b>item3</b></i>|tux2.jpg|30
COMBO@@FINDSELECT@@combobox2@@<i><b>item3</b></i>$"

        # À noter la taille de l'image (modifiable à souhait) en fin de première commande.
}
combobox2() {
	:
}

## Début du script

# Active les premières entrées des deux combobox (les valeurs par defaut dans glade ne fonctionne pas)
echo "MULTI@@SET@@set_active(0)@@combobox1,combobox2"

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
