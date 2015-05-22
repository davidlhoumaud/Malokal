echo "### Fonctions de lecture/écriture des préférences ###"

#écriture dans un fichier de configuration
fileconfig_write() { 
    #echo "WRITE $2 IN $1 OF $3"
    touch "$3.tmp"
    cat "$3" | while read line; do
      echo "$line" | grep "$1"
      if [[ "$?" -eq "0" ]]; then
         echo "$1:$2" >> "$3.tmp"
      else
         echo "$line" >> "$3.tmp"
      fi
    done  
    rm -f "$3" 
    mv "$3.tmp" "$3"
}

#Lecture d'un fichier de configuration
fileconfig_read() {
    #echo "READ $1 OF $2"
    cat "$2" | grep "$1" | cut -d":" -f2
}

