#!/bin/bash

readonly X_LINES_POS=576
readonly SRC_HTML="$1"
readonly DST_PNG="$2"
readonly ROTATE="$3"
readonly PHOTO_PROCESSING="$4"
readonly PNG_EXT=".png"
export PNG2POS_PRINTER_MAX_WIDTH="$X_LINES_POS"

echo "Konvertiere HTML-Datei: $1 zu PNG-Datei: $2 ==> mittels \"wkhtmltoimage\""
# wkhtmltoimage hat ein internes Problem welches Fehler meldet, diese koennen ignoriert werden muessen aber nach /dev/null
wkhtmltoimage --width "$X_LINES_POS" --quality 100 "$SRC_HTML" "$DST_PNG" 2> /dev/null &&

if [ "$ROTATE" = "-R" ]
then
	echo "Rotiere PNG-Datei passe Groesse an: $1 und speichere unter PNG-Datei: ${DST_PNG%.*}-ROT.png ==> mittels \"imagemagick\""
	convert "$DST_PNG" -rotate 90 -resize 576 ${DST_PNG%.*}-ROT.png &&
	echo "Sende PNG-Datei: ${DST_PNG%.*}-ROT.png über \"png2pos\" an Drucker"
	if [ "$PHOTO_PROCESSING" = "-p" ]
	then
		png2pos -c -p -s 4 ${DST_PNG%.*}-ROT.png | lpr -o raw
	else
		png2pos -c -s 4 ${DST_PNG%.*}-ROT.png | lpr -o raw
	fi
	
else
	echo "PNG-Datei passe Groesse an: $1 und speichere unter PNG-Datei: ${DST_PNG%.*}-ROT.png ==> mittels \"imagemagick\""
	convert "$DST_PNG" -resize 576 ${DST_PNG%.*}.png &&
	echo "Sende PNG-Datei: ${DST_PNG%.*}.png über \"png2pos\" an Drucker"
	if [ "$PHOTO_PROCESSING" = "-p" ]
	then
		png2pos -c -p -s 4 ${DST_PNG%.*}.png | lpr -o raw
	else
		png2pos -c -s 4 ${DST_PNG%.*}.png | lpr -o raw
	fi
fi

echo "Drucken erfolgreich abgeschlossen!"

