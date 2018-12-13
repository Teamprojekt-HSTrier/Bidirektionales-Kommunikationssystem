#!/usr/bin/env python3
# Requires PyAudio and PySpeech.
 
import speech_recognition as sr
 
# Record Audio
r = sr.Recognizer()
r.dynamic_energy_treshold = True
#with sr.Microphone() as source:
#    print("Say something!")
#    audio = r.listen(source)
#    r.dynamic_energy_treshold = True
	
with sr.AudioFile('/home/pi/STT/aufnahme.wav') as source:
    print("Wav wird verarbeitet!")
    audio = r.record(source)

fobj_out = open("/home/pi/STT/stt.txt", "w")

# Speech recognition using Google Speech Recognition
try:
    # for testing purposes, we're just using the default API key
    # to use another API key, use `r.recognize_google(audio, key="GOOGLE_SPEECH_RECOGNITION_API_KEY")`
    # instead of `r.recognize_google(audio)`
	ausgabe = (r.recognize_google(audio, language='de-DE'))
    # print "Es wurde verstanden: {}".format(ausgabe)
except sr.UnknownValueError:
    print("Aufnahme konnte nicht erkannt werden.")
except sr.RequestError as e:
    print("Could not request results from Google Speech Recognition service; {0}".format(e))

fobj_out.write(ausgabe.encode("utf-8"))
fobj_out.close()