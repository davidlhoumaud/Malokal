#!/bin/bash
# il faut se déplacer dans le dossier de l'interface ou indiquer le path entier du glade.
cd "$( cd "$(dirname $0)"; pwd )"
../glade2script.py -g ./ExTreeviewDC.glade -d -r 'montree' -t \
"@@montree@@Colonne
ligne1
ligne2
ligne3"
exit
ENTRY=$(./glade2script.py -g ./ExTreeviewDC.glade -d -r 'montree' -t \
"@@montree@@Colonne|FONT
$(ls $HOME | xargs -I% echo '%|bold')")
echo "$ENTRY"
