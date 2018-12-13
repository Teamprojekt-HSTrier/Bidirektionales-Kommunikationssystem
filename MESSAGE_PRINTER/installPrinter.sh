#!/bin/bash
#installation der benötigten Komponenten für TTS
echo "Starte Installation des Assistenzsystems."
echo "Installiere Abhaengigkeiten, bitte warten..."
sudo apt-get -y install getmail4 

ordner="$(cat /home/pi/MESSAGE_PRINTER/printerMDA.sh)"
if [ -z "$ordner" ]
then
#Dateien kopieren, Ordner Anlegen und Berechtigungen setzen
echo "Kopiere aktuellen Installationsordner ins Homeverzeichnis"
mkdir ~/$(basename $PWD) 
cp -R . ~/$(basename $PWD)
echo "Wechsle zum kopierten Ornder im Homeverzeichnis."
cd ~/$(basename $PWD)
mkdir messagedir
mkdir TTS
chmod 777 TTS
echo "Aendere Berechtigungen zum Ausfuehren der Werkzeugkette."
sudo chmod +x printerMDA.sh 
sudo chmod +x emailHtmlToEmailPngThenPrint.sh
sudo chmod +x printMessageParamRotProc.sh
sudo chmod +x runGetmail.sh

#echo "Fuege Autostart-Eintrag hinzu..."
# Hinweis fuer die Vorgehensweise:
# http://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash/878647#878647
#runGetmail Skript in den Autostart eingebunden
CRONTAB_ENTRY="@reboot /bin/bash /home/pi/MESSAGE_PRINTER/runGetmail.sh > /tmp/log 2>&1"
echo "    Erstelle Backup der Crontab-Datei..."
crontab -l > cronbackup

if ! grep -q "$CRONTAB_ENTRY" "cronbackup"; then
    echo "    Eintrag wird eingefuegt..."
    echo "@reboot /bin/bash /home/pi/MESSAGE_PRINTER/runGetmail.sh > /tmp/log 2>&1" >> cronbackup
   crontab cronbackup
   rm cronbackup
else
    echo "Eintrag bereits vorhanden."
fi
fi

#Einlesen der Zugangsdaten von E-Mail Konto, welches zum Empfangen benutzt wird.
if [ -z $MAIL_ACC ]
then
echo -e "${farbcode}Bitte geben Sie die E-Mail-Adresse ein, von welcher die Nachrichten ausgedruckt werden sollen, bestaetigen Sie mit Enter:${neutral}"

read MAIL_ACC
fi

if [ -z $MAIL_PW ]
then
echo -e "${farbcode}Bitte geben Sie die das Passwort fuer die angegebene E-Mail-Adresse ein, bestaetigen Sie mit Enter:${neutral}"
read MAIL_PW
fi

#Zugangsdaten Zwischenspeichern
echo $MAIL_ACC > /home/pi/MESSAGE_PRINTER/MAIL_ACC
echo $MAIL_PW > /home/pi/MESSAGE_PRINTER/MAIL_PW

#Konfig Datei anpassen 
REGEX_MAIL_ACC="s#.*username.*=.*\$#username = ${MAIL_ACC}#"
sed -i "$REGEX_MAIL_ACC" "${PWD}/getmaildir/getmailrc"

REGEX_MAIL_PW="s#.*password.*=.*\$#password = ${MAIL_PW}#"
sed -i "$REGEX_MAIL_PW" "${PWD}/getmaildir/getmailrc"

echo "Installation des Assistenzsystems erfolgreich abgeschlossen!"
