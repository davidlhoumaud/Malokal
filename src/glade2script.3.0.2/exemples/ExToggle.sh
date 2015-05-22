#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

## Définitions des fonctions

window1(){
echo "in widow $@"
}

_check1 (){ # Coche/décoche les checkbuttons automatiquement
echo 'TOGGLE@@ACTIVE@@_checkbutton1,_checkbutton2'
}

_checkbutton1(){
:
}

_checkbutton2(){
:
}

## Début du script

# Décoche les checkbutton
echo "MULTI@@SET@@set_active(False)@@_checkbutton1,_checkbutton2
MULTI@@GET@@get_active()@@_checkbutton1,_checkbutton2"

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
