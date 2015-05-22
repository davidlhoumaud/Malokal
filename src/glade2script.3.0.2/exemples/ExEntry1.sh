#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
######################################################################################################
function btn_ok()
{ # Quitte glade2script en concervant les variables
    echo 'EXIT@@SAVE'
} 
function _btn_no()
{ # Quitte glade2script
    echo 'EXIT@@'
}
function btn_exec()
{       
    # Récupère le contenue de l'entrée, puis va faire un tour dans la boucle
    # afin d'inclure la variable dans l'environnement, la fonction Affich est
    # ensuite appellé.
    echo 'GET@_entry1.get_text()'
    echo 'ITER@@Affich'
}
function Affich()
{
    # La variable $_entry1_get_text (qui contient le contenue de l'entrée), est
    # ainsi disponnible pour une utilisation future.
    # On parle alors d'utilisation dynamique
    echo 'SET@_label1.set_markup("<b><big>'$_entry1_get_text'</big></b>")'
}
function _entry1 ()
{
if [[ "$1" == "clicked" ]]; then
    echo 'SET@_entry1.set_text("")'
    echo 'COLOR@@_entry1@@modify_text@@gtk.STATE_NORMAL@@#000000'
    echo 'COLOR@@_entry1@@modify_base@@gtk.STATE_NORMAL@@#FFFFFF'   
    echo 'COLOR@@window@@modify_bg@@gtk.STATE_NORMAL@@red'   
fi
}
sleep 0.5
echo 'COLOR@@_entry1@@modify_text@@gtk.STATE_NORMAL@@white'
echo 'COLOR@@_entry1@@modify_base@@gtk.STATE_NORMAL@@red'
#echo 'SET@window.show()'
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
