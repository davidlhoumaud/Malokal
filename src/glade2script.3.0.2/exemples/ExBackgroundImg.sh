#!/bin/bash
##############################################################################################
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
###############################################################################################
base_dir="$(pwd)"
flag=false
eventbox1()
{
echo "EXIT@@"
}
eventbox2()
{
	[[ "$@" =~ 'press_event' ]] && {
		echo 'GET@window1.get_pointer()'
		echo 'GEO@@GET@@window1'
		echo 'POINTER@@START@@50@@window1'	
	}	
	[[ "$@" =~ 'release_event' ]] && echo 'POINTER@@STOP@@window1'
}
window1()
{
	value=$(cut -d '@' -f2 <<< $@)
	[[ "$@" =~ 'geo@' ]] && {
		width=$(cut -d ' ' -f1 <<< $value )
		height=$(cut -d ' ' -f2 <<< $value)
		pointer=$(cut -d '(' -f2 <<< $window1_get_pointer | cut -d ')' -f1)
		pointer_x=$(cut -d ',' -f1 <<< $pointer)
		pointer_y=$(cut -d ',' -f2 <<< $pointer)
		decal_x=$((width-pointer_x))
	}
	[[ "$@" =~ 'move@' ]] && {
		x=$(cut -d ' ' -f1 <<< $value)
		y=$(cut -d ' ' -f2 <<< $value)
		x=$((x-decal_x))
		y=$((y-pointer_y))
		#echo "SET@window1.move($x,$y)"
		echo "GEO@@SET@@window1@@$width $height $x $y"
	}
}
#echo "WINDOW@@BACKGROUND@@window1@@skin_black.png"
echo "SET@navig1.set_custom_encoding('UTF-8')"
echo "WEBKIT@@LOAD@@navig1@@$base_dir/index1.html"
#echo "SET@navig1.set_transparent(True)"
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
