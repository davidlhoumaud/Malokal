#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

################################
### À savoir sur les systray ###
################################

# 1) Glade
# >>> Créer un menu contextuel, que vous appeller my_systray (pas obligatoire, mais ça permet de le différencier des autres menus)

# 2) Script d appel (go_*)
# >>> Pour utiliser un systray, il faut le déclarer dans le script d'appel (voir le fichier go_ExSystray.sh)

# On peut utiliser une icone, mais aussi une image perso dans le systray.

##############################################################################################

systray(){ # Appelé lors du clic gauche sur le systray
        echo "TOGGLE@@VISIBLE@@window1" # Affiche/cache la fenêtre automatiquement
}

#btn_ajouter(){ # Affiche le systray
        # SIGNAL => clicked
        # CALLBACK => systray_show

        # Permet d'afficher le systray avec un callback, directement.
#}

#btn_enlever(){ # Cache le systray
        # SIGNAL => clicked
        # CALLBACK => systray_hide

        # Permet de cacher le systray avec un callback, directement.
#}

btn_no(){ # Modifie l'icone du systray
    echo "SET@systray.set_from_icon_name('gtk-no')"
    echo 'NOTIFY@@2@@Titre@@Ligne1\\n<b>Ligne2</b>\\n<i>Ligne3</i>@@dialog-yes'
}

_menuitem_icon(){ # Appel la fonction btn_yes
        btn_yes
}

btn_yes(){ # Modifie l'icone du systray
        echo "SET@systray.set_from_icon_name('gtk-yes')"
}

btn_tux(){ # Modifie l'image du systray
        echo "SET@systray.set_from_file('tux.png')"
}

btn_blink(){ # Fait clignoter le systray
        echo "SET@systray.set_blinking(True)"
}

btn_stop(){ # Stop le clignotement du systray
        echo "SET@systray.set_blinking(False)"
}

btn_bulle(){ # Modifie la bulle d'information du systray
        echo "SET@systray.set_tooltip('''Nouvelle bulle d'information''')"
}

_menuitem_info(){ # Appel la fonction btn_bulle
        btn_bulle
}

btn_quit(){ # Quitte glade2script
        echo "EXIT@@"
}


## Début du script

echo "IMG@@_img_tux@@tux.png@@34@@34"


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
