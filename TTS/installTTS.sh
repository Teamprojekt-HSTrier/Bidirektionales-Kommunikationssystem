#!/bin/bash
#Dateien kopieren, Ordner Anlegen und Berechtigungen setzen
mkdir /home/pi/TTS
mkdir /home/pi/TTS/TTSwav
cp ./files/* /home/pi/TTS
chmod 777 /home/pi/TTS/TTSwav
chmod 777 /home/pi/TTS/tts.sh
chmod 777 /home/pi/TTS

#installation der benötigten Komponenten für TTS
sudo apt-get -y install libpopt-dev
sudo dpkg --install /home/pi/TTS/pico2wave.deb

#Ermitteln des zum starten der Vorlesefunktion benötigten Openhab Schalters.
while [ true ]
do
if [ -z "$OPENHAB_TTS" ]
then
echo -e "${farbcode}Bitte schalten sie jetzt die den Schalter ein und aus oder geben Sie den Namen des Schalter ein, welcher für die TTS Ausgabe verwendet werden soll, bestaetigen Sie mit Enter:${neutral}"
read OPENHAB_TTS
fi
#Auslesen des zu letzt gedrückten Schalters in Openhab
if [ -z "$OPENHAB_TTS" ]
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
OPENHAB_TTS=$zeilen
fi

else
#Wenn Manuell ein Name eingeben wird, so wird geprüft, ob dieser Schalter exisiert.
eingabe=$(cat /var/log/openhab2/events.log | grep $OPENHAB_TTS)
if [ -z "$eingabe" ]
then 
echo -e "${farbcode}Es konnte keine Lampe gefunden werden mit diesem Namen, trotzdem fortfahren?${neutral}"
echo -e "${farbcode}ja / nein${neutral}"
read Fortfahren

#Wenn der Schalter auch, wenn er nicht gedunden wurde übernommen werden soll, so wird hier abgebrochen.
if [ $Fortfahren = "ja" ]
then
break
else
continue
fi
fi
fi

#Sollte Automatisch automatisch ein Schalter ermittelt werden, so wird hier die Schleife abgebrochen.
if [ -n "$OPENHAB_TTS" ]
then 
break
fi
#Sollte automatisch kein Schalter ermittelt werden können, so wird erneut die Schleife durchlaufen
echo -e "${farbcode}Es konnte keine Lampe ermittelt werden.${neutral}"
done

#Zwischenspeichern des Schalters
echo $OPENHAB_TTS > /home/pi/TTS/TTS

#in der OpenHAB config den Namen des Schalters einfügen.
such="Schalter"
rules="$(cat /home/pi/TTS/tts.rules)"
rules="${rules/$such/$OPENHAB_TTS}"
rules="${rules/$such/$OPENHAB_TTS}"
rules="${rules/$such/$OPENHAB_TTS}"
rules="${rules/$such/$OPENHAB_TTS}"
rules="${rules/$such/$OPENHAB_TTS}"
rules="${rules/$such/$OPENHAB_TTS}"
echo "$rules" > /home/pi/TTS/tts.rules.tmp

#die Regeln für das Starten des Skripts an die Richtigen Pfade kopieren.
sudo cp /home/pi/TTS/tts.rules.tmp /etc/openhab2/rules/tts.rules
sudo cp /home/pi/TTS/tts.items /etc/openhab2/items/
sudo cp /home/pi/TTS/tts.things /etc/openhab2/things/

#Auswahl des Zu Startenden Skripts, anhand des Mitgelieferten Parameters
if [ $1 = "SMS" ]
then
#Speichern der Info, das SMS installiert wurde, benötigt für TTS
echo SMS > /home/pi/TTS/SMS
cd ./../SMS
bash ./installSMS.sh
fi

if [ $1 = "MAIL" ]
then
#Speichern der Info, das MAIL installiert wurde, benötigt für TTS
echo MAIL > /home/pi/TTS/MAIL
cd ./../MESSAGE_PRINTER
bash ./installPrinter.sh

#erweiterte automatisches Druckskript um TTS Funktion
search="$(tail -1 /home/pi/MESSAGE_PRINTER/printerMDA.sh)"
text="

echo 1 > /home/pi/OPENHAB/lampemail.txt 2> /dev/null"

#Sollte die Lampen Funktion schon installiert sein, so wird diese Zeile wieder ans ende geschrieben.
if [ "$search" != "echo 1 > /home/pi/OPENHAB/lampemail.txt 2> /dev/null" ]
then
cp /home/pi/TTS/printerMDA.sh /home/pi/MESSAGE_PRINTER/printerMDA.sh
else
cp /home/pi/TTS/printerMDA.sh /home/pi/MESSAGE_PRINTER/printerMDA.sh
echo "$text" >> /home/pi/MESSAGE_PRINTER/printerMDA.sh
fi

fi




