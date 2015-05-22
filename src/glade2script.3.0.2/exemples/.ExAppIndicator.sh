#!/bin/bash
##############################################################################################
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
###############################################################################################
### APP INDICATOR ###
_menuitem_attention() {
    echo "SET@app_indic.set_status(appindicator.STATUS_ATTENTION)"
}
_menuitem_deactive() {
    echo "SET@app_indic.set_status(appindicator.STATUS_PASSIVE)"
    # quit script for the exemple
    sleep 2
    echo "EXIT@@"
}
btn_activate() {
    echo "SET@app_indic.set_status(appindicator.STATUS_ACTIVE)"
}
btn_deactivate() {
    echo "SET@app_indic.set_status(appindicator.STATUS_PASSIVE)"
}
btn_attention() {
    echo "SET@app_indic.set_status(appindicator.STATUS_ATTENTION)"
}

### SYSTRAY ICON ###
systray1() {
    echo "SET@systray1.set_visible(False)"
}
systray2() {
    echo "SET@systray2.set_visible(False)"
}
btn_show_sys1() {
    echo "SET@systray1.set_visible(True)"
}
btn_show_sys2() {
    echo "SET@systray2.set_visible(True)"
}
btn_hide_sys1() {
    systray1
}
btn_hide_sys2() {
    systray2
}

echo "SYSTRAY@@systray1@@_menu@@gtk-yes@@systray 1"
echo "SYSTRAY@@systray2@@None@@gtk-no@@systray 2"
# indicate icon folder path or Npne, the current folder used here to find tux.png image
echo "APPINDICATOR@@app_indic@@gtk-yes@@_menu@@$PWD"
# set the appindicator.STATUS_ATTENTION icon
echo "SET@app_indic.set_attention_icon('tux')"


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