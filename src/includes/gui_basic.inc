echo "### Fonctions standard de l'interface ###"

_globaldatetime() {
    while [[ -f $HOME/.malokal/globaldatetime ]]; do
      echo "SET@_label_hours.set_markup(\"<span color='blue' size='large'>`date "+%a %d %b"`</span>\n<span color='blue' size='xx-large'>`date "+%H:%M:%S"`</span>\")"
    done
}
