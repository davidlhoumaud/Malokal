echo "### Mode de Malokal ###"

_mode_player() {
    if [[ $@ == "True" ]]; then
        __mode_player
    else
        __mode_schedule
    fi
}
_mode_schedule() {
    if [[ $@ == "True" ]]; then
        __mode_schedule
    else
        __mode_player
    fi
}

__mode_player() {
    echo "SET@_mode_player.set_active(True)
SET@_mode_schedule.set_active(False)
SET@_label_current_status.set_visible(False)
SET@_notebook_schedule.set_visible(False)
SET@_label_hours.set_visible(False)"
    rm -f $HOME/.malokal/globaldatetime
    MALOKAL_MODE="player"
    fileconfig_write "mode" "$MALOKAL_MODE" "$HOME/.malokal/malokal.cfg"
}
__mode_schedule() {
    echo "SET@_mode_player.set_active(False)
SET@_mode_schedule.set_active(True)
SET@_label_current_status.set_visible(True)
SET@_notebook_schedule.set_visible(True)
SET@_label_hours.set_visible(True)"
    touch $HOME/.malokal/globaldatetime
    _globaldatetime &
    MALOKAL_MODE="schedule"
    fileconfig_write "mode" "$MALOKAL_MODE" "$HOME/.malokal/malokal.cfg"
}
