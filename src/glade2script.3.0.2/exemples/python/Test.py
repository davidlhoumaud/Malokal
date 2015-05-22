#! /usr/bin/env python
# -*- coding:Utf­8 ­-*-
import os
import os.path
import sys
import threading
'''
Version sans FIFO, option --import
On peut se passer du fichier de lancement (go_*.py), l'équivalent se trouve en fin de script.
Attention, dans ce cas, le contenu du script sera chargé 2 fois en mémoire.
'''
class Action(threading.Thread):
    def __init__(self, g2s):
        '''
        g2s = instance de glade2script
        '''
        threading.Thread.__init__(self)
        # Appeler la fonction from_import pour communiquer avec glade2script
        self.g2s = g2s
        self.to_glade = g2s.from_import

    def run(self):
        pass

    def quit_now(self):
        ''' This function shall not be removed'''
        pass


    def btn_traduire(self, arg=None):
        self.to_glade('''SET@_label_ip.set_use_markup(True)
SET@_label_ip.set_markup('<b>http://'''+IP+''':8000</b>')
SET@modem.set_custom_encoding('UTF-8')
WEBKIT@@LOAD@@modem@@http://192.168.1.1
SET@redirect.set_custom_encoding('UTF-8')
WEBKIT@@LOAD@@redirect@@http://giss.tv''')


if __name__ == '__main__':
    path_fichier = os.path.abspath(__file__)
    path_dossier = os.path.dirname(path_fichier)
    os.chdir(path_dossier)
    os.system('../../glade2script.py -g ./Test.glade -d --import="%s/Test.py"' % path_dossier)
