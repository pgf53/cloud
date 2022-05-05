#!/usr/bin/python3.6

import socket
import subprocess
import sys
import shlex
import os
import re


#out = subprocess.Popen(['wc', '-l', 'my_text_file.txt'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
#UDP_IP_LISTEN = "172.16.17.1"
UDP_IP_LISTEN = sys.argv[1]
#UDP_IP_SEND = "172.16.17.3"
#UDP_PORT_LISTEN = 9999
UDP_PORT_LISTEN = sys.argv[2]
RUTA_TAREAS = sys.argv[3]
#UDP_PORT_SEND = 9998
MESSAGE = b"ACK"

#print("IP de escucha: %s" % UDP_IP_LISTEN)
#print("PUERTO de escucha: %s" % UDP_PORT_LISTEN)

sock = socket.socket(socket.AF_INET, # Internet
socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP_LISTEN, int(UDP_PORT_LISTEN)))

while True:
	data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
	print("received message: %s" % data.decode())
	datos = data.decode()
	lista = datos.split()
	#Procesamos los datos obtenidos del mensaje  UDP
	UDP_IP_SEND = lista[0]
	UDP_PORT_SEND = int(lista[1])
	TAREA = lista[2]
	FIN = int(lista[3])	#Indica si la  tarea ha finalizado
	#enviamos ACK
	sock.sendto(MESSAGE, (UDP_IP_SEND, UDP_PORT_SEND))
	#Obtenemos el número del equipo (eliminamos prefijo)
	#equipo = subprocess.getoutput('cat /etc/hosts | grep ' + UDP_IP_SEND + ' | awk \'{print $2}\'')
	prefijo = os.environ["PREFIJO_NOMBRE_EQUIPO"]
	equipo_sin_prefijo = re.split(prefijo, UDP_IP_SEND)
	equipo_sin_prefijo = equipo_sin_prefijo[1]
	#Invocamos a menu_tarea.sh enviándole como parámetro el número del equipo
	cmd_script_menu_tarea = RUTA_TAREAS + TAREA + "/menu_" + TAREA + ".sh " + equipo_sin_prefijo
	args = shlex.split(cmd_script_menu_tarea)
	print(args)
	p = subprocess.run(args)
	#p = subprocess.Popen(args)



