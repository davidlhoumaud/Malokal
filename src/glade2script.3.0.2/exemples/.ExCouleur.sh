#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################

#################################
### À savoir sur les couleurs ###
#################################

## 1) Script
# >>> On peut indiquer la couleur d'un widget de deux façon:
        # > En la nommant (red, white, black ...)
        # > Avec le code hexa (http://fr.wikipedia.org/wiki/Liste_de_couleurs)

#############################################################################################

## Définition des fonctions

_button1()
{
echo "COLOR@@window1@@override_background_color@@Gtk.StateFlags.NORMAL@@Sienna"
echo "COLOR@@window1@@override_color@@Gtk.StateFlags.ACTIVE@@yellow"

}
_button2()
{
 echo "COLOR@@eventlabel@@override_background_color@@Gtk.StateFlags.NORMAL@@yellow"
 echo "COLOR@@_label1@@override_color@@Gtk.StateFlags.NORMAL@@red"
}

_button3()
{
echo "COLOR@@treeview1@@override_background_color@@Gtk.StateFlags.NORMAL@@green"
echo "COLOR@@treeview1@@override_color@@Gtk.StateFlags.NORMAL@@blue"
echo "COLOR@@treeview1@@override_background_color@@Gtk.StateFlags.SELECTED@@red"
echo "COLOR@@treeview1@@override_color@@Gtk.StateFlags.SELECTED@@yellow"
echo "COLOR@@treeview1@@override_background_color@@Gtk.StateFlags.ACTIVE@@yellow"
echo "COLOR@@treeview1@@override_color@@Gtk.StateFlags.ACTIVE@@red"
}
_button4()
{

echo "COLOR@@eventbox1@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange"
echo "COLOR@@eventbox1@@override_background_color@@Gtk.StateFlags.NORMAL@@black"

}

_button5()
{
echo "COLOR@@_checkbutton1@@override_background_color@@Gtk.StateFlags.NORMAL@@yellow"
echo "COLOR@@_checkbutton1@@override_background_color@@Gtk.StateFlags.PRELIGHT@@red"
echo "COLOR@@_checkbutton1@@override_background_color@@Gtk.StateFlags.SELECTED@@green"
echo "COLOR@@_checkbutton1@@override_color@@Gtk.StateFlags.PRELIGHT@@red"

}
_button6()
{
echo "COLOR@@_togglebutton1@@override_background_color@@Gtk.StateFlags.NORMAL@@yellow"
echo "COLOR@@_togglebutton1@@override_background_color@@Gtk.StateFlags.PRELIGHT@@green"
echo "COLOR@@_togglebutton1@@override_background_color@@Gtk.StateFlags.ACTIVE@@red"
}

_button7()
{
echo "COLOR@@_entry1@@override_background_color@@Gtk.StateFlags.NORMAL@@green"
echo "COLOR@@_entry1@@override_color@@Gtk.StateFlags.NORMAL@@red"
echo "COLOR@@_entry1@@override_background_color@@Gtk.StateFlags.SELECTED@@red"
echo "COLOR@@_entry1@@override_color@@Gtk.StateFlags.SELECTED@@white"
}
_button8()
{

echo "COLOR@@_textview1@@override_background_color@@Gtk.StateFlags.NORMAL@@black"
echo "COLOR@@_textview1@@override_color@@Gtk.StateFlags.NORMAL@@white"
}
_checkbutton1()
{
echo $1
}

## Début du script

echo "COLOR@@_button1@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button1@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button2@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button2@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button3@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button3@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button4@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button4@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button5@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button5@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button6@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button6@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button7@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button7@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button8@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"
echo "COLOR@@_button8@@override_background_color@@Gtk.StateFlags.PRELIGHT@@orange red"

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
