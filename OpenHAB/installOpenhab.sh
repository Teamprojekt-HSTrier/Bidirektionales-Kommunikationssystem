#!/bin/bash
#Benötigte Ordner erstllen, Dateien kopieren und Berechtigungen setzen
mkdir /home/pi/OPENHAB
chmod 777 /home/pi/OPENHAB
cp -r openhab2/ /home/pi/OPENHAB/

#Ermitteln der zu schaltenden Lampe in Openhab.
if [ $1 = "SMS" ]
then
OPENHAB_LAMPE="$OPENHAB_LAMPE_SMS"
fi
if [ $1 = "MAIL" ]
then
OPENHAB_LAMPE="$OPENHAB_LAMPE_MAIL"
fi
while [ true ]
do
if [ -z "$OPENHAB_LAMPE" ]
then
echo -e "${farbcode}Bitte schalten sie jetzt die Lampe ein und aus oder geben Sie den Namen der Lampe ein, welche geschaltet werden soll, bestaetigen Sie mit Enter:${neutral}"
read OPENHAB_LAMPE
fi
#Auslesen der zu letzt geschalteten Lampe in Openhab
if [ -z "$OPENHAB_LAMPE" ]
then
zeilen=$(tail -n 2 /var/log/openhab2/events.log | grep ome.event.ItemCommandEvent)
zeilen=$(echo $zeilen| cut -d'-' -f 4)
zeilen=$(echo $zeilen| cut -d' ' -f 2)
zeilen="$(echo -e "${zeilen}" | tr -d '[:space:]')"
zeilen=${zeilen%?}
zeilen=${zeilen:1}

#wenn im Log in den letzen Zeilen nichts gefunden wird, so wird nichts übernommen
if [ -n "$zeilen" ]
then
OPENHAB_LAMPE=$zeilen
fi

else
#Wenn Manuell ein Name eingeben wird, so wird geprüft, ob diese Lampe exisiert.
eingabe=$(cat /var/log/openhab2/events.log | grep $OPENHAB_LAMPE)

if [ -z "$eingabe" ]
then 
echo -e "${farbcode}Es konnte keine Lampe gefunden werden mit diesem Namen trotzdem fortfahren?${neutral}"
echo -e "${farbcode}ja / nein${neutral}"
read Fortfahren

#Wenn die Lampe auch, wenn diese nicht gedunden wurde übernommen werden soll, so wird hier abgebrochen.
if [ $Fortfahren = "ja" ]
then
break
else
continue
fi
fi
fi

#Sollte Automatisch automatisch eine Lampe ermittelt werden, so wird hier die Schleife abgebrochen.
if [ -n "$OPENHAB_LAMPE" ]
then 
break
fi
#Sollte automatisch keine Lampe ermittelt werden können, so wird erneut die Schleife durchlaufen
echo -e "${farbcode}Es konnte keine Lampe ermittelt werden!${neutral}"
done

#in der Openhab config den Namen der Lampe einfügen.
rules="$(sudo cat /etc/openhab2/rules/tts.rules)"
search="sendCommand(,ON)"
replace="sendCommand(${OPENHAB_LAMPE},ON)"

#Bei Auswahl der Installation von Lampe für SMS, wird diese IF Bedingung ausgeführt.
if [ $1 = "SMS" ]
then
#Zwischenspeichern der Lampe
echo $OPENHAB_LAMPE > /home/pi/OPENHAB/OPENHAB_LAMPE_SMS

#Bearbeiten der Benötigten Regeln zum ausschalten der von SMS angeschalteten Lampe.
such="sms"
rules="${rules/$such/$OPENHAB_LAMPE}"
rules="${rules/$such/$OPENHAB_LAMPE}"
echo "$rules" > /home/pi/OPENHAB/tts.rules.tmp
sudo cp /home/pi/OPENHAB/tts.rules.tmp /etc/openhab2/rules/tts.rules

#Erstellen der Benötigten Puffer Datei, zur Kommunikation von OpenHAB und SMS, sowie Berechtigung setzen
echo 2 > /home/pi/OPENHAB/lampesms.txt
chmod 777 /home/pi/OPENHAB/lampesms.txt 

#erstellen und kopieren der OpenHAB Regeln zum einschalten der Lampe, bei änderung der Pufferdatei
rules=$(cat /home/pi/OPENHAB/openhab2/rules/lampesms.rules)
echo "${rules/$search/$replace}" > /home/pi/OPENHAB/openhab2/rules/lampesms.rules.temp
cp lampesms.sh /home/pi/OPENHAB/
chmod 777 /home/pi/OPENHAB/lampesms.sh
sudo cp /home/pi/OPENHAB/openhab2/items/sms.items /etc/openhab2/items/
sudo cp /home/pi/OPENHAB/openhab2/things/sms.things /etc/openhab2/things/
sudo cp /home/pi/OPENHAB/openhab2/rules/lampesms.rules.temp /etc/openhab2/rules/lampesms.rules
rm /home/pi/OPENHAB/openhab2/rules/lampesms.rules.temp
fi

#Bei Auswahl der Installation von Lampe für MAIL, wird diese IF Bedingung ausgeführt.
if [ $1 = "MAIL" ]
then
#Zwischenspeichern der Lampe
echo $OPENHAB_LAMPE > /home/pi/OPENHAB/OPENHAB_LAMPE_MAIL

#Bearbeiten der Benötigten Regeln zum ausschalten der von MAIL angeschalteten Lampe.
such="mail"
rules="${rules/$such/$OPENHAB_LAMPE}"
rules="${rules/$such/$OPENHAB_LAMPE}"
echo "$rules" > /home/pi/OPENHAB/tts.rules.tmp
sudo cp /home/pi/OPENHAB/tts.rules.tmp /etc/openhab2/rules/tts.rules

#Erstellen der Benötigten Puffer Datei, zur Kommunikation von OpenHAB und MAIL, sowie Berechtigung setzen
echo 2 > /home/pi/OPENHAB/lampemail.txt
chmod 777 /home/pi/OPENHAB/lampemail.txt 

#erstellen und kopieren der OpenHAB Regeln zum einschalten der Lampe, bei änderung der Pufferdatei
rules=$(cat /home/pi/OPENHAB/openhab2/rules/lampemail.rules)
echo "${rules/$search/$replace}" > /home/pi/OPENHAB/openhab2/rules/lampemail.rules.temp
cp lampemail.sh /home/pi/OPENHAB/
chmod 777 /home/pi/OPENHAB/lampemail.sh
sudo cp /home/pi/OPENHAB/openhab2/items/mail.items /etc/openhab2/items/
sudo cp /home/pi/OPENHAB/openhab2/things/mail.things /etc/openhab2/things/
sudo cp /home/pi/OPENHAB/openhab2/rules/lampemail.rules.temp /etc/openhab2/rules/lampemail.rules
rm /home/pi/OPENHAB/openhab2/rules/lampemail.rules.temp

#Zu der Mail Empfangsroutine hinzufügen, das eine eingehende Mail die pufferdatei bearbeiten soll.
search="$(tail -1 /home/pi/MESSAGE_PRINTER/printerMDA.sh)"
if [ "$search" != "echo 1 > /home/pi/OPENHAB/lampemail.txt 2> /dev/null" ]
then
text="

echo 1 > /home/pi/OPENHAB/lampemail.txt 2> /dev/null"
echo "$text" >> /home/pi/MESSAGE_PRINTER/printerMDA.sh
fi
fi
