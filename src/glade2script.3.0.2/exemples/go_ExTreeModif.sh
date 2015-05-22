#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
 ../glade2script.py -g ./ExTreeModif.glade -d -t '@@treeview1@@ICON|Colonne 1%%editable|FONT|Ligne départ'
exit
