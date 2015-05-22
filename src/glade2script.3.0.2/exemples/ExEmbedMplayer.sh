#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

FIFOmplay=/tmp/fifomplay
mkfifo $FIFOmplay

_btn_play()
{
echo loadfile \"${fichier}\" 0 >> $FIFOmplay

}
_filechooser()
{
fichier=${@}
}
_btn_stop()
{
echo 'pause' >> $FIFOmplay
}
btn_mute()
{
echo 'mute -1' >> $FIFOmplay
}
window1()
{
echo 'quit 0' >> $FIFOmplay
rm $FIFOmplay
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
