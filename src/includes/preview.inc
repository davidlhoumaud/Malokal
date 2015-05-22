echo "### Contrôles de la préécoute ###"


_btn_info_play() {
    port_preview=`./cfgedit -r port_preview "$HOME/.malokal/malokal.cfg"`
    if [[ $port_preview != "" && $port_preview -lt 9999 ]]; then
        port_preview=$((port_preview+1))
        ./cfgedit -w port_preview $port_preview "$HOME/.malokal/malokal.cfg"
        instance_port_preview=$port_preview
    else 
        port_preview=9900
        ./cfgedit -w port_preview 9900 "$HOME/.malokal/malokal.cfg"
        instance_port_preview=9900
    fi
    ./odyo play "$_info_pathfile_preview" 0 0 host=localhost:$port_preview &
    touch $HOME/.malokal/preview
    refresh_time_preview &
    echo "SET@_btn_info_play.set_sensitive(False)
SET@_btn_info_stop.set_sensitive(True)
SET@_vbox_info_hms.set_visible(True)
SET@_progress_info.set_visible(True)"
}



refresh_time_preview() {
    port_preview=`./cfgedit -r port_preview "$HOME/.malokal/malokal.cfg"`
    startdelay=3
    while [[ -f $HOME/.malokal/preview ]]; do
        ./odyo filename host=localhost:$port_preview | grep http://
        if [[ $? -eq 1 ]]; then
            hms_time_preview=`./odyo position 0 0 host=localhost:$port_preview`
            ms_current=`echo "$hms_time_preview" | cut -d';' -f1`
            totalhms=`echo "$hms_time_preview" | cut -d'|' -f3 | cut -d';' -f1`
            progress_fraction=`python -c "print $ms_current.000000000/$totalhms"`
            echo "SET@_label_info_hms.set_markup(\"<span color='green' size='small'>`echo "$hms_time_preview" | cut -d'|' -f2 | cut -d';' -f2`</span>\")
SET@_label_info_totalhms.set_markup(\"<span color='red' size='small'>`echo "$hms_time_preview" | cut -d'|' -f1 | cut -d';' -f2`</span>\")
SET@_progress_info.set_fraction($progress_fraction)"
        fi
            timepurcent=`echo $progress_fraction | cut -d'.' -f1`
            if [[ "$timepurcent" -eq "" ]]; then
                timepurcent=0
            fi
            if [[ $timepurcent -eq 1 ]]; then
                if [[ $startdelay -eq 0 ]]; then
                    ./odyo stop 0 0 host=localhost:$port_preview &
                    #./odyo stop 0 0 host=localhost:$((port_preview-1)) &
                    rm -f $HOME/.malokal/preview
                fi
                startdelay=$((startdelay-1))
            fi
        
    done
    
    echo "SET@_btn_info_play.set_sensitive(True)
SET@_btn_info_stop.set_sensitive(False)
SET@_vbox_info_hms.set_visible(False)
SET@_progress_info.set_visible(False)
SET@_progress_info.set_fraction(0.0)"
     
}

_btn_info_stop() {
    port_preview=`./cfgedit -r port_preview "$HOME/.malokal/malokal.cfg"`
    ./odyo stop 0 0 host=localhost:$port_preview &
    #./odyo stop 0 0 host=localhost:$((port_preview-1)) &
    rm -f $HOME/.malokal/preview
}


