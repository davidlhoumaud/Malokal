#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
###############################################################################################################
function treeview1()
{ #arg=sélection, num_l=numéro de la ligne
num_l=$(cut -d '@' -f1 <<< $1)
arg="$(cut -d '@' -f1 --complement <<< $@)"
echo "SET@_entry1.set_text('$arg')"
}
function treeview2()
{ #arg=sélection, num_l=numéro de la ligne
num_l=$(cut -d '@' -f1 <<< $1)
arg="$(cut -d '@' -f1 --complement <<< $@)"
echo "SET@_entry1.set_text('''$arg''')"
}
function treeview3()
{ #arg=sélection, num_l=numéro de la ligne
num_l=$(cut -d '@' -f1 <<< $1)
arg="$(cut -d '@' -f1 --complement <<< $@)"
echo "SET@_entry1.set_text('$arg')"
}





################################################################################################################
while read ligne; do
    if [[ "$ligne" =~ GET@ ]]; then
       eval ${ligne#*@}
       echo "DEBUG => in boucle bash :" ${ligne#*@}
    else
       echo "DEBUG => in bash NOT GET" $ligne
       $ligne
   fi 
done < <(while true; do
    read entree < $FIFO
    [[ "$entree" == "QuitNow" ]] && break
     echo $entree   
done)
exit
