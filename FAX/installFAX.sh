#!/bin/bash

#Alle benötigten Komponenten, welche für den FAX versand benötigt werden installiert
sudo apt-get -y install hylafax-server gammu
sudo faxadduser -p raspberry -u 1002 root

#Ermitteln der Modem Schnittstellt, indem alle Seriellen Schnittstellen ausgelesen werden und nach Modem gefiltert wird.
while read line ; do
modem=$(echo $line | grep Modem)
if [ -z "$modem" ]
then
temp=$line 
else
break
fi
done < <(gammu-detect)

#Auslesen der eigentlichen Schnittstelle
seriell=$(echo $temp| cut -d'/' -f 3)

#Benötigte Ordner werden erstellt und berechtigungen zugewiesen
mkdir /home/pi/FAX
sudo chmod 777 /home/pi/FAX
sudo cp ./files/* /home/pi/FAX/
#sudo chmod 777 /home/pi/FAX/sendFAX.sh

#echo "Fuege Autostart-Eintrag hinzu..."
# Hinweis fuer die Vorgehensweise:
# http://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash/878647#878647
#Versenden von FAX in den Autostart eingebunden
CRONTAB_ENTRY="@reboot /bin/bash /home/pi/FAX/CRONsendFAX.sh > /tmp/log 2>&1"
echo "    Erstelle Backup der Crontab-Datei..."
crontab -l > cronbackup
if ! grep -q "$CRONTAB_ENTRY" "cronbackup"; then
    echo "    Eintrag wird eingefuegt..."
    echo "@reboot /bin/bash /home/pi/FAX/CRONsendFAX.sh > /tmp/log 2>&1" >> cronbackup
   crontab cronbackup
   rm cronbackup
else
    echo "Eintrag bereits vorhanden."
fi

#Einlesen der eigenen FAX Nummer
if [ -z $TEL_NR ]
then
echo -e "${farbcode}Bitte geben Sie die Telefonnummer der Fax Leitung ein, bestaetigen Sie mit Enter: "
echo -e "Beispiel: +4965000000000${neutral}"
read TEL_NR
echo $TEL_NR > /home/pi/FAX/TEL_NR
fi

#Konfig Datei anpassen und an die benötigte Stelle kopieren
countryCode=${TEL_NR:1:2}
areaCode=${TEL_NR:3:4}
cd /home/pi/FAX
body=$(cat config.ttyACM0)
such1="CountryCode:		"
such2="AreaCode:		"
such3="FAXNumber:		"
such4="LongDistancePrefix:	"
body="${body/$such1/$such1$countryCode}"
body="${body/$such2/${such2}0$areaCode}"
body="${body/$such3/$such3$TEL_NR}"
body="${body/$such4/$such4$countryCode}"
echo "$body" > /home/pi/FAX/config.$seriell.temp
sudo cp /home/pi/FAX/config.$seriell.temp /etc/hylafax/config.$seriell
rm /home/pi/FAX/config.$seriell.temp
