#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
 ../glade2script.py -g ./ExCombobox.glade -d -r 'window1.get_size,combobox1.get_active_text' \
--combobox="@@combobox1@@col|ICON
un|gtk-yes
de|gtk-yes" \
--combobox="@@combobox2@@col|IMG%%30
un|tux.png
de|tux.png" \
exit
