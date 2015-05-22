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
echo "COLOR@@window1@@background_color@@NORMAL@@Sienna"
echo "COLOR@@window1@@color@@ACTIVE@@yellow"
echo "GTKRC@@blue.css"
}
_button2()
{
 echo "COLOR@@eventlabel@@background_color@@NORMAL@@yellow"
 echo "COLOR@@_label1@@color@@NORMAL@@red"
 echo "GTKRC@@#treeview1 { color: #000000; }"
}

_button3()
{
echo "COLOR@@treeview1@@background_color@@NORMAL@@green"
echo "COLOR@@treeview1@@color@@NORMAL@@blue"
echo "COLOR@@treeview1@@background_color@@SELECTED@@red"
echo "COLOR@@treeview1@@color@@SELECTED@@yellow"
echo "COLOR@@treeview1@@background_color@@ACTIVE@@yellow"
echo "COLOR@@treeview1@@color@@ACTIVE@@red"
}
_button4()
{

echo "COLOR@@eventbox1@@background_color@@PRELIGHT@@orange"
echo "COLOR@@eventbox1@@background_color@@NORMAL@@black"

}

_button5()
{
echo "COLOR@@_checkbutton1@@background_color@@NORMAL@@yellow"
echo "COLOR@@_checkbutton1@@background_color@@PRELIGHT@@red"
echo "COLOR@@_checkbutton1@@background_color@@SELECTED@@green"
echo "COLOR@@_checkbutton1@@color@@PRELIGHT@@red"

}
_button6()
{
echo "COLOR@@_togglebutton1@@background_color@@NORMAL@@yellow"
echo "COLOR@@_togglebutton1@@background_color@@PRELIGHT@@green"
echo "COLOR@@_togglebutton1@@background_color@@ACTIVE@@red"
}

_button7()
{
echo "COLOR@@_entry1@@background_color@@NORMAL@@green"
echo "COLOR@@_entry1@@color@@NORMAL@@red"
echo "COLOR@@_entry1@@background_color@@SELECTED@@red"
echo "COLOR@@_entry1@@color@@SELECTED@@white"
}
_button8()
{

echo "COLOR@@_textview1@@background_color@@NORMAL@@black"
echo "COLOR@@_textview1@@color@@NORMAL@@white"
}
_checkbutton1()
{
echo $1
}

## Début du script
for i in {1..8}
  do
    echo "COLOR@@_button$i@@background_color@@PRELIGHT@@orange "
  done

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
