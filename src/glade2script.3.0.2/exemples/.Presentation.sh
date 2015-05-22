#!/bin/bash
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo $FIFO
#############################################################################################
function btn_exec()
{
xterm -e "./go_$fichier; echo '[return to quit]';read" &
}

function treeview1()
{ 
if [[ "$1" =~ "double_click@" ]]; then
    arg="$(sed 's/double_click@//' <<< $1)"
    num_l=$(cut -d '|' -f1 <<< $arg)
    #f_glade="$(cut -d '@' -f1 --complement <<< $arg | cut -d '|' -f1)"
    f_glade="$(cut -d '|' -f2 <<< $arg)"
    if which glade-3 &>/dev/null; then
      glade-3 "${f_glade}" 2>/dev/null &
    else
      glade "${f_glade}" 2>/dev/null &
    fi
else
    num_l=$(cut -d '|' -f1 <<< $1)
    #arg="$(cut -d '@' -f1 --complement <<< $1)"
    arg=$(cut -d '|' -f1 --complement <<< $1)
    fichier="$(cut -d '.' -f1 <<< $arg).sh"
    path_lanceur_hide="./.go_$fichier"
    path_lanceur="./go_$fichier"
    path_asso_hide="./.$fichier"
    path_asso="./$fichier"
    echo "SET@_label1.set_markup('<b>Script lanceur</b>  <i>go_${fichier}</i>')"
    echo "SET@_label2.set_markup('<b>Script associé</b>  <i>${fichier}</i>')"
    echo "TEXT@@LOAD@@_text_lanceur@@go_${fichier}"
    echo "TEXT@@LOAD@@_text_code@@${fichier}"
fi
}

function btn_gedit_lanceur()
{
gedit "./go_${fichier}" &
}

function btn_save_lanceur()
{
[ ! -e "$path_lanceur_hide" ] && cp "$path_lanceur" "$path_lanceur_hide"
echo "TEXT@@SAVE@@_text_lanceur@@go_${fichier}"
}

function btn_rest_lanceur()
{
[ -e "$path_lanceur_hide" ] && cp "$path_lanceur_hide" "$path_lanceur"
    echo "TEXT@@LOAD@@_text_lanceur@@$path_lanceur"
}

function btn_gedit_asso()
{
gedit "./${fichier}" &
}

function  btn_save_asso()
{
[ ! -e "$path_asso_hide" ] && cp "$path_asso" "$path_asso_hide"
echo "TEXT@@SAVE@@_text_code@@${fichier}"
}

function btn_rest_asso()
{
[ -e "$path_asso_hide" ] && cp "$path_asso_hide" "$path_asso"
   echo "TEXT@@LOAD@@_text_code@@$path_asso"
}

tree_callback()
{
cmd="$(cut -d '>' -f2 <<< "${@}" | cut -d '<' -f1)"
if [[ "$@" =~ "double_clic" ]]; then
    open_devhelp "$cmd"
else
    echo "CLIP@@SET@@$cmd"
fi
}

tree_cmd()
{
cmd="$(cut -d '>' -f2 <<< "${@}" | cut -d '<' -f1)"
if [[ "$1" =~ "double_clic" ]]; then
open_devhelp "$cmd"
else
    echo "CLIP@@SET@@$cmd"
fi
}

function btn_doc()
{
xdg-open ./doc/${lang}/index.html &
}

_linkbutton1()
{
xdg-open "${@}" &
}

_link_forum()
{
xdg-open "${@}" &
}

_link_doc()
{
xdg-open "${@}" &
}

_link_code()
{
xdg-open "${@}" &
}

_link_tux()
{
xdg-open "${@}" &
}

_link_mail()
{
xdg-open "${@}" &
}

_btn_ouvre_devhelp()
{
open_devhelp glade2script
}

_linkbutton_version()
{
xdg-open "${@}" &
}

open_devhelp()
{
(
devhelp -s "${@}"
) &
}

_btn_install_devhelp()
{
    mkdir -p "${PATH_DEVHELP}"
    rm ${PATH_DEVHELP}/glade2script/*
    cp ./doc/${lang}/* "${PATH_DEVHELP}/glade2script"  && {
    echo 'SET@_label_info.set_markup("<b>Documentation installé</b>")'
    echo 'SET@win_info.show()'
    sleep 2
    echo 'SET@win_info.hide()'
}
}

FindNewVersion()
{
new_version=$(grep "http://glade2script.3.*glade2script." ./version.html | cut -d '"' -f2 | sed 's@.*files/glade2script.\(.*\).tar.gz@\1@' | head -n 1)
}

_btn_check_version()
{
echo 'SET@_progress_version.show()'
wget 'http://code.google.com/p/glade2script/downloads/list' -O- | tee ./version.html | Progress
echo "SET@_progress_version.set_text('Vérification terminée')"
echo "SET@_progress_version.set_fraction(1)"
sleep 2.5
FindNewVersion
echo "SET@_label_result_version.set_markup('<b>Dernière version: "${new_version:-Error}"</b>')"
echo 'SET@_label_result_version.show()'
echo 'SET@_progress_version.hide()'
echo "SET@_linkbutton_version.show()"
rm ./version.html
}

Progress()
{
while read ligne
do
  echo 'SET@_progress_version.pulse()'
done
}

_combo_style() {
echo "TEXT@@SOURCE@@STYLE@@_text_code@@$@"
echo "TEXT@@SOURCE@@STYLE@@_text_lanceur@@$@"
}

_check_line_number() {
echo "SET@_text_code.set_show_line_numbers($@)"
echo "SET@_text_lanceur.set_show_line_numbers($@)"
#echo "TEXT@@LOAD@@_text_code@@${fichier}"
#echo "SET@_text_code.set_property('show-line-marks',$@)"
}
_check_auto_indent() {
echo "SET@_text_code.set_auto_indent($@)"
echo "SET@_text_lanceur.set_auto_indent($@)"
}

PATH_DEVHELP=$HOME/.local/share/devhelp/books
[[ $LANG =~ 'fr' ]] && lang='fr' || lang='en'

echo 'TEXT@@LOAD@@_textview_log@@../changelog.txt'
echo 'TREE@@LOAD@@tree_cmd@@./tree_cmd.txt'
echo 'TREE@@LOAD@@tree_callback@@./tree_callback.txt'
echo "TEXT@@SOURCE@@LANG@@_text_code@@sh"
echo "TEXT@@SOURCE@@LANG@@_text_lanceur@@sh"
echo "MULTI@@SET@@set_insert_spaces_instead_of_tabs(True)@@_text_code,_text_lanceur"
echo "MULTI@@SET@@set_show_right_margin(True)@@_text_code,_text_lanceur"
echo "MULTI@@SET@@set_insert_spaces_instead_of_tabs(True)@@_text_code,_text_lanceur"
echo "MULTI@@SET@@set_indent_width(4)@@_text_code,_text_lanceur"
echo "MULTI@@SET@@set_draw_spaces(GtkSource.DrawSpacesFlags.SPACE)@@_text_code,_text_lanceur"
while read line
  do 
    echo "COMBO@@END@@_combo_style@@$line"
  done < <(echo -e "${G2S_SOURCEVIEW_STYLE//,/\n}")

# Récupe version actuelle.
vd=$(sed -n '\@VERSION="glade2script@s@.*VERSION="glade2script \([^,]*\),.*, \(.*\)"@\1, \2@p' ../glade2script.py)
vd=${vd/\'/}
version=${vd%%,*}
date=${vd#* }
echo "SET@_label_version.set_text('" $version\\n $date"')"
echo $G2S_SOURCEVIEW_STYLE
##########################################################################################
while read ligne; do
    if [[ "$ligne" =~ ^GET@ ]]; then
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
