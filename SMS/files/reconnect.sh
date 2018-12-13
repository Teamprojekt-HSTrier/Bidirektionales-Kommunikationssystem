#!/bin/bash
#in das Logfile von Gammu schauen, ob der UMTS Stick ermittelt werden kann.
while [ true ] ; do
logfile=$(cat /var/log/gammu-smsd | grep "DEVICENOTEXIST")

#steht im Logfile nicht DEVICENOTEXIST, so wird 10s gewartet und erneut geprüft.
if [ -z "$logfile" ]
then
echo "Verbindung zum UMTS Stick vorhanden"
sleep 10

#steht im Logfile DEVICENOTEXIST, so wird dieses Logfile gelöscht, um nicht unendlichoft einen Reconnect durchzuführen.
else
echo "Verbindung zum UMTS Stick verloren"
sudo rm /var/log/gammu-smsd

#ermitteln aller Angeschlossenen USB Geräte und abspeichern in eine Text datei.
lsusb > /home/pi/SMS/usb.txt
#Name des Herstellers vom UMTS Stick
Hersteller="Huawei"

#Die USB Geräte werden auf den Herstellernamen gefiltert. Anschließend wird die BUS und DEVICE ID ermittelt.
while IFS='' read -r line || [[ -n "$line" ]]; do
if [[ "$line" =~ "Huawei" ]]
then
#  gefunden="true"
  bus=$(echo $line| cut -d' ' -f 2)
  device=$(echo $line| cut -d' ' -f 4)
  device=${device:0:3}
  echo "$bus $device"  
fi
done < /home/pi/SMS/usb.txt

#die Zwischenspeicherung von allen USB Geräten wird gelöscht.
rm /home/pi/SMS/usb.txt

#Ein Reconnect von dem ermittelten Gerät mit der passenden BUS und DEVICE ID wird durchgeführt.
sudo service gammu-smsd stop
sudo /home/pi/SMS/UMTSStick/usbreset /dev/bus/usb/$bus/$device
sudo service gammu-smsd start

#es wird 10s gewartet
sleep 10

fi

#Die Schleife wird wiederholt.
done

