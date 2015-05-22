echo "### Gestion du calendrier ###"

_btn_lundi() {
    if [[ $@ == "True" ]]; then
        echo "SET@_btn_lundi.set_active(True)
SET@_btn_mardi.set_active(False)
SET@_btn_mercredi.set_active(False)
SET@_btn_jeudi.set_active(False)
SET@_btn_vendredi.set_active(False)
SET@_btn_samedi.set_active(False)
SET@_btn_dimanche.set_active(False)
TREE@@CLEAR@@tw_calendar_days
TREE@@LOAD@@tw_calendar_days@@$HOME/.malokal/schedule/1"
    fi
}

_btn_mardi() {
    if [[ $@ == "True" ]]; then
        echo "SET@_btn_lundi.set_active(False)
SET@_btn_mardi.set_active(True)
SET@_btn_mercredi.set_active(False)
SET@_btn_jeudi.set_active(False)
SET@_btn_vendredi.set_active(False)
SET@_btn_samedi.set_active(False)
SET@_btn_dimanche.set_active(False)
TREE@@CLEAR@@tw_calendar_days
TREE@@LOAD@@tw_calendar_days@@$HOME/.malokal/schedule/2"
    fi
}

_btn_mercredi() {
    if [[ $@ == "True" ]]; then
        echo "SET@_btn_lundi.set_active(False)
SET@_btn_mardi.set_active(False)
SET@_btn_mercredi.set_active(True)
SET@_btn_jeudi.set_active(False)
SET@_btn_vendredi.set_active(False)
SET@_btn_samedi.set_active(False)
SET@_btn_dimanche.set_active(False)
TREE@@CLEAR@@tw_calendar_days
TREE@@LOAD@@tw_calendar_days@@$HOME/.malokal/schedule/3"
    fi
}

_btn_jeudi() {
    if [[ $@ == "True" ]]; then
        echo "SET@_btn_lundi.set_active(False)
SET@_btn_mardi.set_active(False)
SET@_btn_mercredi.set_active(False)
SET@_btn_jeudi.set_active(True)
SET@_btn_vendredi.set_active(False)
SET@_btn_samedi.set_active(False)
SET@_btn_dimanche.set_active(False)
TREE@@CLEAR@@tw_calendar_days
TREE@@LOAD@@tw_calendar_days@@$HOME/.malokal/schedule/4"
    fi
}

_btn_vendredi() {
    if [[ $@ == "True" ]]; then
        echo "SET@_btn_lundi.set_active(False)
SET@_btn_mardi.set_active(False)
SET@_btn_mercredi.set_active(False)
SET@_btn_jeudi.set_active(False)
SET@_btn_vendredi.set_active(True)
SET@_btn_samedi.set_active(False)
SET@_btn_dimanche.set_active(False)
TREE@@CLEAR@@tw_calendar_days
TREE@@LOAD@@tw_calendar_days@@$HOME/.malokal/schedule/5"
    fi
}

_btn_samedi() {
    if [[ $@ == "True" ]]; then
        echo "SET@_btn_lundi.set_active(False)
SET@_btn_mardi.set_active(False)
SET@_btn_mercredi.set_active(False)
SET@_btn_jeudi.set_active(False)
SET@_btn_vendredi.set_active(False)
SET@_btn_samedi.set_active(True)
SET@_btn_dimanche.set_active(False)
TREE@@CLEAR@@tw_calendar_days
TREE@@LOAD@@tw_calendar_days@@$HOME/.malokal/schedule/6"
    fi
}

_btn_dimanche() {
    if [[ $@ == "True" ]]; then
        echo "SET@_btn_lundi.set_active(False)
SET@_btn_mardi.set_active(False)
SET@_btn_mercredi.set_active(False)
SET@_btn_jeudi.set_active(False)
SET@_btn_vendredi.set_active(False)
SET@_btn_samedi.set_active(False)
SET@_btn_dimanche.set_active(True)
TREE@@CLEAR@@tw_calendar_days
TREE@@LOAD@@tw_calendar_days@@$HOME/.malokal/schedule/7"
    fi
}
