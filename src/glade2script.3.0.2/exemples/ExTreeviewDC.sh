#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
######################################################################################################
# le callback on_clicked à été renseigné pour le signal cursor-changed du montree 
function montree()
{
pre_arg=$( cut -d '@' -f1 <<< ${@})
arg=$( cut -d '@' -f1 --complement <<< ${@})
if [[ "$pre_arg" == "hizo" ]]; then
     ligne_tree=$(sed 's/@@/\n/g' <<< $arg)
     while read ligne
          do
               echo "TREE@@END@@montree@@retour de $ligne"
               sleep 0.2
          done <<< "$ligne_tree"
elif [[ "$pre_arg" == "double_clic" ]]; then
       echo 'EXIT@@SAVE'
fi
}
button1()
{ # Lance la commande pour récupérer le tree dans l'environnement, 
   # la fonction montree sera apellé avec l'intégralité du tree en argument, séparateur de ligne @@
echo "TREE@@HIZO@@montree"
}

_entry1()
{
if [[ "${@%%@*}" == "clicked" ]]; then
    echo "SET@_entry1.set_text('')"
else
    echo "TREE@@END@@montree@@${@#*@}"
    echo "SET@_entry1.set_text('')"
fi
}

######################################################################################################
while read ligne; do
    if [[ "$ligne" =~ GET@ ]]; then
       eval ${ligne#*@}
       echo "DEBUG => in boucle bash :" ${ligne#*@}
    else
       echo  "DEBUG=> in bash NOT GET $ligne"
       $ligne
   fi
done < <(while true; do
    read entree < $FIFO
    [[ "$entree" == "QuitNow" ]] && break
     echo $entree
done)
exit