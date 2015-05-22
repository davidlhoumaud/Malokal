echo "### Gestion de la bibliothèque ###"

tw_library() {
    if [[ "$@" == "clicked" ]]; then
        echo 'TREE@@GET@@tw_library'
        sleep 0.1
        echo 'ITER@@__tw_library'
    else
        echo "### Édition des tags audio"
    fi
}
__tw_library() {
    echo "SET@_label_info_title.set_markup(\"`echo "$tw_library" | cut -d'@' -f2 | cut -d'|' -f3`\")
SET@_label_info_album.set_markup(\"`echo "$tw_library" | cut -d'@' -f2 | cut -d'|' -f4`\")
SET@_label_info_artist.set_markup(\"`echo "$tw_library" | cut -d'@' -f2 | cut -d'|' -f5`\")
SET@_label_info_genre.set_markup(\"`echo "$tw_library" | cut -d'@' -f2 | cut -d'|' -f6`\")
SET@_label_info_year.set_markup(\"`echo "$tw_library" | cut -d'@' -f2 | cut -d'|' -f7`\")
SET@_label_info_comment.set_markup(\"`echo "$tw_library" | cut -d'@' -f2 | cut -d'|' -f9 | cut -d';' -f5`\")"
    _info_pathfile_preview=`echo "$tw_library" | cut -d'@' -f2 | cut -d'|' -f9 | cut -d';' -f6`
}
