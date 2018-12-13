#!/bin/bash
echo -e "${farbcode}Starte Installation der SMS Systeme.${neutral}"

#Alle benötigten Komponenten, welche für den SMS versand / empfang benötigt werden, werden installiert und geupdatet.
sudo apt-get update
sudo apt-get -y install usb-modeswitch usb-modeswitch-data gammu python-gammu gammu-smsd build-essential

#dem User Pi werden Dialout berechtigungen zugewiesen.
sudo adduser pi dialout

#Dateien kopieren, Ordner Anlegen
mkdir /home/pi/SMS
mkdir /home/pi/SMS/messagedir
mkdir /home/pi/SMS/TTS
mkdir /home/pi/SMS/UMTSStick
cp ./files/* /home/pi/SMS
mv /home/pi/SMS/reconnect /home/pi/SMS/UMTSStick/usbreset.c
cd /home/pi/SMS/UMTSStick

#Entpacken der Software für den USB Reset
cc usbreset.c -o usbreset 
cd ..

#Einlesen der PIN
if [ -z $SMS_PIN ]
then
echo -e "${farbcode}Bitte geben Sie die PIN der SIM-Karte ein, bestaetigen Sie mit Enter: ${neutral}"
read SMS_PIN
echo $SMS_PIN > /home/pi/SMS/SMS_PIN
fi

#echo "Fuege Autostart-Eintrag hinzu..."
# Hinweis fuer die Vorgehensweise:
# http://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash/878647#878647
#Reconnect Sktipt in den Autostart eingebunden.
CRONTAB_ENTRY="@reboot /bin/bash /home/pi/SMS/reconnect.sh > /tmp/log 2>&1"
echo "    Erstelle Backup der Crontab-Datei..."
crontab -l > cronbackup

if ! grep -q "$CRONTAB_ENTRY" "cronbackup"; then
    echo "    Eintrag wird eingefuegt..."
    echo "@reboot /bin/bash /home/pi/SMS/reconnect.sh > /tmp/log 2>&1" >> cronbackup
   crontab cronbackup
   rm cronbackup
else
    echo "Eintrag bereits vorhanden."
fi

#Versenden von SMS in den Autostart eingebunden
CRONTAB_ENTRY="@reboot /bin/bash /home/pi/SMS/CRONsendSMS.sh > /tmp/log 2>&1"
echo "    Erstelle Backup der Crontab-Datei..."
crontab -l > cronbackup

if ! grep -q "$CRONTAB_ENTRY" "cronbackup"; then
    echo "    Eintrag wird eingefuegt..."
    echo "@reboot /bin/bash /home/pi/SMS/CRONsendSMS.sh > /tmp/log 2>&1" >> cronbackup
   crontab cronbackup
   rm cronbackup
else
    echo "Eintrag bereits vorhanden."
fi

#Konfig dateien für den SMS versand angepasst und erstellt
body=$(cat gammu-smsdrc)
such="pin = "
sudo echo "${body/$such/$such$SMS_PIN}" > gammu-smsdrc_temp
sudo cp gammu-smsdrc_temp /etc/gammu-smsdrc
sudo cp gammurc /etc/
sudo rm gammu-smsdrc_temp

#Benötigte Berechtigungen werden gesetzt 
sudo chmod -R 774 /var/spool/gammu/inbox
sudo chmod -R 777 /home/pi/SMS	
echo -e "${farbcode}Installation erfolgreich!${neutral}"