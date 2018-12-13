#!/bin/bash
#Bei aufruf des Skript mit Start wird diese IF Abfrage ausgeführt
if [ $1 = "START" ]
then
#Aufnahme starten
arecord -D hw:1 -f dat -c 1 /home/pi/STT/aufnahme.wav

#Python Skript aufrufen, welches die aufnahme zu google Übermittelt und die Antwort in einer txt Speichert
python /home/pi/STT/python.py 

#auslesen der vom Python Skript erstellten txt Datei
nachricht="$(cat /home/pi/STT/stt.txt)"

#prüfen welche Funktion zuvor instlliert wurde
sms="$(cat /home/pi/STT/SMS)"
mail="$(cat /home/pi/STT/MAIL)"
fax="$(cat /home/pi/STT/FAX)"


#sollte Mail installiert worden sein, so wird diese Bedingung ausgeführt
if [ -n "$mail" ]
then
#mail
TXTWAV="$(cat /home/pi/SENDMAIL/TXTWAV)"
pfad="/home/pi/STT/aufnahme.wav"
#Es wird jedem Kontakt in der KontakteMAIL Datei eine Mail geschickt mit den bei der Installation ausgewählten Funktion
counter="$(wc -l /home/pi/STT/KontakteMAIL.txt | cut -d' ' -f 1)"
for ((i=1;i<=$counter;++i)); do 
   Empfaenger="$(head -n $i /home/pi/STT/KontakteMAIL.txt | tail -n 1)"
   Empfaenger="$(echo -e "${Empfaenger}" | tr -d '[:space:]')"
   Betreff="Neue Sprachnachricht"
   #MAIL nur mit Text
   if [ "1" = "$TXTWAV" ]
   then
      echo "$nachricht" | mail -s "$Betreff" $Empfaenger 
   fi
   #Mail mit Aufnahme
   if [ "2" = "$TXTWAV" ]
   then
      nachricht="Guten Tag, die Entsprechende Nachricht befindet sich im Anhang"
      echo "$nachricht" | mail -s "$Betreff" $Empfaenger -A $pfad
   fi
   #Mail mit Text und Aufnahme
   if [ "3" = "$TXTWAV" ]
   then
      echo "$nachricht" | mail -s "$Betreff" $Empfaenger -A $pfad
   fi
done
fi

#sollte SMS installiert worden sein, so wird diese Bedingung ausgeführt
if [ -n "$sms" ]
then
#sms
#Es wird eine Datei erstellt mit den Nachrichten Inhalt, welche von einem Cronjob verschickt wird
echo "$nachricht" > /home/pi/SMS/sendsms
fi

#sollte FAX installiert worden sein, so wird diese Bedingung ausgeführt
if [ -n "$fax" ]
then
#Es wird eine Datei erstellt mit den Nachrichten Inhalt, welche von einem Cronjob verschickt wird
echo "$nachricht" > /home/pi/FAX/fax
fi

else
#Bei aufruf des Skript mit STOP wird die Aufnahme gestoppt
pid=$(ps -A | grep arecord | tr -d '[:space:]' | cut -d'?' -f 1)
kill $pid
fi
