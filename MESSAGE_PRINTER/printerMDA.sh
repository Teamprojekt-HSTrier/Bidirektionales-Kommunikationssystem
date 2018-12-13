#!/bin/bash

##### Variable fuer die eingehende Nachricht
INCOMING_MAIL="$(cat)"
MESSAGE_DIR="${PWD}/messagedir"

#### Die eingehende Nachricht wird an das Pythonskript myMail.py weitergeleitet.
#### Dieses bettet die Nachricht in zwei HTML-Dateien ein.
echo "$INCOMING_MAIL" | python "${PWD}/myMail.py" "$MESSAGE_DIR" 2> /dev/null &&

#### Erst nachdem das Pythonskript abgearbeitet wurde (&&) wird der folgende Befehl ausgefuehrt
#### Das Skript emailHtmlToEmailPngThenPrint wandelt die zuvor erstellte HTML-Dateien in PNG-Bilddateien um und 
#### sendet diese an den Drucker. 
# Bug betreffend wkhtmltoimage im Headless-Modus
# Hinweis fuer die Loesung:
# https://unix.stackexchange.com/questions/192642/wkhtmltopdf-qxcbconnection-could-not-connect-to-display
sudo -u pi /usr/bin/xvfb-run bash "${PWD}/emailHtmlToEmailPngThenPrint.sh" "${MESSAGE_DIR}/emailHeader.html" "${MESSAGE_DIR}/emailHeader.png" "${MESSAGE_DIR}/emailBody.html" "${MESSAGE_DIR}/emailBody.png" 2> /dev/null