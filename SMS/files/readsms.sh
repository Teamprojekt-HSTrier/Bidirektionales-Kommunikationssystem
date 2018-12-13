#!/bin/bash
#Berechtigungen setzen
chmod -R 774 /var/spool/gammu/inbox/
chmod -R 777 /home/pi/SMS/

#für Jede SMS die in der inbox liegt wird diese Schleife wiederholt
/bin/ls -tr /var/spool/gammu/inbox/ | while read line
do 
#Ermitteln des Datums und der Uhrzeit der Empfangen SMS
time=$(echo $line| cut -d'_' -f 2)
date=$(echo $line| cut -d'_' -f 1)
hours=${time:0:2}
min=${time:2:2}
sec=${time:4:2}
day=${date:8}
month=${date:6:2}
year=${date:2:4}
nr=$(echo $line| cut -d'_' -f 4)
date="$day.$month.$year" 
time="$hours:$min:$sec" 

#Einlesen der Formatierungsvorlage
body=$(cat /home/pi/SMS/body.html) 
head=$(cat /home/pi/SMS/head.html) 
#Erstellen der Variable mit angepassten Kopf inhalt
headdata="
<body id='customBody'> 
<div id='customDiv'>
<h1 id='customH1'>Tel Nr. $nr </h1> 
<h1 id='customH1'>Datum: $date $time </h1>
</div>"

#Einlesen der Nachricht
smstext=$(cat /var/spool/gammu/inbox/$line)

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

#Wenn kein Name ermittelt wurde, wird nur die Tel. Nr. ausgegeben, ansonsten wird Name und Tel. Nr ausgegeben
if [ -z "$name" ]
then
name=$nr
else
name="$name $nr"
fi

#Erstellen der Variable mit angepassten Body inhalt
bodydata="
<div id='customDiv'>
<h1 class='customH1'>Absender: $name </h1>
<p id='customP'>$smstext
</p>
</div>"

#einfügen der Kopf und Body Daten in die vordefinierten, eingelesen Dateien und abspeichern von diesen 
such="<body id='customBody'>"
echo "${head/$such/$headdata}" > /home/pi/SMS/messagedir/head.html
echo "${body/$such/$bodydata}" > /home/pi/SMS/messagedir/body.html

#erneutes anpassen der Berechtigungen, der jetzt neu erstellten Dateien
chmod -R 777 /home/pi/SMS/

#ausdrucken der SMS durch aufruf des smsToEmailPngThenPrint Skripts
echo "SMS wird gedruckt"
sudo -u pi bash /home/pi/SMS/smsToEmailPngThenPrint.sh /home/pi/SMS/messagedir/head.html /home/pi/SMS/messagedir/head.png /home/pi/SMS/messagedir/body.html /home/pi/SMS/messagedir/body.png > /home/pi/SMS/sms.log
done

#Löschen der Empfangen E-Mails falls TTS nicht installiert ist, sonst in den Ordner verschieben, welcher für TTS benutzt wird
smsread=$(cat /home/pi/TTS/SMS 2> /dev/null)
if [ -z "$smsread" ]
then
rm /var/spool/gammu/inbox/*
else
mv /var/spool/gammu/inbox/* /home/pi/SMS/TTS/
fi

#Puffer welcher zum schalten der OpenHAB Lampe benötigt wird aktualisieren
echo 1 > /home/pi/OPENHAB/lampesms.txt

