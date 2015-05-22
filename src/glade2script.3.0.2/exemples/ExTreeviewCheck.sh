#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
######################################################################################################
function btn_apply()
{
echo EXIT@@SAVE
#echo TREE@@HIZO@@treeview1
#echo 'TREE@@FINDDEL@@treeview1@@2@@Téléchargements'
}
function btn_cancel()
{
echo EXIT@@
}
function btn_charger()
{
find $HOME -maxdepth 1 -type d -printf 'folder|gtk-yes|%f|False|False|%f|normal|\n' > ./treeview1.data
echo 'TREE@@LOAD@@treeview1@@treeview1.data'
}

function treeview1()
{
arg=$(cut -d '@' -f1 --complement <<< $@)
[[ "${@%%@*}" == "drop" ]] && return
[[ "${@%%@*}" == "radio" ]] && return
[[ "${@%%@*}" == "edit" ]] && return
[[ "${@%%@*}" == "combo" ]] && return
if [[ "${@%%@*}" == "toggled" ]]; then
   line=$(cut -d '@' -f2 <<< $@ | cut -d ',' -f1)
   if [[ "$(cut -d '|' -f4 <<< $@)" == "True" ]]; then
       echo "TREE@@CELL@@treeview1@@$line,6@@bold"
       return
   else
       echo "TREE@@CELL@@treeview1@@$line,6@@normal"
       return
   fi
elif [[ "${@%%@*}" == "clic" ]]; then
   path=$(cut -d '@' -f2 <<< $@)
   line=$(cut -d ',' -f1 <<< $path)
   col=$(cut -d ',' -f2 <<< $path)
   if [[ "$col" == "0" ]]; then
      ico=$(cut -d '@' -f2 <<< $arg | cut -d '|' -f1)
      if [[ "$ico" == "folder" ]]; then
         echo "TREE@@CELL@@treeview1@@$path@@document-open"
      else
         echo "TREE@@CELL@@treeview1@@$path@@folder"
      fi
   elif [[ "$col" == "1" ]]; then
      ico=$(cut -d '@' -f2 <<< $arg | cut -d '|' -f1)
      echo "TREE@@CELL@@treeview1@@$path@@gtk-no"
      [ -n "$old_path" ] && echo "TREE@@CELL@@treeview1@@$old_path@@gtk-yes"
      old_path=$path
   fi
else
       echo "SET@_entry1.set_text('$arg')"
fi
}
old_path=
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
