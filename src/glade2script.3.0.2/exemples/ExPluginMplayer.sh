#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################
window1() { # call when window destroyed
    echo "PLUGIN@@CMD@@MyPlayer@@cmd.quit(0)"
    sleep 1
    echo "EXIT@@"
}

###########################
## PLAYER CALLBACKS
###########################

MyPlayer() {
    argv=$@
    pref=${argv%%@*}
    arg=${argv#*@}
    
    case $pref in
    
        mediainfo ) # call when the file was loaded
            eval $(echo -e "${arg//@@/\n}")
            echo "SET@_label_audio_info.set_text('''$audio_decoder\\n$audio_output\\n$audio_info\\n$audio_codec''')"
            echo "SET@_label_video_info.set_text('''$video_decoder\\n$video_info\\n$video_codec''')";;
        
        metadata ) # call when the file was loaded
            eval $(echo -e "${arg//@@/\n}")
            echo "SET@_label_info.set_text('Artist: $artist, Title: $title')";;
        
        prop ) # call when testing mplayer property
            echo "SET@_label_retour_cmd.set_text('${arg}')";;
        
        cmd ) # call when testing mplayer command
            echo "SET@_label_retour_cmd.set_text('${arg}')";;
        
        eof ) # call at the end of file
            echo "SET@_hscale1.set_value(0)"
            echo "SET@_label_time.set_text('00:00.0 / 00:00.0')"
            echo "SET@_label_info.set_text('End of file ...')";;
        
        starting ) # call at starting play
            echo "SET@window1.set_title('Playing file: $arg')";;
        
    esac
    
}

ProgressPlayerCb() {
    if $flag_scale; then return; fi
    argv=$@
    l=${argv#*@}
    eval $(echo -e "${l//@@/\n}")
    echo "SET@_hscale1.set_value($percent)"
    echo "SET@_label_time.set_text('$format_pos / $format_length')"
    
}

VerbosePlayerCb() {
    :
}


###########################
## GUI ACTIONS
###########################
_filechooserbutton1() {
    fichier=$@
}
# commands & props testing widgets 
_entry_cmd() {
    ex_cmd=$@
}
_entry_arg() {
    ex_arg=$@
}
btn_cmd() {
    echo "PLUGIN@@CMD@@MyPlayer@@cmd.$ex_cmd('$ex_arg')"
}
btn_prop() {
    echo "PLUGIN@@CMD@@MyPlayer@@prop.$ex_cmd('$ex_arg')"
}
# player management
btn_play() {
    echo "PLUGIN@@CMD@@MyPlayer@@loadfile('$fichier')"
}
btn_pause() {
    echo "PLUGIN@@CMD@@MyPlayer@@pause()"
}
btn_stop() {
    echo "PLUGIN@@CMD@@MyPlayer@@cmd.stop()"
}
# seek management
flag_scale=false
_hscale1() {
    argv=$@
    pref=${argv%%@*}
    arg=${argv#*@}
    
    case $pref in
        press_event ) 
            flag_scale=true;;
        
        release_event )
            flag_scale=false
            echo "PLUGIN@@CMD@@MyPlayer@@cmd.seek('$scale 1')";;
        
        [0-9]* )
            scale=$arg;;
    esac
}

###################################
### START
###################################
# init plugin
#echo "PLUGIN@@INIT@@g2sMplayer@@MyPlayer@@_drawingarea1@@-msglevel global=6@@ProgressPlayerCb@@VerbosePlayerCb"
#echo "PLUGIN@@INIT@@g2sMplayer@@MyPlayer@@_drawingarea1@@None@@None@@VerbosePlayerCb"
echo "PLUGIN@@INIT@@g2sPluginMplayer@@MyPlayer@@_drawingarea1@@None@@ProgressPlayerCb@@None"
echo "EXEC@@self.MyPlayer.player.isVideo = True"



##########################################################################################
while read ligne; do
    if [[ "$ligne" =~ GET@ ]]; then
       eval ${ligne#*@}
       echo "DEBUG => in boucle bash :" ${ligne#*@}
    else
       echo "DEBUG=> in bash NOT GET" $ligne
       $ligne
   fi
done < <(while true; do
    read entree < $FIFO
    [[ "$entree" == "QuitNow" ]] && break
     echo $entree
done)
exit
