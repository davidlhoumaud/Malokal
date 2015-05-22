#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
../glade2script.py -g ./ExSystray.glade -d --systray="systray@menu1@gtk-no@Mon infobulle"
exit
