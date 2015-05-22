#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
liste=$(ls -1)
../glade2script.py -g ./ExDragDrop.glade -d --gtkrc="blue.css" -t "@@treeview1@@treeview1
$liste" -t "@@treeview2@@treeview2"
exit
