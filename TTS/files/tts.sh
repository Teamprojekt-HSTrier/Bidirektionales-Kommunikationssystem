#!/bin/bash
#Bei aufruf des Skript mit Start wird diese IF Abfrage ausgeführt
if [ $1 = "START" ]
then
smsread=$(cat /home/pi/TTS/SMS 2> /dev/null)
mailread=$(cat /home/pi/TTS/MAIL 2> /dev/null)

#SMS Vorlesen
if [ -n "$smsread" ]
then
#für jede Datei Vorlesen wiederholen
ls -tr /home/pi/SMS/TTS | while read sms
do
#Datum und Uhrzeit auslesen
time=$(echo $sms| cut -d'_' -f 2)
hours=${time:0:2}
min=${time:2:2}
sec=${time:4:2}
time="$hours:$min" 

#Tel. Nr auslesen
nr=$(echo $sms| cut -d'_' -f 4)

#Nachricht ermitteln
smstext=$(cat /home/pi/SMS/TTS/$sms)

#mithilfe der Nr wird versucht ein Name zu ermitteln, mithilfe einer Kontakte Datei
name=""
while read kontakt
do
nr="$(echo -e "${nr}" | tr -d '[:space:]')"
kontaktnr=$(echo $kontakt| cut -d';' -f 2)
kontaktnr="$(echo -e "${kontaktnr}" | tr -d '[:space:]')"
if [ $nr = $kontaktnr ]
then
name=$(echo $kontakt| cut -d';' -f 1)
fi
done < /home/pi/SMS/Kontakte.txt

#Wenn kein Name ermittelt wurde, wird nur die Tel. Nr. ausgegeben, ansonsten wird der Name ausgegeben
if [ -z "$name" ]
then
name=$nr
fi

stop=$(cat /home/pi/TTS/STOP)
if [ -z "$stop" ]
then
#Text Datei in Wav Datei konverieren und abspielen
pico2wave --lang=de-DE --wave=/home/pi/TTS/TTSwav/nachricht.wav "Neue Nachricht von $name empfangen um $time .. $smstext"
aplay /home/pi/TTS/TTSwav/nachricht.wav
stop=$(cat /home/pi/TTS/STOP)

#Falls die wiedergabe abgebrochen wurde, wird das löschen der Datei übersprungen.
if [ -z "$stop" ]
then
rm /home/pi/SMS/TTS/$sms
fi
fi
done
fi



#Mails vorlesen
if [ -n "$mailread" ]
then
#für jede Datei Vorlesen wiederholen
ls -tr /home/pi/MESSAGE_PRINTER/TTS | while read mail
do
#Datum und Uhrzeit auslesen
time=$(echo $mail| cut -d'_' -f 2)
hours=${time:0:2}
min=${time:2:2}
sec=${time:4:2}
time="$hours:$min" 

#E-Mail ermitteln
name=$(echo $mail| cut -d'_' -f 4)

#Nachricht ermitteln
mailtext=$(cat /home/pi/MESSAGE_PRINTER/TTS/$mail)
stop=$(cat /home/pi/TTS/STOP)
if [ -z "$stop" ]
then
#Text Datei in Wav Datei konverieren und abspielen
pico2wave --lang=de-DE --wave=/home/pi/TTS/TTSwav/nachricht.wav "Neue Nachricht von $name empfangen um $time .. $mailtext"
aplay /home/pi/TTS/TTSwav/nachricht.wav
stop=$(cat /home/pi/TTS/STOP)
#Falls die wiedergabe abgebrochen wurde, wird das löschen der Datei übersprungen.
if [ -z "$stop" ]
then
rm /home/pi/MESSAGE_PRINTER/TTS/$mail
fi
fi
done
rm /home/pi/TTS/STOP
fi

else
#Bei aufruf des Skript mit STOP wird das Abspielen der wav Datei gestoppt
pid=$(ps -A | grep aplay | tr -d '[:space:]' | cut -d'?' -f 1)
if [ -n "$pid" ]
then
kill $pid
#damit nicht nur eine Datei, beim abspielen gestoppt wird, 
#wird eine puffer Datei angelegt, welche vor abspielen überprüft wird
echo "stop" > /home/pi/TTS/STOP
fi
fi
echo "Ende"