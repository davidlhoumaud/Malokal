#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
 ../glade2script.py -g ./ExConsole.glade -d --terminal='_hbox1:500x100' \
--terminal-redim --terminal-font='serif,monospace bold italic condensed 10'
exit
