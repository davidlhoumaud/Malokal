echo "### Initialisation de Malokal ###"

#Si aucune configuration existe on la créée
[[ ! -d "$HOME/.malokal" ]] && mkdir "$HOME/.malokal"
if [[ ! -f "$HOME/.malokal/malokal.cfg" ]]; then
    touch "$HOME/.malokal/malokal.cfg"
    echo "music_dir:$HOME/Musique" >> "$HOME/.malokal/malokal.cfg"
    echo "gui_hide:False" >> "$HOME/.malokal/malokal.cfg"
    echo "gui_fullscreen:False" >> "$HOME/.malokal/malokal.cfg"
    echo "audio_edit:" >> "$HOME/.malokal/malokal.cfg"
    echo "mode:player" >> "$HOME/.malokal/malokal.cfg"
    echo "port:3300" >> "$HOME/.malokal/malokal.cfg"
    echo "port_preview:9900" >> "$HOME/.malokal/malokal.cfg"
    mkdir "$HOME/.malokal/users/"
    mkdir "$HOME/.malokal/library"
    mkdir "$HOME/.malokal/playlists/"
    mkdir "$HOME/.malokal/schedule/"
fi

#Récupération des variable Global
MUSIC_DIR=`./cfgedit -r "music_dir" "$HOME/.malokal/malokal.cfg"`
GUI_HIDE=`./cfgedit -r "gui_hide" "$HOME/.malokal/malokal.cfg"`
GUI_FULLSCREEN=`./cfgedit -r "gui_fullscreen" "$HOME/.malokal/malokal.cfg"`
AUDIO_EDIT=`./cfgedit -r "audio_edit" "$HOME/.malokal/malokal.cfg"`
MALOKAL_MODE=`./cfgedit -r "mode" "$HOME/.malokal/malokal.cfg"`
CURRENT_PORT=`./cfgedit -r "port" "$HOME/.malokal/malokal.cfg"`
CURRENT_PORT_PREVIEW=`./cfgedit -r "port_preview" "$HOME/.malokal/malokal.cfg"`

if [[ "$MALOKAL_MODE" == "schedule" ]]; then
    __mode_schedule
else
    __mode_player
fi

echo "SET@jamendo.set_custom_encoding('UTF-8')
WEBKIT@@CACHE@@jamendo@@/tmp/malokal
WEBKIT@@LOAD@@jamendo@@http://www.jamendo.com/fr/search/discover?qs=q=*:*&by=rating"
