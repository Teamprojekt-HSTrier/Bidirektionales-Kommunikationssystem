#auslesen des Status für die Lampe SMS und Rückgabe an den aufrufenden Threads (OpenHAB)
statusLampesms=$(cat /home/pi/OPENHAB/lampesms.txt)
echo 2 > /home/pi/OPENHAB/lampesms.txt
return $statusLampesms
