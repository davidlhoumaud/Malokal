#! /usr/bin/env python
# -*- coding:Utf­8 ­-*-
############################################################################
##                                                                        ##
##     GladeToScript permet d'utiliser simplemet des fonctions GTK        ##
##   depuis un script/logiciel. Il permet sans grande connaissances       ##
##   en GTK, de manier ses widgets depuis un script bash par exemple.     ##
##                                                                        ##
############################################################################
##                                                                        ##
##     Copyright (C) 2010-2011  AnsuzPeorth (ansuzpeorth@gmail.com)       ##
##                                                                        ##
## This program is free software: you can redistribute it and/or modify   ##
## it under the terms of the GNU General Public License as published by   ##
## the Free Software Foundation, either version 3 of the License, or      ##
## (at your option) any later version.                                    ##
##                                                                        ##
## This program is distributed in the hope that it will be useful,        ##
## but WITHOUT ANY WARRANTY; without even the implied warranty of         ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          ##
## GNU General Public License for more details.                           ##
##                                                                        ##
## You should have received a copy of the GNU General Public License      ##
## along with this program.  If not, see <http://www.gnu.org/licenses/>.  ##
##                                                                        ##
############################################################################
import os, os.path
import threading
import subprocess
import time
import gtk
import gtk.glade
import pygtk	
import gobject
import pango
import shlex
import sys
import getopt
import re
import gettext
from xml.dom.minidom import parse

try:
	import vte
except:
	print "You need to install python bindings for libvte to use --terminal option"
try:
	import pynotify
except:
	print "You need to install pynotify to use notification"

gobject.threads_init()


l_sortie=[]
dic_treeview={}
dic_tooltip={}
s_bash=None
systray_icon=None
gtkrc=None
clip=None
term_box=None
flag_term=None
embed = None
term_font = None
term_redim = None
import_py = None
DEBUG=False


def usage():
	print "usage: " + sys.argv[0] + " [OPTIONS]"
	print "OPTIONS:"
	print " -h/--help : Affiche l'aide"
	print " -s/--sh= : Fichier sh"
	print " -g/--glade= : Fichier glade"
	print """ -r/--retour= : Commandes gtk pour sortie 'window.get_position , _entry1.get_text'"""
	print " -t/--tree=  : Liste des éléments du treeview (un par ligne ou par option)"
	print " -d : Débugge"
	print "--systray= : Icon en zone de notification"
	print "--infobulle= : Pour gérer l'infobulle d'un treeview"
	print "--clipboard= : Récupère le contenue du clipboard [PRIMARY, CLIPBOARD]"
	print "--terminal= : Terminal vte"
	print "--terminal-font= : Charge une font name string"
	print "--terminal-redim : Redimension auto du terminal"
	print "--embed= : Embarque une appli qui le supporte nativement"
	print "--import= : Importer comme module plutôt que d'utiliser le FIFO"
try:                                
	opts, args = getopt.getopt(sys.argv[1:], "hs:g:r:t:d", ["sh=", "glade=", "retour=",
								"gtkrc=", "tree=","systray=", "terminal=", "embed=", "import=",
								"infobulle=","clipboard=","terminal-font=","terminal-redim"])
except getopt.GetoptError: 
	print 'error'
	usage()                         
	sys.exit(2)                     
for opt, arg in opts:
	if opt in ("-h", "--help"): 
		usage()                     
		sys.exit()
	elif opt in ("-s", "--sh"): 
		s_bash = arg                
	elif opt == '-d':               
		DEBUG = True                  
	elif opt in ("-g", "--glade"): 
		f_glade = arg 
	elif  opt in ("-r","--retour"):
		l_sortie=arg.replace(' ','').split(',')
	elif opt in ("--gtkrc"):
		gtkrc = arg
	elif opt in ("--systray"):
		systray_icon=arg
	elif opt in ("--infobulle"):
		name, coord= arg.split('@@')[1:]
		dic_tooltip[name]=eval('{%s}' % coord)
	elif opt in ("-t", "--tree"):
		liste_tree=[]
		for item in arg.split('\n'):
 			if item.startswith('@@'):
 				if liste_tree:
 					dic_treeview[nom]=liste_tree
 					liste_tree=[]
 				nom, reference = item.split('@@')[1:]
 				liste_tree.append(reference)
 				continue
			liste_tree.append(item)
		dic_treeview[nom]=liste_tree
	elif opt in ("--clipboard="):
		clip = arg
	elif opt == "--terminal":
		term_box = arg
	elif opt == "--terminal-font":
		term_font = arg
	elif opt == "--terminal-redim":
		term_redim = True
	elif opt == "--embed":
		embed = arg
	elif opt == "--import":
		import_py = arg
		

nom_appli= os.path.splitext(f_glade)[0]

if s_bash is None:
	s_bash='%s.sh' % nom_appli
	
os.chdir( os.path.dirname(f_glade) )



'''
 APLLICATION EMBARQUE (en constructon !)
'''
class ThreadEmbed(threading.Thread):
	def __init__(self, cmd):        
		threading.Thread.__init__(self)
		self.Terminated = False
		self.cmd = cmd

	def run(self):
		args = shlex.split( self.cmd )
		sb=subprocess.Popen(args,stderr=subprocess.STDOUT,stdout=subprocess.PIPE)
		self.PID=sb.pid
		#time.sleep(1)
		n=0
		'''
		while not self.Terminated:
			#print 'ok',self.Terminated
			#time.sleep(0.2)
			#self.win.set_title(str(n))
			#n+=1
			sortie=sb.stdout.readline().rstrip()
			print sortie
			if 'interrupted' in sortie or 'Exiting' in sortie: 
				print 'interrupt'
				self.win.set_title('Exiting ...')
				self.Terminated = True
			elif 'Error' in sortie:
				self.stop()
				self.win.set_title(sortie)
			elif 'Cache fill' in sortie:
				self.win.set_title('Buffering ...')
				
			elif 'Starting' in sortie:
				self.win.set_title(self.chaine)
				
			elif 'StreamTitle' in sortie:
				self.win.set_title(sortie.split("'")[1])
			#print 'ok2',self.Terminated
		'''	
			
	def stop(self):
		#if not self.Terminated: 
		print 'stoppp'
		os.kill(self.PID,9)

class Embed(gtk.Socket):
	def __init__(self, widget, cmd):
		self.cmd = cmd % widget.window.xid
		gtk.Socket.__init__(self)
		self.flag=False
		self.go_embed()
		
	def go_embed(self):
		print 'play'
		#self.embed=ThreadEmbed( self.cmd )
		#self.embed.start()
		args = shlex.split( self.cmd )
		self.embed=subprocess.Popen(args,stderr=subprocess.STDOUT,stdout=subprocess.PIPE)
		self.flag=True
	
	def stop_embed(self):
		if self.flag: self.embed.stop()
		
		

class Callbacks(object):
		
	'''
	***************************************************
	*** CALLBACKS FROM USER ACTION
	***************************************************
	'''
	'''
	*** Fermeture interface
	'''
	def gtk_widget_destroy(self,*arg):
		self.th.stop('no')

	def gtk_widget_destroy_save(self,*arg):
		self.th.stop('yes')

	'''
	*** icone de notification
	'''	
	def systray_show(self,widget,event=None,arg=None):
		self.systray.set_visible(True)

	def systray_hide(self,widget,event=None,arg=None):
		self.systray.set_visible(False)	
				
	def on_blinking(self,widget,event=None,arg=None):
		self.systray.set_blinking(True)

	def off_blinking(self,widget,event=None,arg=None):
		self.systray.set_blinking(False)

	'''
	*** widgets couleurs
	'''		
	def on_colorbutton(self,widget,event=None,arg=None):
		color_gtk=widget.get_color()
		self.gtk_to_rgb(widget, color_gtk)
	
	def on_colorsel(self,widget,event=None,arg=None):
		color_gtk=widget.get_current_color()
		self.gtk_to_rgb(widget, color_gtk)
		
	def gtk_to_rgb(self,widget, color_gtk):
		nom=widget.get_name()
		color=color_gtk.to_string()
		rgb='#%s%s%s' % ( color[1:3], color[5:7], color[9:11] )
		self.send_data('%s %s' % (nom, rgb.upper() ) )

	'''
	*** widget police de caractère
	'''			
	def on_font(self,widget,event=None,arg=None):
		nom=widget.get_name()
		font=widget.get_font_name()
		self.send_data('%s %s' % (nom, font ) )

	'''
	*** Gestion des widgets (show, sensitive, active) on - off
	'''		
	def on_hide(self,widget,event=None,arg=None):
		self.set_dic_widget(widget, 1)
		widget.hide()
			
	def on_show(self,widget,event=None,arg=None):
		self.set_dic_widget(widget, 1)
		widget.show()

	def on_sensitive(self,widget,event=None,arg=None):
		self.set_dic_widget(widget, 0)
		widget.set_sensitive(True)
		
	def off_sensitive(self,widget,event=None,arg=None):
		self.set_dic_widget(widget, 0)
		widget.set_sensitive(False)

	def on_active(self,widget,event=None,arg=None):
		self.set_dic_widget(widget, 2)
		widget.set_active(True)
		
	def off_active(self,widget,event=None,arg=None):
		self.set_dic_widget(widget, 2)
		widget.set_active(False)
		

	'''
	*** Gestion des widgets (show, sensitive, active) toggle, gestion par un dictionnaire
	'''				
	def toggle_sensitive(self, widget, event=None,arg=None):
		name = widget.get_name()
		self.set_dic_widget(widget, 0)
		widget.set_sensitive( self.dic_widget[name][0] )
	
	def toggle_visible(self, widget, event=None,arg=None):
		name = widget.get_name()
		if self.dic_widget[name][1]:
			widget.hide()
		else:
			widget.show()
		self.set_dic_widget(widget, 1)

	def toggle_active(self, widget, event=None,arg=None):
		name = widget.get_name()
		self.set_dic_widget(widget, 2)
		widget.set_active( self.dic_widget[name][2] )	
		
	def set_dic_widget(self, widget, place):
		name = widget.get_name()
		if self.dic_widget[name][place]:
			self.dic_widget[name][place] = False
		else: 
			self.dic_widget[name][place] = True


	'''
	*** filechooser
	'''		
	def on_filechoose(self,widget,event=None,arg=None):
		nom=widget.get_name()
		valeur=widget.get_filename()
		if valeur ==self.var_filechoose or valeur is None: return
		self.var_filechoose=valeur
		self.send_data('%s %s' % (nom, valeur) )

	'''
	*** combobox, spinbutton, calendar, zone de saisie, scale,
	      menu contextuel, linkbutton, activate
	'''				
	def on_combo(self,widget,event=None,arg=None):
		nom=widget.get_name()
		valeur=widget.get_active_text()
		if valeur is not None:
			self.send_data('%s %s' % (nom, valeur) )
		
	def on_spinbutton(self,widget,*arg):
		nom=widget.get_name()
		valeur=widget.get_value()
		self.send_data('%s %s' % (nom, valeur) )
		
	def on_calendar(self,widget,event=None,arg=None):
		nom=widget.get_name()
		valeur=widget.get_date()
		self.send_data('%s %s' % (nom, valeur) )
		
	def on_entry(self,widget, icon=None, event=None):
		nom=widget.get_name()
		valeur=widget.get_text()
		try:
			if icon == gtk.ENTRY_ICON_PRIMARY:
				v = 'primary@'
			elif icon == gtk.ENTRY_ICON_SECONDARY:
				v = 'secondary@'
			else:
				v = ''
		except:
			v = ''
		self.send_data('''%s %s%s''' % (nom, v, valeur) )
	
	def clear_entry(self,widget, event=None,arg=None):
		widget.set_text('')
			
	def on_scale(self,widget,event=None,value=None):
		nom=widget.get_name()
		valeur=widget.get_value()
		self.send_data('%s %s' % (nom, valeur) )			
	
	def on_menu(self,widget,event=None,arg=None):
		if event is not None:
			if event.button == 3:
				widget.popup(None,None,None,event.button,event.time)

	def on_linkbutton(self,widget,event=None,arg=None):
		nom=widget.get_name()
		valeur=widget.get_uri()
		self.send_data('%s %s' % (nom, valeur) )
	
	def on_activate(self,widget,event=None,arg=None):
		widget.activate()
	
	'''
	*** clic user
	'''					
	def clic_droit(self,widget,event=None,arg=None):
		if event is not None:
			if event.button == 3:
				self.send_data('%s %s' % (widget.get_name() , 'clic_droit') )
			
	def double_clic(self,widget,path=None,view_colomn=None):
		self.on_treeview(widget,'dblc')
						
	def on_clicked(self, widget,event=None,arg=None):
		print event, arg
		self.send_data( '%s %s' % (widget.get_name(), 'clicked') )
		
	def get_pointer(self, widget, event=None,arg=None):
		name = widget.get_name()
		x, y = widget.get_pointer()
		self.send_data( '%s pointer@%s,%s' % (name, x, y) )

	'''
	*** treeview
	'''					
	def on_treeview(self,widget,event=None,arg=None):
		nom=widget.get_name()
		arg=self.th.retourne_selection(nom)
		if arg:
			if event =='dblc': arg='double_clic@%s' % (arg)
			self.send_data('%s %s' % (nom, arg) )
			
	def select_up(self,widget,event=None,arg=None):
		self.th.TREEUP( '_@@_@@%s' % widget.get_name() )
		
	def select_down(self,widget,event=None,arg=None):
		self.th.TREEDOWN( '_@@_@@%s' % widget.get_name() )	

	'''
	*** radio, check, toggle button
	'''	
	def on_toggled(self, widget,event=None,arg=None):
		nom=widget.get_name()
		value=widget.get_active()
		self.dic_widget[nom][2] = value
		self.send_data('%s %s' % (nom, value) )
		
	def my_callback(self, widget,event=None,arg=None):
		self.send_data( '%s %s' % (widget.get_name(), 'my_callback') )


	'''
	*** survol de la souris
	'''		
	def enter_notify_event(self, widget,event=None,arg=None):
		if widget:
			self.send_data( '%s %s' % (widget.get_name(), 'enter_notify_event' ) )
		
	def leave_notify_event(self, widget,event=None,arg=None):
		if widget:
			self.send_data( '%s %s' % (widget.get_name(), 'leave_notify_event' ) )

	'''
	*** touches clavier
	'''				
	def key_press(self,widget, event):
		key=gtk.gdk.keyval_name(event.keyval)
		self.send_data( '%s %s' % (widget.get_name(), 'press@%s' % key) )
        	
	def key_release(self,widget, event):
		key=gtk.gdk.keyval_name(event.keyval)
		self.send_data( '%s %s' % (widget.get_name(), 'release@%s' % key) )

	
	'''
	*** expander
	'''			
	def toggle_expander(self, widget, event=None,arg=None):
		if widget.get_expanded():
			widget.set_expanded(False)
		else:
			widget.set_expanded(True)
				
	def on_expander(self, widget, event=None,arg=None):
		widget.set_expanded(True)
	
	def off_expander(self, widget, event=None,arg=None):
		widget.set_expanded(False)
	
	'''
	*** terminal
	'''				
	def kill_term_child(self, widget, arg=None):
		if DEBUG: print '[terminal] kill: ', self.terminal_PID
		try:
			os.kill( self.terminal_PID, 9)
			self.terminal_PID = self.terminal.fork_command()
		except:
			print 'Aucun processus ou kill -9 innopérant'
	
	'''
	*** notebook
	'''		
	def on_page(self, widget, event=None,arg=None):
		notebook = widget.get_parent()
		num = notebook.page_num(widget)
		notebook.set_current_page( num )
	
	def page_next(self, widget, event=None,arg=None):
		widget.next_page()

	def page_prev(self, widget, event=None,arg=None):
		widget.prev_page()


class Gui(Callbacks):
	'''
	*****************************************
	*** CREATION DE L'INTERFACE UTILISATEUR
	*****************************************
	'''
	ne=1
	nl=1
	ns=0
	CIBLES = [
        ('MY_TREE_MODEL_ROW', gtk.TARGET_SAME_WIDGET, 0),
        ('text/plain', 0, 1),
        ('TEXT', 0, 2),
        ('STRING', 0, 3),
        ]
        DIC_RADIO={}
	def __init__(self):
		self.send_drop=True
		self.old_label_tooltip=None
		self.flag_tooltip=False
		self.tooltip_line=-1
		self.tooltip_col=-1
		self.size_cell=24
		self.var_filechoose=None
		self.dic_widget = {}
		self.glade2script_PID = os.getpid()
		
		local_path = os.path.join( os.path.realpath(os.path.dirname(sys.argv[0])),
																	 'locale' )
		if os.path.exists(local_path):  # charger traduction
			gtk.glade.bindtextdomain(nom_appli, local_path)
			gtk.glade.textdomain(nom_appli)
			gettext.install(nom_appli)
			self.widgets = gtk.glade.XML(fname=f_glade, domain=nom_appli)
		else: self.widgets = gtk.glade.XML( f_glade ) 
		     	
		self.widgets.signal_autoconnect(self)
		
		if systray_icon is not None:
			self.set_systray_icon()
			
		if clip is not None:
			self.clipboard = gtk.Clipboard(gtk.gdk.display_manager_get().get_default_display(), clip)
			
		self.parse_xml()
		
		if term_box is not None:
			self.make_terminal()
		
		if embed is not None:
			name, cmd = embed.split('@@')
			widget = eval('self.%s' % name)
			self.app_embed = Embed(widget, cmd)

	
	
	
	'''
	********************
	*** Terminal vte ***
	********************
	'''
	def make_terminal(self):
		'''
		Ajout d'un terminal vte.
		    option --terminal='_hbox1:55x10'
		    Conteneur et dimension (width,height) en paramètres.
		    Un viewport avec callabck doit y être ajouté pour la redimension auto (dans glade)
		'''
		self.flag_term = True
		self.flag_event = True
		self.terminal = vte.Terminal()
		self.terminal_PID = self.terminal.fork_command()	
		lbox, size = term_box.split(':')
		self.term_width, self.term_height = size.split('x')	
		box = eval('self.%s' % lbox)
		box.pack_start(self.terminal,False, True, 0)
		if term_redim:
			self.terminal.connect('char-size-changed', self.redim_container_from_font) 
			self.terminal.connect('status-line-changed', self.child_exited)
		if term_font is not None:
			self.terminal.set_font_from_string(term_font)
		self.terminal.show()
		box.show()
	
	def child_exited(self, widget, arg1=None, arg2=None):
		print widget, arg1, arg2
	
	def redim_container_from_font(self, widget, width, height):
		'''
		Callback appelé lors du changement de fonts du terminal.
			widget = terminal
			width, height = taille nécessaire à la nouvelle font, en pixels
		'''
		pere = widget.get_parent()
		Gpere = pere.get_parent()
		if type(Gpere ) == gtk.Viewport:
			container_width =  width * widget.get_column_count()
			container_height = height * widget.get_row_count()
			gobject.idle_add(Gpere.set_size_request, container_width, container_height)
			self.flag_term = True	
	
	
	def redim_term(self, widget, rect):
		'''
		Callback du signal size-allocate du viewport.
		Lorsque le widget est redimensionné
		   widget = viewport
		   rect = gtk.rectangle
		'''
		# Charge les dimensions pour base de calcul et valeurs par défaut,
		# redimensionne viewport et terminal, une seule fois au départ.
		# Réinitialisée lors de changement de fonts grace au flag
		if self.flag_term: # flag pour éviter le premier signal
			self.flag_term = False
			self.defaut_width, self.defaut_hight = int(self.term_width),int(self.term_height)
			self.col_size = self.terminal.get_char_width()
			self.line_size = self.terminal.get_char_height()
			nb_col = self.defaut_width / self.col_size
			nb_line = self.defaut_hight / self.line_size
			gobject.idle_add(self.terminal.set_size, nb_col, nb_line)
			self.old_nb_col, self.old_nb_row = nb_col, nb_line 
			gobject.idle_add(widget.set_size_request, self.defaut_width, self.defaut_hight)
			return
					
		x, y, w, h = list(rect)
		# nombre de col et de row pour nouvelle taiile
		new_w, new_h = int(float(w)/float(self.col_size)), int(float(h)/float(self.line_size))
		
		# si une dimension est modifiée
		if new_w != self.old_nb_col or new_h != self.old_nb_row: 
			if self.flag_event: self.flag_event = False # flag pour éviter le premier signal
			else: 
				gobject.idle_add(self.terminal.set_size, new_w, new_h )
		self.old_nb_col, self.old_nb_row = new_w, new_h



	'''
	********************
	*** Parser glade ***
	********************
	'''
	def parse_xml(self):
		dom = parse(f_glade)
		l = dom.getElementsByTagName("widget")
		widgets2ref = ['GtkWindow', 'GtkEventBox', 'GtkTreeView', 'GtkStatusbar', 'GtkAboutDialog']
		child2ref = ['sensitive', 'visible', 'active']
		for node in l:
			widget = node.attributes['class'].value
			name = node.attributes['id'].value
			#ajouter au dic pour chaque widget 'sensitive', 'visible', 'active',
			# nécessaire pour gérer les commandes et callaback toggle 
			self.dic_widget[name] = [True, False, False]
			if widget in widgets2ref or name.startswith('_'):
				exec_widget = 'self.%s=self.widgets.get_widget("%s")' % (name, name)
				exec(exec_widget)
				try:
					getattr(self, widget)(name)
				except: pass
				#except TypeError,e:
					#print "Unexpected error:",e
    				
			for child in node.childNodes:
				if child.nodeType == child.TEXT_NODE or not child.hasAttributes() or child.nodeName == "child": continue
				child_name = child.attributes['name'].value
				try:
					child_data = child.firstChild.data
					if child_name in child2ref: # si active, visible, sensitive, lancer fonction modif dico
						getattr(self, child_name)(name, child_data)
				except:
					pass
				if child_name == 'drag_drop':
					self.set_drag_drop(name)
	
	def GtkTextView(self, nom):
		pass
		
	def GtkLabel(self, nom):
		pass
	
	def active(self, nom, data):
		if data =='True':
			self.dic_widget[nom][2] = True
	
	def visible(self, nom, data):
		if data =='True':
			self.dic_widget[nom][1] = True
	
	def sensitive(self, nom, data):
		if data =='False':
			self.dic_widget[nom][0] = False
			
	def GtkWindow(self, nom):
		window=eval('self.%s' % (nom) )
		if gtkrc is not None:
			self.apply_gtkrc( window, gtkrc )
		screen = window.get_screen()
		self.screen_width, self.screen_height = (screen.get_width(),
													screen.get_height())
		return
		if dic_trans:
			
			for key in dic_trans:
				self.transparence(window, screen)
				
	def GtkTreeView(self, nom):
		exec( 'treeview=self.%s' % (nom) )
		try:
			self.make_treeview(nom, treeview)
		except ValueError, e: 
			print '==== [[ ERROR ]] ===>> %s' % e
			
		treeview.enable_model_drag_source( gtk.gdk.BUTTON1_MASK,
                                				self.CIBLES,
                                				gtk.gdk.ACTION_DEFAULT|
                                				gtk.gdk.ACTION_MOVE)
		treeview.enable_model_drag_dest( self.CIBLES,
                                    		gtk.gdk.ACTION_DEFAULT)			
		
	def GtkStatusbar(self, nom):
		exec("self.context_%s = self.%s.get_context_id('context_description')" % (nom,nom) )
			
	'''
	***************************
	*** Gestion drag & drop ***
	***************************
	'''			
	def set_drag_drop(self, nom):
		dd=eval( "self.%s" % (nom) )
		liste=[('truc',gtk.TARGET_SAME_APP, 0),('text/plain', 0, 1),
			('TEXT', 0, 2), ('STRING', 0, 3) ]
		dd.drag_dest_set(gtk.DEST_DEFAULT_DROP, liste, gtk.gdk.ACTION_COPY)
		dd.connect('drag_data_received', self.event_drag_data_received)
		dd.connect('drag_motion', self.motion_cb)
		
	def motion_cb(self, wid, context, x, y, time):
		context.drag_status(gtk.gdk.ACTION_COPY, time)
		return True

	def drag_drop(self, wid, context, x, y, time): 
		return True
			
	def drag_data_get(self, treeview, context, selection, id_cible,
                           etime):  # glisser depuis un treeview
		treeselection = treeview.get_selection()
		#treeselection.set_mode(gtk.SELECTION_MULTIPLE)
		modele, iter = treeselection.get_selected()
		donnees = list(modele[iter])
		selection.set(selection.target, 8, str(donnees) )

	def drag_data_received(self, treeview, context, x, y, selection,
                                info, etime):  # déposer dans un treeview
		modele = treeview.get_model()
		donnees = selection.data
		donnees
		try:  # si c'est une liste, donc venant d'un treeview
			donnees_eval=eval( donnees )
			donnees=self.th.list_to_string(donnees_eval)
		except: # Le join est là uniquement par sécurité,  pas nécessaire
			donnees=donnees.rstrip().replace('\r\n','@@')
			donnees_eval=[donnees]
			donnees='|'.join(donnees_eval)
			
		info_depot = treeview.get_dest_row_at_pos(x, y)
		
		if info_depot: # si on se trouve entre des lignes du treeview
			chemin, position = info_depot
			iter = modele.get_iter(chemin)
			if (position == gtk.TREE_VIEW_DROP_BEFORE
			or position == gtk.TREE_VIEW_DROP_INTO_OR_BEFORE):
				try: # le drop vient du tree
					modele.insert_before(None,iter, donnees_eval)
				except:
					new_iter=modele.get_iter(chemin)
					modele.remove(new_iter)
			else:
				try: # le drop vient du tree
					modele.insert_after(None,iter, donnees_eval)
				except:
					new_iter=modele.get_iter(chemin) 
					modele.remove(new_iter)
			if DEBUG: print '%s drop@%s@%s' % (treeview.get_name(), ','.join( map(str,chemin) ), donnees)
			self.send_data( '%s drop@%s@%s' % (treeview.get_name(), ','.join( map(str,chemin) ), donnees) )		
		else: #on est pas entre lignes de treeview
			try: # le drop vient du tree
				modele.append(None, donnees_eval)
			except: 
				del modele[-1]
				#modele.remove(iter)
			if DEBUG: print '%s drop@%s@%s' % (treeview.get_name(), len(modele)-1, donnees)
			self.send_data( '%s drop@%s@%s' % (treeview.get_name(), len(modele)-1, donnees) )
		if context.action == gtk.gdk.ACTION_MOVE:
			context.finish(True, True, etime)
		return	

	def event_drag_data_received(self, widget, context, x, y, selection,
                                info, etime):  # déposer dans un widget
		try: # si ca vient d'un treeview, convertir en string
			selec=eval(selection.data)
			st_lst=self.th.list_to_string(selec)
			selec='drop@%s' % st_lst
		except: selec='drop@%s' % selection.data.rstrip()
		if DEBUG: print '[event_drag] %s %s' % (widget.get_name(), selec) 
		self.send_data( '%s %s' % (widget.get_name(), selec) )
		
		if context.action == gtk.gdk.ACTION_MOVE:
			context.finish(True, True, etime)

	'''
	****************************
	*** Création du treeview ***
	****************************
	'''
	def make_treeview(self,name,treeview):
		'''
		dic_treeview[name] = ['ICON%%5%%clic%%check|ICON%%clic%%radio|Colonne%%50%%editable|CHECK%%check|RADIO%%radio|Colonne%%50|FONT|COMBO%%combo%%mp3%%ogg%%défaut','data|dtat|dtat|....']
		store_base=['str', 'str', 'str', 'bool', 'bool', 'str', 'str', 'str']
		dic_entet={'RADIO4': ['radio'], 'ICON0': ['5', 'clic', 'check'], 'ICON1': ['clic', 'radio'], 'COMBO7': ['combo', 'mp3', 'ogg', 'd\xc3\xa9faut'], 'Colonne5': ['50'], 'Colonne2': ['50', 'editable'], 'FONT6': [], 'FONT': 6, 'CHECK3': ['check']}
		liste_base=['ICON0', 'ICON1', 'Colonne2', 'CHECK3', 'RADIO4', 'Colonne5', 'FONT6', 'COMBO7']	
		'''
		store_base = []
		liste_base = []
		value_ent = []
		self.dic_entet = {}
		FBF = ['FONT', 'BACK', 'FORE']
		dic_elem_entet = {'FONT':'str', 'BACK':'str', 'FORE':'str', 'CHECK':'bool',
                  		'RADIO':'bool', 'PROGRESS':'int', 'HIDE':'str', 'FORE':'str',
                  		'COMBO':'str', 'ICON':'str'}
		liste_treeview =  dic_treeview[name]
		#ref = ICON|colonne
		ref=liste_treeview.pop(0)
		liste_ref=ref.split('|')
		
		n=0
		for l in liste_ref:
			liste_l = l.split('%%')
			# ent = ICON, CHECK ...
			ent = liste_l.pop(0)
			# ent_n = ICON1, CHECK2 ...
			ent_n = '%s%s' % (ent, n)
			try:
				# ajoute str, bool ...
				store_base.append( dic_elem_entet[ent] )
			except:
				store_base.append('str')
			liste_base.append( ent_n )
			self.dic_entet[ent_n] = liste_l
			if ent in FBF: #referencer la colonne
				self.dic_entet[ent] = n
			n+=1
		
		var=','.join(store_base)
		exec( 'self.store_%s= gtk.TreeStore(%s)' % (name,var) )
		exec( 'mystore=self.store_%s' % (name) )
		l = []
		for ent in liste_base:
			n = ent[-1]
			call_fonction = ent[:-1]
			try: #test si l'entête est une fonction
				vv = dic_elem_entet[call_fonction]
				value_ent = self.dic_entet[ent]
			except: #sinon, c'est une colonne texte
				value_ent = [call_fonction]+self.dic_entet[ent]
				call_fonction = 'TEXT'
			titre_col=' '
			getattr(self, call_fonction)(name, treeview, mystore, int(n),
													value_ent, titre_col)
		if liste_treeview: # si des lignes sont passées en argument, charger le TreeStore
			for ligne in liste_treeview:
				path = ligne.split('|')[0]
				parent, position = self.try_path(path, mystore)
				mystore.append(parent, self.modif_type(ligne) )
		treeview.set_model(mystore)
		
	def try_path(self, position, mystore):
		try:
			parent, position = position.split(':')
			iter = mystore.get_iter(parent)
		except:
			iter = None
		return (iter, position)		
	
	def ICON(self, name, treeview, mystore, num_col, l_value, titre):
		CLIC=False
		render=gtk.CellRendererPixbuf()
		for lm in l_value:
			try:  # si c'est un chiffre
				size=int(lm)
				render.set_property('stock_size', size )
			except:			        			
				if lm == 'clic': # rendre icon cliquable
					CLIC=True
				else:			        				
					titre=lm
		
		col=gtk.TreeViewColumn(titre, render, icon_name=num_col)
		if CLIC:
			treeview.connect_after('cursor-changed', self.rappel_clic, col, name, num_col)
		treeview.append_column(col)
		return True
    	
	def CHECK(self, name, treeview, mystore, num_col, l_value, titre):
		if l_value: titre = l_value[0]
		render=gtk.CellRendererToggle()
		render.connect('toggled', self.rappel_toggled, mystore, num_col, name)
		col=gtk.TreeViewColumn(titre, render, active=num_col)
		treeview.append_column(col)
		
	def RADIO(self, name, treeview, mystore, num_col, l_value, titre):
		if l_value: titre = l_value[0]
		render=gtk.CellRendererToggle()
		render.set_property('radio',True)
		render.connect('toggled', self.rappel_radio, mystore, num_col, name)
		col=gtk.TreeViewColumn(titre,render,active=num_col)
		treeview.append_column(col)
		self.DIC_RADIO[num_col]=0
		
	def COMBO(self, name, treeview, mystore, num_col, l_value, titre):
		if l_value:
			titre = l_value.pop(0)
			for lm in l_value:
				try:
					size=int(lm)
					render.set_property('width', size )
				except:			        			
					pass
			liste_combo=[ [i] for i in l_value ]
		store_combo=gtk.ListStore(str)
		for li in liste_combo:
			store_combo.append(li)
		render=gtk.CellRendererCombo()
		render.set_property('model',store_combo)
		render.set_property('text-column', 0)
		render.set_property('editable',True)
		render.connect('edited', self.rappel_edited, name, mystore, num_col,
															'combo',treeview)
		col=gtk.TreeViewColumn(titre, render, text=num_col)
		try:
			col_font = self.dic_entet['FONT']
			col.add_attribute(render,'font', col_font)
		except: pass
		treeview.append_column(col)
		
	def PROGRESS(self, name, treeview, mystore, num_col, l_value, titre):
		render=gtk.CellRendererProgress()
		if l_value:
			for lm in l_value:
				try:
					size=int(lm)
					render.set_property('width', size )
				except:			        			
					titre=lm
		col=gtk.TreeViewColumn(titre, render, value=num_col)
		treeview.append_column(col)	
	
	def TEXT(self, name, treeview, mystore, num_col, l_value, titre):
		render=gtk.CellRendererText()
		size=None
		self.column_sizing=True
		if l_value:
			titre=l_value.pop(0)
			for lm in l_value:
				try:
					size=int(lm)
					render.set_property('width', size )
					self.column_sizing=False
				except:
					if lm == 'editable':
						render.set_property('editable', True)
						render.connect('edited', self.rappel_edited, name,
								mystore, num_col, 'edit', treeview)
						self.col_edit=num_col
		#else: titre=elem
		col=gtk.TreeViewColumn(titre,render,markup=num_col)
		try:
			col_font = self.dic_entet['FONT']
			col.add_attribute(render,'font', col_font)
		except: pass
		try:
			col_back = self.dic_entet['BACK']
			col.add_attribute(render,'background', col_back)
		except: pass
		try:
			col_fore = self.dic_entet['FORE']
			col.add_attribute(render,'foreground', col_fore)
		except: pass
		col.set_resizable(True)
		col.set_sort_column_id(num_col)
		treeview.append_column(col)
		sel=treeview.get_selection()
		sel.set_mode(gtk.SELECTION_SINGLE)
	
	def HIDE(self, name, treeview, mystore, num_col, l_value, titre):
		return
	
	def FONT(self, name, treeview, mystore, num_col, l_value, titre):
		return
	
	def BACK(self, name, treeview, mystore, num_col, l_value, titre):
		return
	
	def FORE(self, name, treeview, mystore, num_col, l_value, titre):
		return
	

	'''
	**************************************************************
	*** Actions treeview column → icon, radio, check, edited   ***
	**************************************************************
	'''		
	def rappel_clic(self, widget, tree_column, tree_name, num_col):
		self.th.iter_select=' '
		if widget.get_cursor()[1] == tree_column:  # si la colonne est régler sur clic
			list_str=self.th.retourne_selection(tree_name)
			liste=list_str.split('@')			
			arg='%s,%s' % (liste.pop(0), num_col)
			list_str_re= '|'.join(liste) 			
			var='%s clic@%s@%s' % (tree_name, arg, list_str_re)
			self.send_data( var )
		return True
	
	def rappel_radio(self, cellrender, path, store, col, name_tree):
	 	if DEBUG: print self.DIC_RADIO[col]
		self.th.iter_select=' '
	 	old=self.DIC_RADIO[col]
	 	store[old][col]=False	
		store[path][col]=True
	 	self.DIC_RADIO[col]=path
	 	if DEBUG: print self.DIC_RADIO[col]
		liste=self.th.list_to_string( list(store[path]) )
		val="%s radio@%s,%s@%s" % ( name_tree, path, col, liste )
		self.send_data( val )			

	def rappel_toggled(self, cellrender, path, store, col, name_tree):
		etat=store[path][col]
		self.th.iter_select=' '
		if etat:
			cellrender.set_active(False)
			store[path][col]=False
		else:
			cellrender.set_active(True)
			store[path][col]=True
		liste=self.th.list_to_string( list(store[path]) )
		val="%s toggled@%s,%s@%s" % ( name_tree, path, col, liste )
		self.send_data( val )

	def rappel_edited(self,celltext, chemin, nouveau_texte, tree_name,
										 mystore, col, style, treeview):
		ancien_texte= mystore[chemin][col]
		mystore[chemin][col] = nouveau_texte
		ligne=self.th.list_to_string( list(mystore[chemin]) )
		val='%s %s@%s,%s@%s@%s' % (tree_name, style, chemin ,col, ancien_texte, ligne)
		self.send_data( val )
		if self.column_sizing: treeview.columns_autosize()
		


	'''
	******************************
	*** infos bulles du treeview
	******************************
	'''
	def query_tooltip(self,treeview, x, y, keyboard_mode, tooltip):
		y = y - self.size_cell  #Pour gérer le décallage des lignes
		store=treeview.get_model()
		name=treeview.get_name()
		info = treeview.get_path_at_pos(x, y)
		if info is None: return False  #Si rien en cette position, on n'affiche pas
		line=info[0][0]
		column=info[1]
		columns=treeview.get_columns()  # récupère toutes les colonnes
		col=columns.index(column)  # numéro de la colonne
		tuple_size=column.cell_get_size()[4]  # taille de la colonne 4 = hauteur cellule
		self.size_cell=tuple_size
		if line == -1 or col == -1: return False # Si on est dehors
		colonne=col # sauver num colonne
		try:
			dic_tooltip_name=dic_tooltip[name]  # {'treeview':{0:1,1:5,}, }
			if col in dic_tooltip_name:  # Si on assigne un text d'une autre colonne
				col=dic_tooltip_name[col]
				flag=False  # OK, on peut afficher
			else: flag=True
		except:
			flag=False  #On affiche par défaut, pas d'option
		if flag: return False
		label=str( store[line][col] )
		if line == self.tooltip_line and colonne == self.tooltip_col:  #on est dans la même colonne
			tooltip.set_markup( label )
			return True	# affichage	
		self.tooltip_line=line
		self.tooltip_col=colonne
		return False

	'''
	****************
	*** Divers   ***
	****************
	'''		
	def set_systray_icon(self):		
		menu, icon, bulle = systray_icon.split('@')
		if '.' in icon:
			self.systray = gtk.status_icon_new_from_file(icon)
		else:
			self.systray = gtk.status_icon_new_from_icon_name(icon)
		self.systray.set_tooltip(bulle)
		if menu:
			menu = self.widgets.get_widget(menu)
			self.systray.connect('popup-menu', self.popup_menu_cb, menu)
		self.systray.connect('activate', self.send_data, 'my_systray')
					
	def popup_menu_cb(self, widget, button, time, data = None):
		if button == 3:
			if data:
				data.show_all()
				data.popup(None, None, gtk.status_icon_position_menu,
				                3, time, self.systray)
					
	def apply_gtkrc(self, widget, gtkrc):
		gtk.rc_parse(gtkrc)
		screen = widget.get_screen()
		settings = gtk.settings_get_for_screen(screen)
		gtk.rc_reset_styles(settings)
		
	
	def modif_type(self, ligne):
	 	list_ligne=ligne.split('|')
	 	for elem in list_ligne:
	 		try:
	 			value=eval(elem)
	 			index=list_ligne.index(elem)
				list_ligne[index]=value
			except: pass
		return list_ligne
		
	def go_thread(self):
		self.th=MyThread(self)
		self.th.start()
		
	def send_data(self, data, arg=None):
		if arg is not None:
			data = arg
		self.th.send(data)
	
	def set_widget(self, cmd):
		arg='self.%s' % (cmd)
		exec( arg )
		
	def set_color(self, widget, etat, color):
		couleur=gtk.gdk.color_parse(color)
		widget=eval( 'self.%s' % (widget) )
		widget(eval(etat), couleur)
		
	def main(self):
		gtk.main()
		
		
		
		
class Commandes(object):
	'''
	**********************************************
	*** INTERPRETATION DES COMMANDES GLADE2SCRIPT
	**********************************************
	'''			
	'''
	*** CLIPBOARD
	'''	
	def CLIP(self, sortie):
		cmd='CLIP%s' % sortie.split('@@')[1]
		gobject.idle_add(getattr(self, cmd),sortie)
		
	def CLIPGET(self, data=None):
		self.gui.clipboard.request_text(self.clipboard_texte)
	
	def clipboard_texte(self, clipboard, texte, donnees):
		self.send( 'clipboard %s' % texte)			
	
	def CLIPSET(self, data=None):
		self.gui.clipboard.set_text( data.replace('CLIP@@SET@@','') )
						
	'''
	*** COULEUR
	'''		
	def COLOR(self, sortie):
		'''
		Modifie la couleur d'un widget
		  sortie = COLOR@@widget.modify@@gtk_state@@color
		'''
		widget_action, etat, color = sortie.split('@@')[1:]
		gobject.idle_add(self.gui.set_color, widget_action, etat, color)

					
	'''
	*** COMBOBOX
	'''				
	def COMBO(self, sortie):
		'''
		 sortie = COMBO@@CLEAR@@combobox
		 sortie = COMBO@@FINDDEL@@combobox@@item
		 sortie = COMBO@@FINDSELECT@@combobox@@item
		 sortie = COMBO@@SUPPLAST@@combobox
		'''
		cmd='COMBO%s' % sortie.split('@@')[1]
		names = sortie.split('@@')[2].split(',')
		for name in names:
			try:
				item = sortie.split('@@')[3]
			except:
				item = None
			combo, modele = self.return_tree_store(name)
			nb = len(modele)
			gobject.idle_add(getattr(self, cmd), nb, combo, modele, item)
		
	def COMBOCLEAR(self, nb, combo, modele, item):
		'''
		Supprime tous les éléments du combobox
		'''
		for i in range(nb):
			combo.remove_text(0)
			
	def COMBOFINDDEL(self, nb, combo, modele, item):
		'''
		Trouve et supprime une ligne par son item
		'''
		liste = []
		modele.foreach(self.find_tree_item, ('0', item, liste) )
		#combo.set_active( liste[0] )
		try:
			del modele[ liste[0] ]
		except: pass	
		
	def COMBOFINDSELECT(self, nb, combo, modele, item):
		'''
		Trouve et selectionne un item
		'''
		liste = []
		modele.foreach(self.find_tree_item, ('0', item, liste) )
		try:
			combo.set_active( liste[0][0] )
		except: pass	
	
	def COMBODELEND(self, nb, combo, modele, item):
		'''
		Supprime le dernier élément du combobox
		'''
		# soustraction car le nombre d'entrée est superieur au réel
		nb = nb -1
		combo.remove_text(nb)
						
	'''
	*** SORTIE
	'''	
	def EXIT(self, sortie):
		arg=sortie.split('@@')[1]
		if arg:
			self.stop('yes')
		else: self.stop('no')
							
	'''
	*** DIMENSION WINDOW
	'''			
	def GEO(self, sortie):
		'''
		Découpe la commande GEO@@GET => GEOGET
		'''
		cmd='GEO%s' % sortie.split('@@')[1]
		gobject.idle_add(getattr(self, cmd), sortie)
				
	def GEOGET(self, sortie):
		'''
		sortie = GEO@@GET@@widget
		'''
		nom = sortie.split('@@')[2]
		widget = eval('self.gui.%s' % (nom) )
		width, height = widget.get_size()
		X, Y = widget.get_position()
		self.send( '''%s "geo@%s,%s,%s,%s"''' % (nom, width, height, X, Y) )
	
	def GEOSET(self, sortie):
		'''
		sortie = GEO@@SET@@widget@@width,height,X,Y
		'''
		nom = sortie.split('@@')[2]
		widget = eval('self.gui.%s' % (nom) )
		width, height, X, Y = sortie.split('@@')[3].replace(' ','').split(',')
		widget.resize(int(width), int(height) )
		widget.move(int(X), int(Y) )
							
	'''
	*** PYGTK
	'''				
	def GET(self, sortie):
		'''
		Commande pygtk
		  sortie = GET@widget.cmd()
		'''
		sortie = sortie.split('GET@')[1]
		widget= sortie.split('(')[0].replace('.','_')
		var='self.gui.%s' % (sortie)
		result=eval(var)
		var_get='GET@%s="%s"' % ( widget, result )
		self.send(var_get)
							
	'''
	*** GTKRC
	'''				
	def GTKRC(self, sortie):
		'''
		Charge un fichier de style gtkrc
		  sortie = GTKRC@@widget@@gtkrcFile
		'''
		widget, rcfile = sortie.split('@@')[1:]
		widget=eval('self.gui.%s' % (widget) )
		self.gui.apply_gtkrc(widget, rcfile)
								
	'''
	*** IMAGE
	'''		
	def IMG(self, sortie):
		'''
		Modifie une image
		  sortie = IMG@@widget@@file@@width@@height
		'''
		widget, path, x, y = sortie.split('@@')[1:]
		if path:
			pixbuf=gtk.gdk.pixbuf_new_from_file_at_size( path, int(x), int(y) )
			img=eval('self.gui.%s' % (widget) ) 
			gobject.idle_add(img.set_from_pixbuf, pixbuf) 	
								
	'''
	*** RECUP ETAT TOOGLE WIDGET ENFANTS
	'''			
	def ISACTIVE(self, sortie):
		'''
		Récupère les etats des toggles d'un widget container
		  sortie = ISACTIVE@@widget
		'''
		widget_name = sortie.split('@@')[1]
		self.list_is_active = []
		widget = eval( 'self.gui.%s' % widget_name )
		self.IS_container( widget )
		if DEBUG: print '[ISACTIVE] ', self.list_is_active
		self.send( '%s isactive@%s' % (widget_name, ','.join(self.list_is_active) ) )
		
	def IS_container(self, widget):
		try:
			childs = widget.get_children()
		except:
			pass
		else:
			for child in childs:
				self.IS_container(child)
				self.IS_active(child)
	
	def IS_active(self, widget):
		try:
			value = widget.get_active()
		except:
			pass
		else:
			self.list_is_active.append( '%s' % widget.get_name() )
								
	'''
	*** ITER
	'''		
	def ITER(self, sortie):
		'''
		Appelle une fonction dans le script associé
		  sortie = ITER@@fonction
		'''
		arg=sortie.replace('ITER@@','')
		self.send( arg )
									
	'''
	*** COMMANDES MULTIPLE
	'''	
	def MULTI(self, sortie):
		'''
		Envoi une commande pour plusieurs widgets
		  sortie = MULTI@@SET@@cmd()@@widget,widget
		'''
		arg=sortie.replace('ITER@@','')
		cmd='MULTI%s' % sortie.split('@@')[1]
		getattr(self, cmd)(sortie)

	
	def MULTISET(self, sortie):
		cmd = sortie.split('@@')[2]
		l_widgets = sortie.split('@@')[3].split(',')
		for item in l_widgets:
			self.SET( 'SET@%s.%s' % (item, cmd) )
	
	def MULTIGET(self, sortie):
		cmd = sortie.split('@@')[2]
		l_widgets = sortie.split('@@')[3].split(',')
		for item in l_widgets:
			self.GET( 'GET@%s.%s' % (item, cmd) )
									
	'''
	*** NOTIFICATION
	'''			
	def NOTIFY(self, sortie):
		'''
		Notification pynotify
		  sortie = NOTIFY@@timer@@texte@@icon
		'''
		delay, titre, message, icon = sortie.split('@@')[1:]
		message=message.replace('\\n','\n')
		if not pynotify.init("Multi Action Test"):
			return
		if icon:
			if '/' in icon:
				uri = "file://%s" % icon
			else:
				uri=icon
			n = pynotify.Notification(titre, message, uri)
		else:
			n = pynotify.Notification(titre, message)
		if systray_icon is not None:
			n.attach_to_status_icon(self.gui.systray)
		n.show()
		if delay: t=int(delay)*1000
		else: t=3000
		n.set_timeout(t)
		if not n.show():
			print "Failed to send notification"
									
	'''
	*** DIMENSION ECRAN
	'''		
	def SCREEN(self, sortie):
		'''
		Charge la taille de l'écran dans l'environnement
		'''
		self.send('GET@screen_height="%s"' % self.gui.screen_height)
		self.send('GET@screen_width="%s"' % self.gui.screen_width)
								
	'''
	*** PYGTK
	'''		
	def SET(self, sortie):
		'''
		Commande pygtk
		  sortie = SET@widget.cmd()
		'''
		sortie = sortie.replace('SET@','')
		gobject.idle_add(self.gui.set_widget, sortie )
									
	'''
	*** STATUSBARRE
	'''	
	def STATUS(self, sortie):
		'''
		Affiche texte dans statusbarre.
		  sortie = STATUS@widget@@texte
		'''
		widget, text = sortie.split('@@')[1:]
		arg='self.gui.%s.push(self.gui.context_%s, "%s")' % (widget,widget,text)
		eval( arg ) 
									
	'''
	*** TOGGLE
	'''	
	def TOGGLE(self, sortie):
		'''
		Bascule l'état d'un widget.
		  sortie = TOOGLE@@ACTIVE@@widget,widget
		'''
		cmd='TOGGLE%s' % sortie.split('@@')[1]
		gobject.idle_add(getattr(self, cmd), sortie)
		
	def TOGGLESENSITIVE(self, sortie):
		'''
		  sortie = TOOGLE@@SENSITIVE@@widget,widget
		'''
		l_widgets = sortie.split('@@')[2].split(',')
		for item in l_widgets:
			widget = eval('self.gui.%s' % (item) )
			self.gui.toggle_sensitive(widget)	
	
	def TOGGLEEXPANDER(self, sortie):
		l_widgets = sortie.split('@@')[2].split(',')
		for item in l_widgets:
			widget = eval('self.gui.%s' % (item) )
			if widget.get_expanded():
				widget.set_expanded(False)
			else:
				widget.set_expanded(True)	
	
	def TOGGLEVISIBLE(self, sortie):
		l_widgets = sortie.split('@@')[2].split(',')
		for item in l_widgets:
			widget = eval('self.gui.%s' % (item) )
			self.gui.toggle_visible(widget)
	
	def TOGGLEACTIVE(self, sortie):
		l_widgets = sortie.split('@@')[2].split(',')
		for item in l_widgets:
			widget = eval('self.gui.%s' % (item) )
			self.gui.toggle_active(widget)
									
	'''
	*** TREEVIEW
	'''		
	def TREE(self, sortie):
		cmd='TREE%s' % sortie.split('@@')[1]
		gobject.idle_add(getattr(self, cmd), sortie)
							
	def TREEINSERT(self, sortie):
		'''
		Ajoute au treview à un emplacement défini
		  sortie = TREE@@INSERT@@treeview@@line@@data
		  line défini le ligne 1, ou l'enfant 1:0
		'''
		name, path, value = sortie.split('@@')[2:]
		treeview, mystore = self.return_tree_store(name)
		iter, path = self.gui.try_path(path, mystore)	
		mystore.insert(iter, int(path), self.gui.modif_type(value) )
	
	def TREELOAD(self, sortie):
		'''
		Charge le treeview depuis un fichier.
		  sortie = TREE@@LOAD@@treeview@@fichier
		'''
		name, path = sortie.split('@@')[2:]
		try:
			treeview, mystore = self.return_tree_store(name)
			#mystore.clear()
			for ligne in file(path,'r'):
				ligne=ligne.strip()
				liste=self.gui.modif_type(ligne)
				position = liste[0]
				parent_iter, path = self.gui.try_path(position, mystore)
				mystore.append(parent_iter, liste)
		except ValueError, e: 
			print '==== [[ ERROR ]] ===>> %s' % e
	
	def TREEGET(self, sortie):
		'''
		Envoi la selection du treview.
		  sortie = TREE@@GET@@treeview
		'''
		name = sortie.split('@@')[2]
		result=self.retourne_selection(name)
		var_get='''GET@%s="%s"''' % ( name,result )
		self.send( var_get )
	
	def TREECELL(self, sortie):
		'''
		Modifie une cellule ou une ligne.
		  sortie = TREE@@CELL@@treeview@@line[,col]@@data
		'''
		name, place, value = sortie.split('@@')[2:]
		self.modif_cell_str(name, place, value)
	
	def TREEEND(self, sortie):
		'''
		Ajoute une ligne en fin de treeview.
		  sortie = TREE@@END@@treeview@@data
		'''
		name, value = sortie.split('@@')[2:]
		treeview, modele = self.return_tree_store(name)
		modele.append(None, value.split('|') )
		num_row=len(list(modele))-1
		if num_row > 0:
			treeview.scroll_to_cell(num_row)

	def TREEUP(self, sortie):
		'''
		Monte la ligne sélectionnée.
		  sortie = TREE@@UP@@treeview
		'''
		iter, path, model = self.tree_up_down(sortie)
		l = list(path)
		#enleve 1 au dernier num du path
		l[-1] = l[-1] -1
		path = tuple(l)
		new_iter = model.get_iter(path)
		model.move_before(iter, new_iter)

	def TREEDOWN(self, sortie):
		'''
		Descend la ligne sélectionnée.
		  sortie = TREE@@DOWN@@treeview
		'''
		iter, path, model = self.tree_up_down(sortie)
		new_iter = model.iter_next(iter)
		model.move_after(iter, new_iter)

	def tree_up_down(self, sortie):
		'''
		Gère la montée ou descente de ligne.
		  sortie = TREE@@DOWN/UP@@treeview
		'''
		name = sortie.split('@@')[2]
		treeview, modele = self.return_tree_store(name)
		selection = treeview.get_selection()
		model, iter = selection.get_selected()
		path = model.get_path(iter)
		return (iter, path, model)

	def TREEPROG(self, sortie):
		'''
		Modifie la progressbar.
		  sortie = TREE@@PROG@@treeview@@line,col@@value
		'''
		name, place, value = sortie.split('@@')[2:]
		self.modif_cell_int(name, place, value)
		
	def TREESAVE(self, sortie):
		'''
		Sauvegarde le treeview dans u fichier.
		  sortie = TREE@@SAVE@@treeview@@fichier
		'''
		name, fichier = sortie.split('@@')[2:]
		treeview, modele = self.return_tree_store(name)
		file(fichier,'w')
		self.fichier_save_tree=open(fichier,'a')
		modele.foreach(self.sauv_tree, fichier)
		self.fichier_save_tree.close()
	
	def TREEHIZO(self, sortie):
		'''
		Envoie le treeview dans l'envirronement.
		Les sauts de ligne seront remplacés par des @@.
		  sortie = TREE@@HIZO@@treeview
		'''
		name = sortie.split('@@')[2]
		self.list_hizo=[]
		treeview, modele = self.return_tree_store(name)
		modele.foreach(self.return_tree)
		var='@@'.join(self.list_hizo)
		tree="""%s hizo@%s""" % (name, var)
		self.send(tree)
	
	def TREECLEAR(self, sortie):
		'''
		Efface le treeview.
		  sortie = TREE@@CLEAR@@treeview
		'''
		names = sortie.split('@@')[2].split(',')
		for name in names:
			mystore=eval('self.gui.store_%s' % (name) )
			mystore.clear()
		
	def TREEFIND(self, sortie):
		'''
		Trouve et envoie les lignes d'après un motif et une colonne.
		  sortie = TREE@@FIND@@treeview@@col@@motif
		'''
		name, col, item = sortie.split('@@')[2:]
		treeview, modele = self.return_tree_store(name)
		liste = []
		modele.foreach(self.find_tree_item, (col, item, liste) )
		liste_find = [item]
		for item in liste:
			liste_find.append( self.tup_path_to_str_path(item) )
		liste_find = self.list_to_string(liste_find)
		cmd="""%s find@%s""" % (name, liste_find)
		self.send(cmd)
	
	def TREEFINDDEL(self, sortie):
		'''
		Trouve et selectionne une ligne d'après un motif et une colonne.
		  sortie = TREE@@FINDSELECT@@treeview@@col@@motif
		'''
		name, col, item = sortie.split('@@')[2:]
		treeview, modele = self.return_tree_store(name)
		liste = []
		modele.foreach(self.find_tree_item, (col, item, liste) )
		if liste:
			liste_ligne = list( modele[ liste[0] ] )
			del modele[ liste[0] ]
			liste_find = self.list_to_string(liste_ligne)
			str_path = self.tup_path_to_str_path( liste[0] )
			cmd="""%s finddel@%s@%s""" % (name, str_path, liste_find)
		else: cmd="""%s finddel@NoItemFind""" % name
		self.send(cmd)
	
	def tup_path_to_str_path(self, path):
		try:
			parent, child = path
			str_path = '%s:%s' % (parent, child)
		except:
			str_path = path[0]
		return str_path
	
	def TREEFINDSELECT(self, sortie):
		'''
		Trouve et selectionne une ligne d'après un motif et une colonne.
		  sortie = TREE@@FINDSELECT@@treeview@@col@@motif
		'''
		name, col, item = sortie.split('@@')[2:]
		treeview, modele = self.return_tree_store(name)
		liste = []
		modele.foreach(self.find_tree_item, (col, item, liste) )
		if liste: treeview.set_cursor( liste[0] )		
		
	def find_tree_item(self, liststore, path, iter, tup):
		col, item, liste = tup
		donnees=list(liststore[iter])
		try:
			if item in donnees[int(col)]:
				liste.append(path)
		except: pass
		
	def return_tree_store(self, name):
		treeview=eval('self.gui.%s' % (name) )
		modele=treeview.get_model()
		return treeview, modele
		
	
	def TREEFORCE_SELECT(self, sortie):
		'''
		Outrepasse la sécurité.
		  sortie = TREE@@FORCE_SELECT@@treeview
		'''
		self.iter_select=True
									
	'''
	*** TEXTVIEW
	'''				
	def TEXT(self, sortie):
		cmd='TEXT%s' % sortie.split('@@')[1]
		gobject.idle_add(getattr(self, cmd), sortie)
		
	def TEXTCLEAR(self, sortie):
		'''
		Efface le textview.
		  sortie = TEXT@@CLEAR@@textview
		'''		
		names = sortie.split('@@')[2].split(',')
		for name in names:
			buffertexte=eval('self.gui.%s.get_buffer()' % (name) )
			start, end = buffertexte.get_bounds()
			buffertexte.delete(start, end)
				
	def TEXTLOAD(self, sortie):	
		'''
		Charge le textview depuis un fichier.
		  sortie = TEXT@@LOAD@@textview@@fichier
		'''			
		name, path = sortie.split('@@')[2:]
		try:
			buffertexte=eval('self.gui.%s.get_buffer()' % (name) )
			fichier = open(path, "r")
			chaine = fichier.read()
			fichier.close()
			buffertexte.set_text(chaine)
		except: pass
	
	def TEXTEND(self, sortie):
		'''
		Ajoute en fin de textview.
		  sortie = TEXT@@END@@textview@@texte
		'''					
		name, text = sortie.split('@@')[2:]
		textview=eval('self.gui.%s' % (name) )
		buffertexte=textview.get_buffer()
		start, end = buffertexte.get_bounds()
		text = text.replace('\\n', '\n')
		buffertexte.insert(end, text)
		p_text_mark = buffertexte.create_mark ('p_buffer', end, False)
		textview.scroll_to_mark(p_text_mark,0.0)
		
	def TEXTDELEND(self,sortie):
		'''
		Supprime la dernière ligne du textview.
		  sortie = TEXT@@DEL_END@@textview
		'''	
		name = sortie.split('@@')[2]
		textview=eval('self.gui.%s' % (name) )
		buffertexte=textview.get_buffer()
		nombre_lignes = buffertexte.get_line_count()
		debut_end = buffertexte.get_iter_at_line(nombre_lignes-2)
		start, end = buffertexte.get_bounds()
		buffertexte.delete(debut_end, end)
	
	def TEXTSAVE(self, sortie):	
		'''
		Sauvegarde le textview dans un fichier.
		  sortie = TEXT@@SAVE@@textview@@fichier
		'''		
		name, path = sortie.split('@@')[2:]
		try:
			buffertexte=eval('self.gui.%s.get_buffer()' % (name) )
			start, end = buffertexte.get_bounds()
			texte=buffertexte.get_text(start,end)
			fichier = open(path, "w")
			fichier.writelines(texte)
			fichier.close()
		except: pass
	
	def TEXTHIZO(self, sortie):
		'''
		Envoie le textview dans l'envirronement.
		Les sauts de ligne seront remplacés par des @@.
		  sortie = TEXT@@HIZO@@treeview
		'''
		name = sortie.split('@@')[2]
		buffertexte=eval('self.gui.%s.get_buffer()' % (name) )
		start, end = buffertexte.get_bounds()
		texte=buffertexte.get_text(start,end)
		texte=texte.replace("'","\\'").replace('"','\\"').replace('\n','@@')
		self.send( """%s hizo@%s""" % (name, texte) )
	
	def TEXTCURSOR(self, sortie):
		'''
		Ajoute un texte au curseur du textview.
		  sortie = TEXT@@CURSOR@@textview@@texte
		'''					
		name, text = sortie.split('@@')[2:]
		buffertexte=eval('self.gui.%s.get_buffer()' % (name) )
		buffertexte.insert_at_cursor(text)		
	
	def TEXTAUTOUR(self, sortie):
		'''
		Entoure une selection de texte.
		  sortie = TEXT@@AUTOUR@@textview@@texteAvant@@texteAprès
		'''					
		name, avant, apres = sortie.split('@@')[2:]
		buffertexte=eval('self.gui.%s.get_buffer()' % (name) )
		start, end = buffertexte.get_selection_bounds()
		buffertexte.insert(start, avant)
		start, end = buffertexte.get_selection_bounds()
		buffertexte.insert(end, apres)
									
	'''
	*** TERMINAL
	'''		
	def TERM(self, sortie):
		cmd='TERM%s' % sortie.split('@@')[1]
		gobject.idle_add(getattr(self, cmd),sortie)
		
	def TERMFONT(self, sortie):
		'''
		Modifie la police du terminal.
		  sortie = TERM@@FONT@@font
		'''					
		font = sortie.split('@@')[2]
		self.gui.terminal.set_font_from_string(font)
	
	def TERMKILL(self, sortie):
		'''
		Tue le processus en cours du terminal.
		  sortie = TERM@@KILL
		'''					
		self.gui.kill_term_child(None)
		
	def TERMWRITE(self, data=None):
		'''
		Ecrit dans le terminal.
		  sortie = TERM@@XRITE@@texte
		'''					
		cmd = data.replace('TERM@@WRITE@@','').replace('\\n','\n').replace('\\r','\r')
		self.gui.terminal.feed(cmd) 
		
	def TERMSEND(self, data=None):
		'''
		Envoie une commande dans le terminal.
		  sortie = TERM@@SEND@@commande
		'''					
		cmd = data.replace('TERM@@SEND@@','').replace('\\n','\n').replace('\\r','\r')
		self.gui.terminal.feed_child(cmd) 
	
	
	def TOOLTIPUP(self, data=None):
		#print 'in tool'
		#print self.gui._label1.get_display()
		gobject.idle_add( self.gui.window1.trigger_tooltip_query )
		#gobject.idle_add( gtk.tooltip_trigger_tooltip_query, self.gui.window1.get_display() )
		#print 'in tool'
	
	'''
	*****************
	*** UTILITAIRES
	*****************
	'''

	def list_to_string(self, donnees):
		'''
		Convertie une liste en string pour les treeview
		'''
		return '|'.join( map(str, donnees) )

	def sauv_tree(self, liststore, path, iter, fichier):
		donnees=list(liststore[iter])
		ligne=self.list_to_string(donnees)
		self.fichier_save_tree.write(ligne+'\n')
		
	def return_tree(self, liststore, path, iter):
		donnees=list(liststore[iter])
		ligne=self.list_to_string(donnees)
		self.list_hizo.append(ligne)
		if DEBUG: print '[return_tree] hizo@%s' % (ligne)

	def modif_cell_int(self, name, place, value):
		store=eval('self.gui.store_%s' % (name) )
		row, col = place.split(',')
		store[row][int(col)] = int(value)
		
	def modif_cell_str(self, name, place, value):
		if self.iter_select is None: return
		store=eval('self.gui.store_%s' % (name) )
		treeview=eval('self.gui.%s' % (name) )
		if place:  # 3,1
			try:
				row, col = place.split(',')
				store[row][int(col)] = value  #modif cellule
				#print "modif celluel", value
			except:
				if value:
					liste=self.gui.modif_type(value)
					#row = eval( '(%s)' % row.replace(':',',') )
					#print 'modif', row
					store[place]= liste  # modif ligne
				else:
					try:
						#print "in try"
						iter=store.get_iter(place)
						store.remove(iter)  # supprimer ligne par son numéro
						self.iter_select=None  # plus de selection
					except: pass
		elif self.iter_select is not None: # supprimer ligne sélectionnée
			store.remove(self.iter_select)  
			self.iter_select=None
		if self.gui.column_sizing: treeview.columns_autosize()
	
	def retourne_selection(self,name):
		treeview=eval('self.gui.%s' % (name) )
		modele =treeview.get_model()
		sel=treeview.get_selection()
		( model,iter ) = sel.get_selected()
		self.iter_select=iter
		if iter is not None:
			path=model.get_string_from_iter(iter)
			if DEBUG: print 'DEBUG=>: [retourne_selection] : %s %s' % (path, list(model[iter]) )
			#print model.get_string_from_iter(iter)
			liste=list(model[iter])
			ligne=str(path[0])
			list_str=self.list_to_string(liste)
			return '%s@%s' % (path, list_str)
			#return list_str
		else: return 'None'  #['None']





class MyThread(threading.Thread, Commandes):
	'''
	********************************************************
	*** RECEPTION DES COMMANDES GLADE2SCRIPT DEPUIS LE FIFO
	********************************************************
	'''
	def __init__(self, gui):        
		threading.Thread.__init__(self)
		self.gui=gui
		self.Terminated=False
		self.iter_select=None
		self.n_break=0
	
	def run(self):
		if import_py is not None:
			module = os.path.splitext(import_py)[0]
			if os.path.isfile(import_py):
				path, module = os.path.split(module)
				sys.path.append(path)
			exec('import %s as myimport' % module)
			self.IMPORT = myimport.Action(self)
		else:
			args = shlex.split( s_bash )
			sb=subprocess.Popen(args,stderr=subprocess.STDOUT,stdout=subprocess.PIPE)
			PID=sb.pid
			self.path_FIFO='/tmp/FIFO%s' % (PID)		
			while not self.Terminated:
				sortie=sb.stdout.readline().rstrip()
				if DEBUG: print 'DEBUG=>: in thread py', sortie
				if sortie =='':
					self.n_break=+1
					if self.n_break==10 : break
				try:
					cmd=sortie.split('@')[0]
					getattr(self, cmd)(sortie)
				except: pass				
	
	def from_import(self, sortie):
		try:
			cmd=sortie.split('@')[0]
			getattr(self, cmd)(sortie)
		except: pass
		if DEBUG: print 'DEBUG=>: in thread py', sortie
			
	def send(self,data):
		if import_py is not None:
			self.IMPORT.from_glade(data)
			if DEBUG: print "DEBUG => Send from glade:", data
			return
		if data:
			time.sleep(0.001)
			i=open(self.path_FIFO,'w')
			i.write(data+'\n')
			#i.write(data)
			#i.flush()
		if DEBUG: print "DEBUG => FIFO write:", data
		
	def stop(self,arg): 				
		self.send('QuitNow')
		if not import_py:				
			self.Terminated=True
			global EXIT
			if arg == 'no': 
				print 'EXIT="no"'
				EXIT='no'
			else: 
				self.stop_save()
				print 'EXIT="yes"'
				EXIT='yes'
		if term_box:	
			self.gui.kill_term_child(None)
		gtk.main_quit()
		try:
		 os.remove(self.path_FIFO)
		except: pass
		
	def stop_save(self):
		for item in l_sortie:
			wid = eval('self.gui.%s' % (item) )
			if 'GtkTreeView' in str(wid):
				retour=self.retourne_selection(item)
				if retour:
					print '''%s="%s"''' % (item, retour)
				continue
			widget= item.replace('.','_')
			var='self.gui.%s ()' % (item)
			result=eval(var)
			print '%s="%s"' % (widget , result)
		

if DEBUG: print 'glade2script 2.2.1 , Copyright (C) 2010-2011 , mars 2011'		
m=Gui()
m.go_thread()
m.main()
if import_py is None:
	if EXIT == 'yes': sys.exit(0)
	elif EXIT == 'no': sys.exit(1)
