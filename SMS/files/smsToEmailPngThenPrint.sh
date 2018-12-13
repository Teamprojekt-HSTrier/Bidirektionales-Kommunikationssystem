#!/bin/bash

#### Variable fuer die Anzahl der vertikalen Linien, welche der Drucker beherrscht.
X_LINES_POS=512
#### Variable fuer den Pfad zum Header im HTML-Format fuer die umzuwandelnde Nachricht.
SRC_HTML_HEADER="$1"
#### Variable fuer den Pfad zur PNG-Datei welche aus dem Header erstellt wird.
DST_PNG_HEADER="$2"
#### Variable fuer den Pfad zum Body im HTML-Format fuer die umzuwandelnde Nachricht.
SRC_HTML_BODY="$3"
#### Variable fuer den Pfad zur PNG-Datei welche aus dem Body erstellt wird.
DST_PNG_BODY="$4"
#PNG_EXT=".png"

#### Umgebungsvariable fuer hier aufgerufene Shells erstellen
export PNG2POS_PRINTER_MAX_WIDTH="$X_LINES_POS"
export DISPLAY=:0

#### Hier wird der Header im PNG-Format fuer die Nachricht aus dem Header im HTML-Format generiert
echo "Konvertiere HTML-Datei: $SRC_HTML_HEADER zu PNG-Datei: $SRC_HTML_HEADER ==> mittels \"wkhtmltoimage\" ==> $DST_PNG_HEADER"
# wkhtmltoimage hat ein internes Problem welches Fehler meldet, diese koennen ignoriert werden muessen aber nach /dev/null
/usr/bin/wkhtmltoimage --width "$X_LINES_POS" --quality 100 "$SRC_HTML_HEADER" "$DST_PNG_HEADER"
# 2> /dev/null

#### Hier wird die PNG-Datei falls die Groesse durch einen Bug in wkhtmltoimage nicht stimmt erneut auf X_LINES_POS gesetzt
echo "Passe Groesse an und speichere ab. $DST_PNG_BODY  ==> mittels \"imagemagick\" ==> DST_PNG_BODY"
/usr/bin/convert "$DST_PNG_HEADER" -resize "$X_LINES_POS" "$DST_PNG_HEADER" 2> /dev/null &&
# 2> /dev/null
	
#### Hier wird der Body im PNG-Format fuer die Nachricht aus dem Body im HTML-Format generiert	
echo "Konvertiere HTML-Datei: $SRC_HTML_BODY zu PNG-Datei: $SRC_HTML_BODY ==> mittels \"wkhtmltoimage\"  ==> $DST_PNG_BODY"
# wkhtmltoimage hat ein internes Problem welches Fehler meldet, diese koennen ignoriert werden, muessen aber nach /dev/null
/usr/bin/wkhtmltoimage --height "$X_LINES_POS" --quality 100 "$SRC_HTML_BODY" "$DST_PNG_BODY"
# 2> /dev/null

#### Hier wird die PNG-Datei fuer die Ausgabe rotiert und 
#### falls die Groesse durch einen Bug in wkhtmltoimage nicht stimmt erneut auf X_LINES_POS gesetzt
echo "Rotiere PNG-Datei, passe Groesse an und speichere ab. $DST_PNG_HEADER  ==> mittels \"imagemagick\" ==> $DST_PNG_HEADER"
/usr/bin/convert "$DST_PNG_BODY" -rotate 90 -resize "$X_LINES_POS" "$DST_PNG_BODY" 2> /dev/null &&
# 2> /dev/null

#### Hier werden die PNG-Dateien in POS-Befehle umgewandelt und an den Drucker gesendet. 

png2pos -s 4 "$DST_PNG_HEADER" | lp
png2pos -s 4 -c "$DST_PNG_BODY" | lp

# /usr/local/bin/png2pos -s 4 "$DST_PNG_HEADER" | /usr/bin/lpr -o raw
# /usr/local/bin/png2pos -c -s 4 "$DST_PNG_BODY" | /usr/bin/lpr -o raw

echo "Drucken erfolgreich abgeschlossen!"
