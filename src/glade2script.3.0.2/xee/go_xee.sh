#!/bin/bash
# il faut se déplacer dans le dossier de l'interface ou indiquer le path entier du glade.
cd "$( cd "$(dirname $0)"; pwd )"
./glade2script.py -g ./xee.glade -d --terminal='_termbox:400x100' --terminal-redim --clipboard=PRIMARY
exit
