#!/bin/bash
cd "$( cd "$(dirname $0)"; pwd )"
# remplacer la window ID nécessaire par %s
 ../glade2script.py -g ./ExEmbedMplayer.glade -d --embed="_drawingarea1@@mplayer -idle -slave -quiet -vo xv -wid %s -input file=/tmp/fifomplay"
exit
