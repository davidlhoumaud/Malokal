#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
tree_icon="folder|folder|folder|folder
gtk-no|folder|folder|gtk-yes
folder|folder|folder|folder"

tree_pango="Défaut, sans balises
<i><b>Balise b et i</b></i>
<big><tt>Balise big et tt</tt></big>
<span size='large' font_family='FreeMono'>Balise span large</span>
<b><span size='xx-large' background='blue' foreground='white'>Balise span couleur et b</span></b>"

tree_defaut="choix normal|choix normal|hide|normal|red
italic et bold|italic et bold|hide|bold italic|red
sans bold 12|sans bold 12|hide|sans bold 12|red
serif,monospace bold italic condensed 16|serif,monospace bold italic condensed 16|hide|serif,monospace bold italic condensed 16|red"

../glade2script.py -g ./ExTreeviewFull.glade -d -t \
"@@treeview1@@ICON%%6|ICON%%5|ICON%%2|ICON%%1
$tree_icon
@@treeview2@@PangoMarkup
$tree_pango
@@treeview3@@col1%%50|PangoFontDescription%%editable|HIDE|FONT|BACK
$tree_defaut"
exit


"@@treeview1@@ICON%%6|ICON%%5|ICON%%2|ICON%%1|Titre 1%%100|Titre 2
folder|folder|folder|folder|Police par défaut|<i>ajout italic</i>
folder|folder|folder|folder|<span foreground='red'>Police en rouge</span>|<span foreground='white' background='red'>Couleur</span>
folder|folder|folder|folder|<span font_family='FreeMono'>Police FreeMono</span>|<b><span font_family='FreeMono'>Police FreeMono bold</span></b>"
