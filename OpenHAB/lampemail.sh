#auslesen des Status für die Lampe Mail und Rückgabe an den aufrufenden Threads (OpenHAB)
statusLampemail=$(cat /home/pi/OPENHAB/lampemail.txt)
echo 2 > /home/pi/OPENHAB/lampemail.txt
return $statusLampemail
