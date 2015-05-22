#!/bin/bash

if [[ -z $1 ]]; then # Aucune option
        pid=$(ps aux | egrep "\<bash ./extinctor.sh\>|\<python .*extinctor.glade\>" | egrep -v "grep")

        if [[ -z $pid ]]; then # Lance le programme via glade2script
                cd "$( cd "$(dirname $0)"; pwd )"
                ../glade2script.py -g ./ExExtinctor.glade -d

                pid=$(ps aux | egrep "\<bash ./extinctor.sh\>|\<python .*extinctor.glade\>" | egrep -v "grep")

                if [[ $pid ]]; then # Kill les processus restants
                        pid=$(pstree -p $(cut -d " " -f2 <<< $pid)) ; pid=${pid//[!0-9]/$'\n'}

                        kill $pid
                fi
        else # Une instance du programme est déjà lancée
                echo "Extinctor est déjà en cours d'exécution ($(cut -d " " -f2 <<< $pid))"
        fi
else # Évalue l'option
        case $1 in
                -h|--help)
                        echo "Utilisation: extinctor [OPTION]...

Options:
        -h, --help              Montrer ce message et quitter
        -i, --info              Montrer le message d'information et quitter
        -v, --version           Montrer le numéro de version et quitter" ;;
                -i|--info)
                        echo "Pour le bon fonctionnement d'extinctor, $USER doit avoir le droit d'utiliser certaines commandes (halt/reboot et pm-suspend/pm-hibernate si pm-utils est installé).

Pour ce faire, voici la marche à suivre:
        >> Ouvrir un terminal.
        >> Lancer la commande \"visudo\" avec les droits root.
        >> Insérer la ligne suivante: \"$USER ALL= NOPASSWD: /sbin/halt, /sbin/reboot, /usr/sbin/pm-hibernate, /usr/sbin/pm-suspend\" de cette manière :

# User privilege specification
root>---ALL=(ALL) ALL
$USER ALL= NOPASSWD: /sbin/halt, /sbin/reboot, /usr/sbin/pm-hibernate, /usr/sbin/pm-suspend

        >> Enregistrer.
        >> Pour que les modifications prennent effets, redémarrer \"sudo\" avec la commande: \"/etc/init.d/sudo restart\".
Enjoy !" ;;
                -v|--version)
                        echo "Extinctor: 0.2" ;;
                *)
                        echo "Extinctor: option non valide \"$1\""
        esac
fi

exit 0
