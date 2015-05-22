#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
#rm ./tmpsmaplyer
../glade2script.py -g ./ExPluginMplayer.glade -d #>> ./tmpsmaplyer
exit
