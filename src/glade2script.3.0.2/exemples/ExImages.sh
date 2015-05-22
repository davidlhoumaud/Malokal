#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

## Définition des fonctions

########################
### MODIF ICON-STOCK ###
########################

_combobox1(){ # Récupère le contenue actif du combobox
        combobox1_img=$@
    ChangeIcons $@ stock
}

ModifIcons(){ # Appel la fonction ChangeIcons avec la variable récupérée (contenue actif du combobox) en argument
        ChangeIcons $_combobox1_img stock
}

######################
### MODIF ICON-NAME ##
######################

treeview1(){ # Appel la fonction ChangeIcons avec le retour de la sélection du treeview
        arg=$(cut -d '@' -f1 --complement <<< $@)

        ChangeIcons "'$(cut -d '|' -f1 <<< $arg)'" icon_name
}

####################
### CHANGE ICONS ###
####################

ChangeIcons(){
        lab=${1//\'/}

        echo "SET@_img_$2.set_from_$2($1, Gtk.IconSize.BUTTON)
SET@_img_size1.set_from_$2($1, Gtk.IconSize.MENU)
SET@_img_size2.set_from_$2($1, Gtk.IconSize.SMALL_TOOLBAR)
SET@_img_size3.set_from_$2($1, Gtk.IconSize.LARGE_TOOLBAR)
SET@_img_size4.set_from_$2($1, Gtk.IconSize.BUTTON)
SET@_img_size5.set_from_$2($1, Gtk.IconSize.DND)
SET@_img_size6.set_from_$2($1, Gtk.IconSize.DIALOG)
SET@_label_$2.set_markup('<b>$lab</b>')"
}

######################
### MODIF _IMG_TUX ###
######################

_event_150(){ # Redimensionne l'image
        # SIGNAL => enter-notify-event
        # CALLBACK => entern-notify-event

        # Permet d'agir au passage de la souris sur le widget

        echo "IMG@@_img_tux@@tux.png@@150@@150"
}

_event_75(){
        echo "IMG@@_img_tux@@tux.png@@75@@75"
}

_event_32(){
        echo "IMG@@_img_tux@@tux.png@@32@@32"
}

#######################
### CREE LISTE ICON ###
#######################

btn_cree_liste(){
        echo "SET@_progressbar1.show()" # Affiche la progressbar

        [ -e ./icon_liste_gnome.txt ] && {
        rm ./icon_liste_gnome.txt

        echo "TREE@@CLEAR@@treeview1" # Vide le treeview
        n=0
        }

        while read ligne; do
                [[ "$n" =~ '0' ]] && echo "SET@_progressbar1.set_text(' Icons : $n ')
SET@_progressbar1.pulse()" # Envoie d'informations dans la progressbar et fais pulser la barre

                sleep 0.01

                echo "$ligne" >> ./icon_liste_gnome.txt
                n=$((n+1))
        done < <(find /usr/share/icons/gnome -name "*.png" ! -lname "*.png" -printf "%f|%f|normal\n" | sed 's/.png//g' | sort -u)

        echo "SET@_progressbar1.set_text('')
TREE@@LOAD@@treeview1@@icon_liste_gnome.txt" # Charge le fichier précédement créer, dans le treeview

        sleep 0.5

        echo "SET@_progressbar1.hide()" # Cache la progressbar
}


## Début du script

echo "SET@_img_icon_name.set_from_icon_name('gtk-yes', Gtk.IconSize.BUTTON)
IMG@@_img_tux@@tux.png@@150@@150"

ChangeIcons Gtk.STOCK_PREFERENCES stock
[ -e ./icon_liste_gnome.txt ] && echo 'TREE@@LOAD@@treeview1@@icon_liste_gnome.txt'

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
