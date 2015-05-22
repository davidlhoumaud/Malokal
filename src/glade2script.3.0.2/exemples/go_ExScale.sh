#!/bin/bash

# il faut se déplacer dans le dossier de l'interface ou indiquer le path entier du glade.
cd "$( cd "$(dirname $0)"; pwd )"
../glade2script.py -g ./ExScale.glade -r '_hscale1.get_value' -d
exit
