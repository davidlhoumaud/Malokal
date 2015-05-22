#! /usr/bin/env python
# -*- coding: utf-8 -*-

from mymplayer import MyPlayer
import shlex


class Plugin(object):
    def __init__(self, g2s, cmd):
        '''
        @param g2s instance glade2script
        @param cmd name@@drawing@@line options@@progress function@@output function
        '''
        self.g2s = g2s
        self.send = g2s.send
        l = cmd.split('@@')
        self.name = l.pop(0)
        drawing, option, self.p_cb, self.o_cb = l
        arg = []
        if drawing != 'None':
            wid = getattr(g2s.gui, drawing).window.xid
            arg = ['-wid', str(wid)]
        if option != "None":
            arg += shlex.split(option)
        #print arg
        self.player = MyPlayer(arg)
        self.player.connect('eof', self.player_eof_cb)
        self.player.connect('starting', self.starting_cb)
        self.player.connect('metadata', self.metadata_cb)
        self.player.connect('media-info', self.player_media_info_cb)
        if self.p_cb != "None":
            self.player.connect('position', self.player_position_cb)
        if self.o_cb != "None":
            self.player.connect('verbose', self.player_verbose_cb)
        self.player.start()
        pass 
    
    def player_media_info_cb(self, th, arg):
        args = [ '%s="%s"' % (k,v) for k,v in arg.iteritems()]
        self.send('%s mediainfo@%s' % (self.name, '@@'.join(args)) )
    
    def metadata_cb(self, th, arg):
        args = [ '%s="%s"' % (k,v) for k,v in arg.iteritems()]
        self.send('%s metadata@%s' % (self.name, '@@'.join(args)) )
    
    def player_position_cb(self, th, arg):
        args = [ '%s=%s' % (k,v) for k,v in arg.iteritems()]
        self.send('%s position@%s' % (self.p_cb, '@@'.join(args)) )
    
    def player_verbose_cb(self, th, arg):
        self.send('%s verbose@%s' % (self.o_cb, arg) )
    
    def starting_cb(self, th, arg):
        self.send('%s starting@%s' % (self.name, th.metadata['uri']) )
        
    def player_eof_cb(self, th, code, arg):
        self.send('%s eof@%s@%s' % (self.name, code, arg) )
    
    def CMD(self, cmd):
        cmd_e = 'self.player.%s' % cmd
        arg = eval(cmd_e)
        #print cmd_e,arg
        if arg is not None:
            cmd = cmd.split('(')[0]
            try:
                prefixe, cmd = cmd.split('.')
            except:
                prefixe = cmd
            self.send('%s %s@%s %s' % (self.name, prefixe, cmd, arg))

        
        
