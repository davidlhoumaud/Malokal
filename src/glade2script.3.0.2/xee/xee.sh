#!/bin/bash

PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
######################################################################################################
#echo "GET@terminal_PID"
msgadm="L'installation des mises à jour nécessite les privilèges administrateur."
bot="$PWD/bot_xee.py"
echo "TEXT@@LOAD@@_source@@$bot"
echo "SET@_id.set_text('@jappix.com')"
echo "SET@_pass.set_text('')"

function _id()
{
echo 'GET@_id.get_text()'
}
function _pass()
{
echo 'GET@_pass.get_text()'
}
function _exe()
{
    echo "SET@_exe.set_sensitive(False)"
    echo "SET@_stop.set_sensitive(True)"
    echo "TEXT@@SAVE@@_source@@$bot"
    cmd="./bot_xee.py $_id_get_text $_pass_get_text\n"
    echo "TERM@@SEND@@$cmd"
}

function _stop()
{
    killall bot_xee.py
    echo "SET@_exe.set_sensitive(True)"
    echo "SET@_stop.set_sensitive(False)"
}

function _close()
{
    echo "EXIT@@"
}

_source()
{
    echo "_______$@"
}

######################################################################################################
#set -f
while read ligne; do
    if [[ "$ligne" =~ GET@ ]]; then
       eval ${ligne#*@}
       echo "DEBUG => in boucle bash :" ${ligne#*@}
       
    else
       echo "DEBUG=> in bash NOT GET" $ligne # ${ligne/\*/\\\*}
       #${ligne/\*/\\\*} #
       $ligne
   fi 
done < <(while true; do
    read entree < $FIFO
    [[ "$entree" == "QuitNow" ]] && break
     echo $entree   
done)

exit
