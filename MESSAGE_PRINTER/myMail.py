import sys
import re
from email.parser import Parser
from email.header import decode_header

#### Variable fuer Pfad-Parameter
customPath = sys.argv[1]

#### Variable fuer die eingehende Nachricht welche von der Standardeingabe eingelesen wird.
message = sys.stdin.read()
#### Variable fuer eingehende Nachricht als Rohtext umgewandelt in gueltige E-Mail.
incomingEmail = Parser().parsestr(message)

#### Variablen fuer die Einbettung der Nachricht in HTML.
htmlHeaderHead = """\
<!doctype html>
<html id='customHtml' lang="de">
    <head>
        <meta charset='utf-8'>
        <meta name="viewport" content="initial-scale=1.0">
        <title>Neue Nachricht (Header)</title>
        <style type="text/css">          
            #customBody{
                margin: 0px;
                padding: 0px;
            }            
            #customDiv{
                min-width: 576px!important;
				padding:20px;
				margin:0px;
				border:5px solid black;
				background-color:black;
			}
			#customP{
				padding: 0px;
				margin:0px;
				text-align:justify;
				white-space: pre-wrap;
				font-family:'Rasa SemiBold';
				font-size:3em;
				line-height:1.0em;
			}
			#customH1{
				padding: 0px;
				margin:0px;
				text-align:left;
				font-family:'Rasa SemiBold';
				font-size:2.5em;
				line-height:1em;
				color:white
			}
            @font-face {
				font-family: 'Rasa SemiBold';
				src: url('../FONTS/Rasa-SemiBold.ttf');
				font-weight: normal;
				font-style: normal;
			}
        </style>
    </head>
    <body id='customBody'>
		<div id='customDiv'>"""
				
htmlHeaderTail="""\
</div>
    </body>
</html>
"""

htmlBodyHead = """\
<!doctype html>
<html id='customHtml' lang="de">
    <head>
        <meta charset='utf-8'>
        <meta name="viewport" content="initial-scale=1.0">
        <title>Neue Nachricht (Body)</title>
        <style type="text/css">          
            #customBody{
                margin: 0px;
                padding: 0px;
            }            
            #customDiv{
				height: 526px!important;
                min-width: 576px!important;
                -moz-column-width: 800px;
				-webkit-column-width: 800px;
				column-width:800px;
				-moz-column-gap: 40px;
				-webkit-column-gap: 40px;
				column-gap: 40px;
				-moz-column-rule: 2px solid black;
				-webkit-column-rule: 2px solid black;
				column-gaprule: 2px solid black;
				padding:20px;
				
				margin:0px;
				border:5px solid black;
				/*background-color:green;*/
			}
			#customP{
				/*background-color:red;*/
				padding: 0px;
				margin:0px;
				text-align:justify;
				white-space: pre-wrap;
				font-family:'Rasa SemiBold';
				font-size:3em;
				line-height:1.0em;
			}
			.customH1{
				/*
				background-color:red;
				*/
				padding: 0px;
				margin:0px;
				text-align:left;
				white-space: pre-wrap;
				font-family:'Rasa SemiBold';
				font-size:3.5em;
				line-height:1.0em;
			}
            @font-face {
				font-family: 'Rasa SemiBold';
				src: url('../FONTS/Rasa-SemiBold.ttf');
				font-weight: normal;
				font-style: normal;
			}
        </style>
    </head>
    <body id='customBody'>
		<div id='customDiv'>"""
				
htmlBodyTail = """\
</p>
		</div>
    </body>
</html>""" 

#### Funktionsdefinition um Nachrichtenteile in HTML einzubetten und in zwei Teile abzuspeichert (Header und Body)
def integrateTextInHtmlHeaderBody(incomingEmail, text):
    
    #### Absender der Nachricht passend formatieren
    matchFrom = re.search('\s*?(.*?)\s*?<(.*?)>', incomingEmail['From'])
    
    #### Datum der Nachricht passend formatieren
    date = re.sub(r'\[-+].*',"", str(incomingEmail['Date']))
    
    #### Datum und Absender in HTML einbetten und abspeichern.
    htmlHeaderCombined = htmlHeaderHead + """<h1 id='customH1'>Em@il.: """ + matchFrom.group(2) + """</h1>
				<h1 id='customH1'>Datum: """ + date + """</h1>""" + htmlHeaderTail
    file = open(customPath + "/emailHeader.html","w")
    file.write(htmlHeaderCombined)
    file.close()

    #### Betreff und Nachrichteninhalt in HTML einbetten und abspeichern.
    htmlBodyCombined = htmlBodyHead + """<h1 class='customH1'>Absender: """ + matchFrom.group(1) + """</h1>
""" + """<h1 class='customH1'>Betreff: """ + decode_header(incomingEmail['Subject'])[0][0] + """</h1>
""" + """<p id='customP'>"""  + text + htmlBodyTail
    file = open(customPath + "/emailBody.html","w")
    file.write(htmlBodyCombined)
    file.close()
    

#### Zerlegung der Nachricht in Einzelteile um Text und Anhaenge abzuspeichern
text = None
for contentPart in incomingEmail.walk(): # Alle Nachrichtenteile durchitterien
    if contentPart.get_content_type() == "multipart":
        continue
    elif contentPart.get_content_type() == "text/html": # HTML-Text der Nachricht extrahieren und abspeichern
        htmlText = contentPart.get_payload(decode=True)
        file = open(customPath + "/htmlText.html","w")
        # Auf .jpg-Anhänge im Ordner referenzieren um diese in HTML-Emails einzubinden (.png ist nicht implementiert).
        htmlTextSRC = re.sub(r'<img.+?(?i)src.*?=.*?(?i)(CID):',"<img src=\"./", htmlText)
        htmlTextSRCExtension = re.sub(r'(<img src=\"./.*?)(\")',r'\1' + '.jpg' + r'\2', htmlTextSRC)
        file.write(htmlTextSRCExtension)
        file.close()
    elif contentPart.get_content_type() == "text/plain": # Text der Nachricht extrahieren und abspeichern
        text = contentPart.get_payload(decode=True)
        file = open(customPath + "/text.txt","w")
        file.write(text)
        file.close()        
    elif contentPart.get_content_type() == "image/jpeg": # .jpg-Anhang extrahieren und abspeichern
        image = contentPart.get_payload(decode=True)
        imageName = contentPart["Content-ID"].replace("<","").replace(">","")
        file = open(customPath + "/" + imageName + ".jpg","w")
        file.write(image)
        file.close()
    elif contentPart.get_content_type() == "image/png": # .png-Anhang extrahieren und abspeichern
        print contentPart.get_payload(decode=True)
        imageName = contentPart["Content-ID"].replace("<","").replace(">","")
        file = open(customPath + "/" + imageName + ".png","w")
        file.write(image)
        file.close()
        
#### Funktionsaufruf, falls Nachricht Text enthaelt
if text is not None:
        integrateTextInHtmlHeaderBody(incomingEmail, text)
