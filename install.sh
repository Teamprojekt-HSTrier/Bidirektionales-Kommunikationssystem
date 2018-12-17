#!/bin/bash
sudo chmod 777 -R .
export farbcode="\033[32m"
export neutral="\033[0m"
while [ true ]
do
#Test auf Google DNS Server, ob Netzwerkverbindung vorhanden
if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
  echo "Netzwerkverbindung vorhanden"
  network=1
  break;
else
  echo -e "${farbcode}Netzwerkverbindung fehlt"
  echo "Bitte Netzwerk prüfen"
  network=2
  sleep 10
fi
done

#Wenn Netzwerk vorhanden
if [ $network = 1 ]
then 
echo -e "${farbcode}Willkommen zur Installation!"
echo -e "Ihr System wird nun vorbereitet...${neutral}"
sleep 5

#prüfen ob der Port 8080 schon benutzt wird. 
#Wenn nein, Openhab wird installiert.
#wenn ja nur Software updates werden durchgeführt. 
openhabinstall="$(netstat -an |grep LISTEN | grep 8080)"
if [ -z "$openhabinstall" ]
then
#lade openhab2 herunter
wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' | sudo apt-key add -
sudo apt-get -y install apt-transport-https
echo 'deb https://dl.bintray.com/openhab/apt-repo2 stable main' | sudo tee /etc/apt/sources.list.d/openhab2.list

#Systemupdate
sudo apt-get -y autoclean
sudo apt-get -y autoremove
sudo apt-get -y update
sudo apt-get -y upgrade

#openHAB installieren 
sudo apt-get -y install openhab2
#Autostart für openHAB erstellen
sudo systemctl daemon-reload
sudo systemctl enable openhab2.service

#Berechtigungen für openHAB hinzufügen
sudo adduser openhab dialout
sudo adduser openhab tty
sudo adduser openhab audio

#Openhab wird gestartet und addons werden anschließend installiert.
sudo /bin/systemctl start openhab2.service
sudo apt-get -y install openhab2-addons
else
sudo apt-get -y autoclean
sudo apt-get -y autoremove
sudo apt-get -y update
sudo apt-get -y upgrade
fi

#Starte Instalationsauswahl in der Konsole
while [ true ]
do

echo -e "${farbcode}Sie können zwischen folgenden Systemkomponenten auswählen. Bitte geben sie die entsprechende Zahl ein und bestätigen Sie mit Enter: "
echo "Nach der Installation einer Komponente erscheint diese Ansicht erneut"
echo ""
echo "Nachrichtenempfang: "
echo "1. E-Mail mit Ausdruck auf Thermodrucker (online)"
echo "2. SMS mit Ausdruck auf Thermodrucker (offline)"
echo "3. E-Mail mit Sprachausgabe (online)" 
echo "4. SMS mit Sprachausgabe (offline)"
echo ""
echo "Nachrichtenversand"
echo "5. Fax per Spracheingabe (online)"
echo "6. E-Mail per Spracheingabe (online)"
echo "7. SMS per Spracheingabe (online)"
echo ""
echo "optionale Einrichtung einer Lampe"
echo "8. Lampe einrichten, welche auf SMS reagiert"
echo "9. Lampe einrichten, welche auf E-Mail reagiert"
echo -e "10. Beenden${neutral}"


#Abhängig von der Auswahl wird das entsprechende Skript ausgeführt
read Auswahl

case $Auswahl in
1)
cd THERMODRUCKER
bash ./installThermodrucker.sh MAIL
cd ..
;;

2)
cd THERMODRUCKER
bash ./installThermodrucker.sh SMS
cd ..
;;

3)
cd TTS
bash ./installTTS.sh MAIL
cd ..
;;

4)
cd TTS
bash ./installTTS.sh SMS
cd ..
;;

5)
cd STT
bash ./installSTT.sh FAX
cd ..
;;

6)
cd STT
bash ./installSTT.sh MAIL
cd ..
;;

7)
cd STT
bash ./installSTT.sh SMS
cd ..
;;

8)
cd OpenHAB
bash ./installOpenhab.sh SMS
cd ..
;;

9)
cd OpenHAB
bash ./installOpenhab.sh MAIL
cd ..
;;

*)
break
esac


#Eingegebene Variablen zwischenspeichern solange die Konsole noch offen ist

MAIL_ACC=$(cat /home/pi/MESSAGE_PRINTER/MAIL_ACC 2> /dev/null)
if [ -z $MAIL_ACC ]
then
export MAIL_ACC=$(cat /home/pi/SENDMAIL/MAIL_ACC 2> /dev/null)
export MAIL_PW=$(cat /home/pi/SENDMAIL/MAIL_PW 2> /dev/null)
else
export MAIL_ACC=$(cat /home/pi/MESSAGE_PRINTER/MAIL_ACC 2> /dev/null)
export MAIL_PW=$(cat /home/pi/MESSAGE_PRINTER/MAIL_PW 2> /dev/null)
fi

export SMS_PIN=$(cat /home/pi/SMS/SMS_PIN 2> /dev/null) 
export TEL_NR=$(cat /home/pi/FAX/TEL_NR 2> /dev/null) 
export OPENHAB_LAMPE_SMS=$(cat /home/pi/OPENHAB/OPENHAB_LAMPE_SMS 2> /dev/null) 
export OPENHAB_LAMPE_MAIL=$(cat /home/pi/OPENHAB/OPENHAB_LAMPE_MAIL 2> /dev/null) 
export OPENHAB_SCHALTER_STT=$(cat /home/pi/STT/STT 2> /dev/null) 
export OPENHAB_TTS=$(cat /home/pi/TTS/TTS 2> /dev/null) 

done

#Lösche Datei in der Zwischengespeichert wird
rm /home/pi/FAX/TEL_NR 2> /dev/null
rm /home/pi/SENDMAIL/MAIL_PW 2> /dev/null
rm /home/pi/SENDMAIL/MAIL_ACC 2> /dev/null
rm /home/pi/MESSAGE_PRINTER/MAIL_PW 2> /dev/null
rm /home/pi/MESSAGE_PRINTER/MAIL_ACC 2> /dev/null
rm /home/pi/SMS/SMS_PIN 2> /dev/null
rm /home/pi/OPENHAB/OPENHAB_LAMPE_SMS 2> /dev/null
rm /home/pi/OPENHAB/OPENHAB_LAMPE_MAIL 2> /dev/null
rm /home/pi/STT/STT 2> /dev/null

#rm /home/pi/MESSAGE_PRINTER/getmaildir/oldmail* 2> /dev/null #vielleicht entfernen
#rm /home/pi/MESSAGE_PRINTER/TTS/* 2> /dev/null # vielleicht entfernen

#Neustart nach abschluss des Skripts
echo -e "${farbcode}Das System wird sich nun neu starten. Fahren Sie anschließend mit der Anleitung fort.${neutral}"
sleep 5
sudo reboot -f
fi
