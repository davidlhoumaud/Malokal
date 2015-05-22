#!/bin/bash
pid=$$
fifo=/tmp/FIFO$pid
mkfifo $fifo
####################################################

## Définition des variables
time=40

## Définition des fonctions

window1(){ # Quitte le logiciel
        [[ $pid_info ]] && kill $pid_info
        [[ $(pstree $pid_info_user) ]] && kill $pid_info_user

        echo "EXIT@@"
}

halt(){ # Éteint l'ordinateur
        sudo halt &

        window1
}

reboot(){ # Redémarre l'ordinateur
        sudo reboot &

        window1
}

_suspend(){ # Met en veille l'ordinateur
        sudo pm-suspend &

        window1
}

_hibernate(){ # Met en hibernation l'ordinateur
        sudo pm-hibernate &

        window1
}

info(){ # Lance un compte à rebours avant l'extinction
        while [[ $time != 0 ]]; do
                echo "SET@_info.set_markup('<i>Vous êtes actuellement connecté en tant que <b>$USER</b>.\nCet ordinateur va s\'éteindre automatiquement dans \n<b>$time</b> $(awk '{if (($1 != "1")) {print "secondes"} else {print "seconde"}}' <<< $time).</i>')"

                sleep 1

                time=$(($time -1))
        done

        echo "SET@_info.set_markup('<i>L\'ordinateur va s\'éteindre dans un instant...</i>')"

        sleep 1.5
        unset $pid_info

        halt
}

user_info(){ # Affiche le message d'information
        x-terminal-emulator -e bash -c "./go_ExExtinctor.sh --info ; bash" &
        pid_info_user=$!
}

## Début du script

# Vérifie si pm-utils est installé
[[ -x /usr/sbin/pm-suspend ]] && echo "MULTI@@SET@@show()@@_suspend,_hibernate"

# Lancement du compte à rebours
info &
pid_info=$!

####################################################
while read ligne; do
        if [[ "$ligne" =~ GET@ ]]; then
                eval ${ligne#*@}
                echo "DEBUG => in boucle bash :" ${ligne#*@}
        else
                echo "DEBUG => in bash NOT GET" $ligne
                $ligne
        fi
done < <(while true; do
read entree < $fifo
[[ "$entree" == "QuitNow" ]] && break
echo $entree
done)

exit 0
