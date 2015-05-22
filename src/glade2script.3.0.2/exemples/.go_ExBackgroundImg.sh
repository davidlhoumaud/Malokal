#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
../glade2script.py -g ./ExBackgroundImg.glade -d --webkit='navig1,_box_navig'
exit
