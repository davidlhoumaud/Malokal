echo "### Contrôles d'écoute ###"


_btn_current_play() {
    port=`./cfgedit -r port "$HOME/.malokal/malokal.cfg"`
    if [[ $port != "" && $port -lt 3399 ]]; then
        port=$((port+1))
        ./cfgedit -w port $port "$HOME/.malokal/malokal.cfg"
        instance_port=$port
    else 
        port=3300
        ./cfgedit -w port 3300 "$HOME/.malokal/malokal.cfg"
        instance_port=3300
    fi
    ./odyo play "$_info_pathfile" 0 0 host=localhost:$port &
    curtitle=`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f3`
    curalbum=`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f4`
    curartist=`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f5`
    curyear=`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f7`
    
    echo "SET@_label_current1.set_markup(\"<span color='black' size='xx-large'><b>$curtitle</b> by <b>$curartist</b></span>\")
SET@_label_current2.set_markup(\"<span color='black' size='large'>of <b>$curalbum</b> in <b>$curyear</b></span>\")"
    
    touch $HOME/.malokal/current
    refresh_time_current &
    echo "SET@_btn_current_play.set_sensitive(False)
SET@_btn_current_stop.set_sensitive(True)"
PLAYERACTIF=1
}



refresh_time_current() {
    port=`./cfgedit -r port "$HOME/.malokal/malokal.cfg"`
    startdelay=3
    while [[ -f $HOME/.malokal/current ]]; do
        ./odyo filename host=localhost:$port | grep http://
        if [[ $? -eq 1 ]]; then
            hms_time_preview=`./odyo position 0 0 host=localhost:$port`
            ms_current=`echo "$hms_time_preview" | cut -d';' -f1`
            totalhms=`echo "$hms_time_preview" | cut -d'|' -f3 | cut -d';' -f1`
            
            if [[ "$ms_current" -eq "" ]]; then
                _btn_current_stop
                break
            fi
            progress_fraction=`python -c "print $ms_current.000000000/$totalhms"`
            

            echo "SET@_label_current_rhms.set_markup(\"<span color='green' size='xx-large'><b>`echo "$hms_time_preview" | cut -d'|' -f2 | cut -d';' -f2`</b></span>\")
SET@_label_current_hms.set_markup(\"<span color='red' size='xx-large'><b>`echo "$hms_time_preview" | cut -d'|' -f1 | cut -d';' -f2`</b></span>\")
SET@_progress_current.set_fraction($progress_fraction)"
        fi
            timepurcent=`echo $progress_fraction | cut -d'.' -f1`
            if [[ "$timepurcent" -eq "" ]]; then
                timepurcent=0
            fi
            if [[ $timepurcent -eq 1 ]]; then
                if [[ $startdelay -eq 0 ]]; then
                    _btn_current_stop
                    break
                fi
                startdelay=$((startdelay-1))
            fi
        
    done
    
    echo "SET@_btn_current_play.set_sensitive(True)
SET@_btn_current_stop.set_sensitive(False)
SET@_label_current_rhms.set_markup(\"<span color='green' size='xx-large'><b>00:00</b></span>\")
SET@_label_current_hms.set_markup(\"<span color='red' size='xx-large'><b>00:00</b></span>\")
SET@_progress_current.set_fraction(0.0)
SET@_label_current1.set_markup(\"<span color='black' size='xx-large'><b>Title</b> by <b>Artist</b></span>\")
SET@_label_current2.set_markup(\"<span color='black' size='large'>of <b>Album</b> in <b>2014</b></span>\")"
    numline_current=$((numline_current+1))
    echo "TREE@@SELECT@@tw_current@@$numline_current"
    
}

_btn_current_stop() {
    port=`./cfgedit -r port "$HOME/.malokal/malokal.cfg"`
    ./odyo stop 0 0 host=localhost:$port &
    ./odyo stop 0 0 host=localhost:$((port-1)) &
    rm -f $HOME/.malokal/current
    PLAYERACTIF=0
}


