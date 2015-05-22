echo "### Gestion de la liste courante ###"
numline_current=0
sumcurrent=""
oldsumcurrent=""
PLAYERACTIF=0
tw_current() {
    numline_current=$(cut -d '@' -f1 <<< $1)
    echo 'TREE@@FORCESELECT@@tw_current'
    echo 'TREE@@GET@@tw_current'
    sleep 0.1
    echo 'ITER@@__tw_current'
    #if [[ "$@" == "clicked" ]]; then
    #    echo 'TREE@@GET@@tw_current'
    #    sleep 0.1
    #    echo 'ITER@@__tw_current'
    #else
    #    echo "Édition des tags audio"
    #fi
}
__tw_current() {
    echo "SET@_label_info_title.set_markup(\"`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f3`\")
SET@_label_info_album.set_markup(\"`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f4`\")
SET@_label_info_artist.set_markup(\"`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f5`\")
SET@_label_info_genre.set_markup(\"`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f6`\")
SET@_label_info_year.set_markup(\"`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f7`\")
SET@_label_info_comment.set_markup(\"`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f9 | cut -d';' -f5`\")"
    _info_pathfile=`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f9 | cut -d';' -f6`
    _info_pathfile_preview=`echo "$tw_current" | cut -d'@' -f2 | cut -d'|' -f9 | cut -d';' -f6`
    if [[ "$oldsumcurrent" != "" ]]; then
        if [[ `echo -n "$tw_current" | md5sum` != "$oldsumcurrent" ]]; then
            if [[ $PLAYERACTIF -eq 1 ]]; then
                echo "SET@_btn_current_play.clicked()"
                oldsumcurrent=`echo -n "$tw_current" | md5sum`
            fi
        fi
    else
        oldsumcurrent=`echo -n "$tw_current" | md5sum`
    fi
    
}
