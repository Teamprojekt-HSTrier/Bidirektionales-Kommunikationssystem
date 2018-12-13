#!/bin/bash
#Endlosschleife zum versenden von FAXen
while [ true ] ; do

#prüfen ob ein FAX angelegt wurde.
fax=$(cat /home/pi/FAX/fax)

#wenn kein FAX vorhanden is 10s warten
if [ -z "$fax" ]
then
sleep 10

else
#Sollte ein FAX vorhanden sein, so wird die Kontaktdatei ausgelesen und jedem Kontakt ein FAX übermittelt.
counter="$(wc -l /home/pi/STT/KontakteFAX.txt | cut -d' ' -f 1)"
for ((i=1;i<=$counter;++i)); do 
   Telnr="$(head -n $i /home/pi/STT/KontakteFAX.txt | tail -n 1)"
   Telnr="$(echo -e "${Telnr}" | tr -d '[:space:]')"
   sudo sendfax -d $Telnr /home/pi/FAX/fax 
done

#Zu letzt wird die FAX datei gelöscht und dann 10s gewartet.
sudo rm /home/pi/FAX/fax 
sleep 10
fi
done

