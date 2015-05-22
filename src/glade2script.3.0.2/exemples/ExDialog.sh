#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

## Définition des fonctions

button_ok_filechoose()
{ # Récupère le chemin complet de la sélection
    echo "GET@filechooserdialog1.get_filename()"
}

button3()
{ # Change le numéro de version
echo "SET@Glade2script.set_version('2.01')"
}

_filechooserdialog1()
{ # Affiche le chemin de la sélection en cours
    # WIDGET => _filechooserdialog1
    # SIGNAL => file-activated
    # CALLBACK => on_clicked
    # DONNEE UTILISATEUR => button_ok_filechoose

    # Un double clic sur la sélection appel la fonction button_ok_filechoose,
    # permet d'avoir le même comportement que le bouton de validation.
    if [[ "$1" = "clicked" ]]; then
        echo "GET@_filechooserdialog1.get_filename()"   
    elif [[ "$1" = "my_callback" ]]; then  
        echo "SET@_entry2.set_text('''$selection''')"
    else
        selection=$(basename $@)
        echo "SET@_entry1.set_text('''$selection''')"
    fi
}
_colorsel_color_selection1()
{
    if [[ "$1" == "clicked" ]]; then
        # Colore l'entrée avec la couleur sélectionné
        echo "COLOR@@_entry_color@@override_background_color@@Gtk.StateFlags.NORMAL@@$color"
    else
        # Envoie la couleur sélectionné dans l'entée
        color=$1
        echo "SET@_entry_color.set_text('''$1''')"
    fi
}
_colorbutton1()
{
    echo "SET@_entry_color.set_text('''$1''')"
    echo "COLOR@@_entry_color@@override_color@@Gtk.StateFlags.NORMAL@@$1"
}

_recentchooserdialog1()
{
    # WIDGET => _recentchooserdialog1
    # SIGNAL => item-activated (double clic)
    # CALLBACK => my_callback (callback de remplacement, permet de filtrer le retour)
    # SIGNAL => selection-changed (simple clic)
    # CALLBACK => on_clicked

    # En fonction du type de sélection, le retour sera différent, de façon à filtrer la fonction.
    [[ "$1" == "my_callback" ]] && echo "SET@_entry_recent.set_text('''$_recentchooserdialog1_get_current_uri''')"
    echo "GET@_recentchooserdialog1.get_current_uri()"

}
_fontselectiondialog1()
{
if [[ "$1" == "clicked" ]]; then
     echo "SET@_label_font.set_markup('''<span font_desc='$font'>$font</span>''')"
:
else
    font="$@"
    echo "SET@_label_font.set_text('''$font''')"
fi
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
