��          ,      <       P   �  Q   c  �  �  <                         <big><b>HOW TO TRANSLATE  APP</b></big>

<b>Dependances:</b> xgettext msgfmt msginit

<b>Generate .mo file</b>
<i>xgettext -o Test.pot Test.glade Test.sh
#ou xgettext -o Test.pot *.glade *.sh
msginit -i Test.pot -o Test.po
Translate de .po file then:
msgfmt Test.po -o Test.mo</i>

The .mo file was used for the translation.
It should be in a folder 'locale' in the current directory 
(or use --locale option to change the folder destination).
<i>dirscripts/locale/fr/LC_MESSAGES/Test.mo</i>

<b>In your bash script:</b>
<i>chemin="$(cd "$(dirname "$0")";pwd)"
set -a
source gettext.sh
set +a
export TEXTDOMAIN=Test    #here the name of .mo, .glade, ....
export TEXTDOMAINDIR="${chemin}/locale"
. gettext.sh</i>

Text to translate into the script:
<i>$(eval_gettext "label à traduire")</i>

With a glade2script command:
<i>echo "SET@_label1.set_text('$(eval_gettext "label à traduire")')"</i>
 Project-Id-Version: glade 2script.2
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2011-11-16 13:52+0100
PO-Revision-Date: 2011-11-16 13:52+0100
Last-Translator: yoanne <yoanne@yoanne-desktop>
Language-Team: French
Language: fr
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=2; plural=(n > 1);
     <big><b>COMMENT TRADUIRE UNE APP</b></big>

<b>Dépendances:</b> xgettext msgfmt msginit

<b>Créer le fichier .mo</b>
<i>xgettext -o Test.pot Test.glade Test.sh
#ou xgettext -o Test.pot *.glade *.sh
msginit -i Test.pot -o Test.po
Traduire le fichier .po, ensuite:
msgfmt Test.po -o Test.mo</i>

Le fichier .mo sera utiliser pour la traduction de l'app.
Il doit se trouver dans un dossier 'locale' au coté de g2s 
(ou utiliser l'option --locale pour changer de dossier).
<i>dirscripts/locale/fr/LC_MESSAGES/Test.mo</i>

<b>Dans le script bash:</b>
<i>chemin="$(cd "$(dirname "$0")";pwd)"
set -a
source gettext.sh
set +a
export TEXTDOMAIN=Test    #here the name of .mo, .glade, ....
export TEXTDOMAINDIR="${chemin}/locale"
. gettext.sh</i>

Texte à traduire dans le script bash:
<i>$(eval_gettext "label à traduire")</i>

Avec une commande glade2script:
<i>echo "SET@_label1.set_text('$(eval_gettext "label à traduire")')"</i>
 