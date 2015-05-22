#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################
function treeview1()
{ # $@=double_clic@line@data|data
pre_arg=$(cut -d '@' -f1 <<< $@)
if [[ "$pre_arg" == "double_clic" ]]; then
    row=$(cut -d '@' -f2 <<< $@)
    ActiveTree $row &
fi
}

function button1()
{
echo "TREE@@SAVE@@treeview1@@/tmp/test"
}
sp=65
function ActiveTree()
{
echo "TREE@@CELL@@treeview1@@$1,3@@italic"
for nb in {1..100}
do
[[ "$nb" =~ "0" ]] && sp=$((sp+5))
[[ "$sp" == "95" ]] && sp=40
echo "TREE@@CELL@@treeview1@@$1,1@@$sp k/s"
echo "TREE@@PROG@@treeview1@@$1,2@@$nb"
sleep 0.2
done
echo "TREE@@CELL@@treeview1@@$1,3@@FreeMono italic 8"
echo "TREE@@CELL@@treeview1@@$1,1@@.. k/s"
}
n=0
rm /tmp/liste_tree
ls -1 | while read ligne
do
 echo "$ligne|0 K/s|0|normal|$n|$n" >> /tmp/liste_tree
  n=$((n+1))
  [[ "$n" == "10" ]] && break
done
echo "TREE@@LOAD@@treeview1@@/tmp/liste_tree"



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
