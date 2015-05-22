#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
../glade2script.py -g ./ExCouleur.glade -d -t "@@treeview1@@Titre
$(ls -1)"
exit
