#!/bin/bash
#installation der benötigten Komponenten für den Drucker
echo "Entferne wolfram alpha..."
sudo apt-get purge wolfram
sudo apt-get purge wolfram-engine
echo "Installiere Abhaengigkeiten, bitte warten..."
sudo apt-get -y install wkhtmltopdf cups libcups2-dev libcupsimage2-dev system-config-printer imagemagick xvfb

#Benötigte Berechtigungen, welche zum Drucken benötigt werden setzen
echo "Setze Benutzerrechte fuer das System."
sudo usermod -a -G lpadmin pi
sudo usermod -a -G lp pi

#Drucker Dienst starten
echo "Starte Dienst CUPS neu."
sudo systemctl restart cups.service

#PNG to POS installieren, welches Bilder umformatiert in Drucker Befehle
echo "Starte Installation von png2pos..."
tar -xf png2pos.tar
#echo "    Lade png2pos herunter..."
#git clone --recursive https://gitlab.com/wiltonlazary/png2pos.git
echo "    Wechsle in das Verzeichnis png2pos."
cd png2pos/
echo "    png2pos wird installiert..."
make
sudo make install
echo "...Installation abgeschlossen."
echo "Wechlse zum Ã¼bergeordneten Verzeichnis."
cd ..

#Bei auswahl von SMS das SMS installations Skript starten
if [ $1 = "SMS" ]
then
cd ./../SMS
bash ./installSMS.sh
fi

#Bei auswahl von MAIL das MAIL Empfang installations Skript starten
if [ $1 = "MAIL" ]
then
cd ./../MESSAGE_PRINTER
bash ./installPrinter.sh
fi
