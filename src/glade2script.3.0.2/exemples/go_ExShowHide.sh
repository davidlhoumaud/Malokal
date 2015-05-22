#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
../glade2script.py -g ./ExShowHide.glade -d
exit
