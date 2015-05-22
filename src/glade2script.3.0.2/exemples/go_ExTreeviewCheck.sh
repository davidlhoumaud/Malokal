#!/bin/bash
# il faut se déplacer dans le dossier de l'interface ou indiquer le path entier du glade.
cd "$( cd "$(dirname $0)"; pwd )"                                                                                                                      

../glade2script.py -g ./ExTreeviewCheck.glade -r 'treeview1' -d --infobulle="@@treeview1@@1:2,2:2,3:3,4:4,5:5,6:7" -t \
"@@treeview1@@ICON%%5%%clic%%check|ICON%%clic%%radio|Colonne%%50%%editable|CHECK%%check|RADIO%%radio|Colonne%%50|FONT|COMBO%%combo%%mp3%%ogg%%défaut"
exit



