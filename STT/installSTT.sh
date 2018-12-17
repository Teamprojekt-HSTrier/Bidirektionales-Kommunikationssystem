#!/bin/bash
#installation der benötigten Komponenten für STT
cat ./files/split-SpeechRecognition.tar.* > ./files/SpeechRecognition.tar 
tar -xf ./files/SpeechRecognition.tar 
sudo apt-get -y install python-pyaudio python3-pyaudio flac
sudo pip install google-api-python-client
sudo pip install ./files/SpeechRecognition-3.8.1-py2.py3-none-any.whl
python -m pip install --upgrade pip setuptools wheel

#Dateien kopieren, Ordner Anlegen und Berechtigungen setzen
mkdir /home/pi/STT
cp ./files/* /home/pi/STT/
sudo chmod 777 /home/pi/STT
sudo chmod 777 /home/pi/STT/aufnahme.sh

#Ermitteln des zum starten der Aufnahme benötigten Openhab Schalters.
while [ true ]
do
if [ -z "$OPENHAB_SCHALTER_STT" ]
then
echo -e "${farbcode}Bitte schalten sie jetzt die den Schalter ein und aus oder geben Sie den Namen des Schalter ein, welcher für die STT Aufnahme verwendet werden soll, bestaetigen Sie mit Enter:${neutral}"
read OPENHAB_SCHALTER_STT
fi

#Auslesen des zu letzt gedrückten Schalters in Openhab
if [ -z "$OPENHAB_SCHALTER_STT" ]
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
OPENHAB_SCHALTER_STT=$zeilen
fi

else
#Wenn Manuell ein Name eingeben wird, so wird geprüft, ob dieser Schalter exisiert.
eingabe=$(cat /var/log/openhab2/events.log | grep $OPENHAB_SCHALTER_STT)
if [ -z "$eingabe" ]
then 
echo -e "${farbcode}Es konnte kein Schalter mit diesem Namen gefunden werden trotzdem fortfahren?${neutral}"
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
if [ -n "$OPENHAB_SCHALTER_STT" ]
then 
break
fi
#Sollte automatisch kein Schalter ermittelt werden können, so wird erneut die Schleife durchlaufen
echo -e "${farbcode}Es konnte kein Schalter ermittelt werden!${neutral}"
done

#Zwischenspeichern des Schalters
echo $OPENHAB_SCHALTER_STT > /home/pi/STT/STT

#in der OpenHAB config den Namen des Schalters einfügen.
such="Schalter"
rules="$(cat /home/pi/STT/stt.rules)"
rules="${rules/$such/$OPENHAB_SCHALTER_STT}"
rules="${rules/$such/$OPENHAB_SCHALTER_STT}"
echo "$rules" > /home/pi/STT/stt.rules.tmp

#die Regeln für das Starten des Skripts an die Richtigen Pfade kopieren.
sudo cp /home/pi/STT/stt.items /etc/openhab2/items/
sudo cp /home/pi/STT/stt.things /etc/openhab2/things/
sudo cp /home/pi/STT/stt.rules.tmp /etc/openhab2/rules/stt.rules

#Beiauswahl der Fax Funktion wird diese If Bedingung durchlaufen
if [ $1 = "FAX" ]
then
#Ziel Fax Nr ermitteln und abspeichern in der KontakteFax Datei
echo -e "${farbcode}Bitte geben sie die Ziel Fax Nr an:${neutral}"
read FAX_NR
cp ./KontakteFAX.txt /home/pi/STT/
fax=$(cat /home/pi/STT/KontakteFAX.txt)
such="fax"
fax="${fax/$such/$FAX_NR}"
echo "$fax" > /home/pi/STT/KontakteFAX.txt
#Für die STT Funktion merken, das Fax installiert wurde
echo FAX > /home/pi/STT/FAX
cd ./../FAX
#Fax installation starten
bash ./installFAX.sh
fi

#Beiauswahl der MAIL Funktion wird diese If Bedingung durchlaufen
if [ $1 = "MAIL" ]
then
#Ziel MAIL Adresse ermitteln und abspeichern in der KontakteMAIL Datei
echo -e "${farbcode}Bitte geben sie die Ziel Mail Adresse an:${neutral}"
read MAIL_NR
cp ./KontakteMAIL.txt /home/pi/STT/
mail=$(cat /home/pi/STT/KontakteMAIL.txt)
such="mail"
mail="${mail/$such/$MAIL_NR}"
echo "$mail" > /home/pi/STT/KontakteMAIL.txt
#Für die STT Funktion merken, das MAIL installiert wurde
echo MAIL > /home/pi/STT/MAIL
cd ./../SENDMAIL
#SendMAIL installation starten
bash ./installMAIL.sh
fi

#Beiauswahl der SMS Funktion wird diese If Bedingung durchlaufen
if [ $1 = "SMS" ]
then
#Ziel SMS Nr ermitteln und abspeichern in der KontakteSMS Datei
echo -e "${farbcode}Bitte geben sie die Ziel Telefonnummer an:${neutral}"
read SMS_NR
cp ./KontakteSMS.txt /home/pi/STT/
sms=$(cat /home/pi/STT/KontakteSMS.txt)
such="sms"
sms="${sms/$such/$SMS_NR}"
echo "$sms" > /home/pi/STT/KontakteSMS.txt
#Für die STT Funktion merken, das SMS installiert wurde
echo SMS > /home/pi/STT/SMS
cd ./../SMS
#SMS installation starten
bash ./installSMS.sh
fi


