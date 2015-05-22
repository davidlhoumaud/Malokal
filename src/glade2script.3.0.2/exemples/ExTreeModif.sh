#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################
btn_selection()
{
#echo 'SET@treeview1.set_cursor(2)'
echo 'TREE@@FINDSELECT@@treeview1@@1@@Tree'
}
btn_up_com()
{
echo "TREE@@UP@@treeview1"
}
btn_down_com()
{
echo "TREE@@DOWN@@treeview1"
}
function treeview1()
{
num_ligne=$(cut -d '@' -f1 <<< $1)
echo "SET@_entry_ligne.set_text('''$(cut -d '@' -f1 <<< $@ --complement)''')"
}

function btn_supp1()
{
echo "TREE@@CELL@@treeview1@@$num_ligne@@"
}
function btn_supp()
{
echo "TREE@@CELL@@treeview1@@@@"
}

function _entry_ligne()
{ # cette fonction est appelé depuis le bouton grace a user data, cela permet d'éviter GET@
echo "TREE@@CELL@@treeview1@@$num_ligne@@$@"
}
function _spin_col()
{
echo "GET@_spin_col.get_value()"
}
function _spin_line()
{
echo "GET@_spin_line.get_value()"
}
function _entry_cell()
{ # cette fonction est appelé depuis le bouton grace a user data, cela permet d'éviter GET@
spin_line=$(cut -d '.' -f1 <<< $_spin_line_get_value)
spin_col=$(cut -d '.' -f1 <<< $_spin_col_get_value)
echo col $_spin_col_get_value
echo "TREE@@CELL@@treeview1@@$spin_line,$spin_col@@$1"
}
>  /tmp/treeview.txt
n=0
ls -1 | while read ligne
do
#echo "gtk-yes|$ligne|bold|$n" >> /tmp/treeview.txt
echo "TREE@@INSERT@@treeview1@@$n@@gtk-yes|$ligne|bold|$n"
n=$((n+1))
done
#echo "TREE@@LOAD@@treeview1@@/tmp/treeview.txt"

#charger les variables des spin car si pas changées et clic pour modif cellule,
# les variables pas chargé, donc bug
echo "GET@_spin_col.get_value()"
echo "GET@_spin_line.get_value()"




##########################################################################################
while read ligne; do
    if [[ "$ligne" =~ GET@ ]]; then
       eval ${ligne#*@}
       #echo "DEBUG => in boucle bash :" ${ligne#*@}
    else
       #echo "DEBUG=> in bash NOT GET" $ligne
       $ligne
   fi 
done < <(while true; do
    read entree < $FIFO
    [[ "$entree" == "QuitNow" ]] && break
     echo $entree   
done)
exit
