#!/bin/bash
# il faut se déplacer dans le dossier de l'interface ou indiquer le path entier du glade.
cd "$( cd "$(dirname $0)"; pwd )"

ENTRY=$(../glade2script.py -g ./ExEntry1.glade -r '_entry1.get_text')

if [[ "$?" == "1" ]]; then # $?=code de sortie
   echo "Annuler a été cliqué" && exit
else
   eval $ENTRY
     if [[ "$_entry1_get_text" ]]; then # test si l'entry est vide
         echo "le contenue de l'entry est $_entry1_get_text"
     else
         echo "le contenue de l'entry est vide"
     fi
fi
echo "$ENTRY"


