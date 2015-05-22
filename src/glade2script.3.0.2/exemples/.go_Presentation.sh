#!/bin/bash
path="$( cd "$(dirname "$0")"; pwd )"
cd "$path"
n=0
tree_exemples=$(ls | grep glade$ | while read line; do echo "$n|$line"; n=$((n+1)); done)
#echo "${tree_exemples}"
../glade2script.py -g ./Presentation.glade --clipboard=PRIMARY -d -t \
"@@treeview1@@HIDE|Exemples
${tree_exemples}" \
-t "@@tree_cmd@@HIDE|cmd|ex" \
-t "@@tree_callback@@callabck|signal|value" \
--combo="@@_combo_style@@col" \
--sourceview="_text_lanceur,_box_text_lanceur" \
--sourceview="_text_code,_box_text_code"
exit
