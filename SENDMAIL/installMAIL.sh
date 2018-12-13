#!/bin/bash
#installation der benötigten Komponenten für SENDMAIL
sudo apt-get -y update
sudo apt-get -y install ssmtp mailutils

#Einlesen der Zugangsdaten von E-Mail Konto, welches zum Senden benutzt wird.
if [ -z $MAIL_ACC ]
then
echo -e "${farbcode}Bitte geben Sie die E-Mail-Adresse des Senders ein, bestaetigen Sie mit Enter:${neutral}"
read MAIL_ACC
fi
if [ -z $MAIL_PW ]
then
echo -e "${farbcode}Bitte geben Sie die das Passwort fuer die angegebene Adresse ein, bestaetigen Sie mit Enter:${neutral}"
read MAIL_PW
fi

#Ordner Anlegen und Berechtigungen setzen
mkdir /home/pi/SENDMAIL
chmod 777  /home/pi/SENDMAIL

#Zugangsdaten Zwischenspeichern
echo $MAIL_ACC > /home/pi/SENDMAIL/MAIL_ACC
echo $MAIL_PW > /home/pi/SENDMAIL/MAIL_PW

#Auswahl zur Installation der gewählten Mail Version
echo -e "${farbcode}Bitte geben sie die passende Zahl für Ihre Auswahl an:"
echo "1 Nachrichteninhalt als Text"
echo "2 Nachrichteninhalt als Audiodatei"
echo -e "3 Nachrichteninhalt als Text und Audiodatei${neutral}"
read MAIL_WAV

#sollte keine / bzw. die Falsche Auswahl getroffen worden sein, so wird 1 als Standard gesetzt werden.
if [ "1" = "$MAIL_WAV" ]
then
MAIL_WAV="1"
else
if [ "2" = "$MAIL_WAV" ]
then
MAIL_WAV="2"
else
if [ "3" = "$MAIL_WAV" ]
then
MAIL_WAV="3"
else
MAIL_WAV="1"
fi
fi
fi
#Abspeichern der Auswahl und Berechtigung setzten
echo "$MAIL_WAV" > /home/pi/SENDMAIL/TXTWAV
chmod 777  /home/pi/SENDMAIL/TXTWAV

#Dateien kopieren 
cp ./ssmtp.conf /home/pi/SENDMAIL/
cp ./revaliases /home/pi/SENDMAIL/
cd /home/pi/SENDMAIL

#Konfig Datei 1 anpassen und an die Richtige Position kopiern
user="AuthUser="
pass="AuthPass="
root="root="
rev=$(cat /home/pi/SENDMAIL/revaliases)
smtp=":smtp.gmail.com:587"
eingabe="${MAIL_ACC}${smtp}"
echo "${rev}${eingabe}" > /home/pi/SENDMAIL/revaliases.tmp
sudo cp /home/pi/SENDMAIL/revaliases.tmp /etc/ssmtp/revaliases
rm /home/pi/SENDMAIL/revaliases.tmp

#Konfig Datei 2 anpassen und an die Richtige Position kopiern
conf=$(cat /home/pi/SENDMAIL/ssmtp.conf)
conf="${conf/$root/$root$MAIL_ACC}"
conf="${conf/$user/$user$MAIL_ACC}"
conf="${conf/$pass/$pass$MAIL_PW}"
echo "$conf" > /home/pi/SENDMAIL/ssmtp.conf.tmp
sudo cp /home/pi/SENDMAIL/ssmtp.conf.tmp /etc/ssmtp/ssmtp.conf
rm /home/pi/SENDMAIL/ssmtp.conf.tmp

