#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

##############################
### À savoir sur les menus ###
##############################

## 1) Glade
# >>> Créer un menu contextuel (pas besoin de rajouter un _ devant le nom, menu1 par exemple).
# >>> Utiliser le callback on_menu avec le signal button-press-event sur le widget d'appel de votre menu.
# >>> Ajouter le nom du menu à ouvrir en données utilisateurs (à droite du callback).

# SIGNAL => button_press_event
# CALLBACK => on_menu
# DONNEES UTILISATEUR => Nom du menu

## 2) Gui
# >>> Pour appeller le menu, il suffit d'un clic droit sur le widget où le callback est défini.

# ACTION=Clic droit

### ATTENTION ###
# Certains widgets ne possède pas de signal (frame, progressbar ... par exemple), ce qui veux dire que les callbacks n'ont pas d'effet.
# Pour remédier à cela, il suffit de rajouter une boite d'évènement sur le widget et de renseigner le callback sur cette boite au lieu du widget d'origine.

#############################################################################################

## Définition des variables
font='Monospace'
color='black'
back='white'


## Définition des fonctions

################
### MENULIST ###
################

# SIGNAL => activate
# CALLBACK => on_clicked

ModifCouleur(){ # Modifie la couleur en fonction du menuitem sélectionné
        echo "SET@_label_list.set_markup('''<span foreground='$1'>MENULIST</span>''')"
}

_menuitem1(){ # Fonction relié au menuitem1 du menu1
        ModifCouleur red
}

_menuitem2(){ # Fonction relié au menuitem2 du menu1
        ModifCouleur black
}

_menuitem3(){ # Fonction relié au menuitem3 du menu1
        ModifCouleur '#C07474'
}

#################
### CHECKMENU ###
#################

# SIGNAL => toggled
# CALLBACK => on_toggled
# RETOUR => True/False

# Si le retour = True alors la case est coché, sinon elle est décoché.

ModifFont(){ # Modifie la police, la couleur, ou la couleur de fond, en fonction de l'état (Coché/Décoché) du checkmenuitem sélectionné
        echo "SET@_label_check.set_markup('''<span font-family='$font' background='$back' foreground='$color'>CHECKMENU</span>''')"
}

_checkmenuitem1(){ # Modifie la police
        [[ $1 == True ]] && font='FreeMono' || font='Monospace'
        ModifFont
}

_checkmenuitem2(){ # Modifie la couleur
        [[ $1 == True ]] && color='red' || color='black'
        ModifFont
}

_checkmenuitem3(){ # Modifie la couleur de fond
        [[ $1 == True ]] && back='yellow' || back='white'
        ModifFont
}

#################
### MENURADIO ###
#################

# SIGNAL => toggled
# CALLBACK => on_toggled
# RETOUR => True/False

# Si le retour = True alors le radiomenuitem est sélectionné, sinon non.

ModifLabel(){ # Modifie le label en fonction du radiomenuitem sélectionné
        echo "SET@_label_frame.set_text('$1')"
}

_radiomenuitem1(){
        [[ $1 == True ]] && ModifLabel radio1
}

_radiomenuitem2(){
        [[ $1 == True ]] && ModifLabel radio2
}

_radiomenuitem3(){
        [[ $1 == True ]] && ModifLabel radio3
}


## Début du script

# Appel de la fonction ModifFont avec les variables définits plus haut.
ModifFont

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
