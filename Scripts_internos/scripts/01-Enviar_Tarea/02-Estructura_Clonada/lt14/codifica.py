#!/usr/bin/python3.6
import sys
import urllib.parse
#import re
#import requests
#import time
#import os

#format
if len(sys.argv) != 3:
	print('Format: codifica.py file.uri dir_out')
	sys.exit()

# constants
file_uri = sys.argv[1]
file_out = sys.argv[2]
append_or_write_1 = 'w+'
name_posicion = file_uri.index('.')


file_name = file_uri[0:name_posicion]
file_name_posicion = file_name.rfind('/')
total_characters = len(file_name)
file_name = file_name[file_name_posicion + 1:total_characters]
file_uri_encoded_name = file_name +  "_codificado.uri" 
file_uri_encoded = file_out + file_uri_encoded_name

#print(file_uri_codificado)
#sys.exit()

encodingUris = open(file_uri_encoded, append_or_write_1)

with open(file_uri, 'r', encoding='ISO-8859-1', errors='ignore') as file:
	for line in file:
		if line[0] != "/":
			line = "/" + line
		encodingUri = urllib.parse.quote(line)
		encodingUris.write(encodingUri + '\n')
		append_or_write_1 = 'a'

encodingUris.close()
