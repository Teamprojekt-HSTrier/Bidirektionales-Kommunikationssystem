#!/bin/bash
#Endlosschleife zum versenden von SMS
while [ true ] ; do

#prüfen ob eine SMS angelegt wurde.
sms=$(cat /home/pi/SMS/sendsms)

#wenn keine SMS vorhanden is 10s warten
if [ -z "$sms" ]
then
sleep 10

else
#Sollte eine SMS vorhanden sein, so wird die Kontaktdatei ausgelesen und jedem Kontakt eine SMS übermittelt.
counter="$(wc -l /home/pi/STT/KontakteSMS.txt | cut -d' ' -f 1)"
for ((i=1;i<=$counter;++i)); do 
   SMSnr="$(head -n $i /home/pi/STT/KontakteSMS.txt | tail -n 1)"
   SMSnr="$(echo -e "${SMSnr}" | tr -d '[:space:]')"
   sudo gammu-smsd-inject TEXT $SMSnr -text "$sms"
done

#Zu letzt wird die SMS datei gelöscht und dann 10s gewartet.
sudo rm /home/pi/SMS/sendsms 
sleep 10
fi
done

