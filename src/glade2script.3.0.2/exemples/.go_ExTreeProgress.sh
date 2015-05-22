#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
var=$(ls -1 | xargs -I% echo '%|0')
../glade2script.py -g ./ExTreeProgress.glade -d -t "@@treeview1@@name%%editable%%-1|Débit%%-1|PROGRESS%%Progression%%150|FONT|col%%-1|HIDE"
 exit
