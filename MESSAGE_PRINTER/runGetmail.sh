#!/bin/bash

# Hinweis fuer die Vorgehensweise:
# https://askubuntu.com/questions/47800/command-not-found-when-running-a-script-via-cron/47801#47801
#export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin"

#### In das richtige Verzeichniss wechseln.
cd /home/pi/MESSAGE_PRINTER/

# Hinweis fuer die Vorgehensweise:
# http://stackoverflow.com/questions/696839/how-do-i-write-a-bash-script-to-restart-a-process-if-it-dies/697064#697064

#### Starte getmail mit der idle-Funktion. Starte getmail neu falls unerwartet beendet.

until  getmail "--idle=Inbox" "--getmaildir=${PWD}/getmaildir"; do
    echo "Restarting getmail"
    #### Warte jeweils 10 Sekunden um Ressourcen zu schonen
    sleep 10
done
