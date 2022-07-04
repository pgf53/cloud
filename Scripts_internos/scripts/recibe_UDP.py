#!/usr/bin/python3.6

import socket
import subprocess
import sys
import shlex
import os
import re

UDP_IP_LISTEN = sys.argv[1]
UDP_PORT_LISTEN = sys.argv[2]
RUTA_TAREAS = sys.argv[3]
MESSAGE = b"ACK"

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
	#enviamos ACK
	sock.sendto(MESSAGE, (UDP_IP_SEND, UDP_PORT_SEND))
	TAREA = lista[2]

	numero_instancia = ""
	tamaño_tarea = len(TAREA)
	for character in TAREA:
		#Solo de las dos últimas posiciones (num_instancias_max=99)
		if character == TAREA[tamaño_tarea-1] or character == TAREA[tamaño_tarea-2]:
			if character.isdigit():
				numero_instancia = numero_instancia + character

	#Eliminamos el número de instancia para poder acceder a la tarea en el servidor
	TAREA = TAREA.replace(numero_instancia,"")

	FIN = int(lista[3])	#Indica si la  tarea ha finalizado
	#Obtenemos el número del equipo (eliminamos prefijo)
	prefijo = os.environ["PREFIJO_NOMBRE_EQUIPO"]
	equipo_sin_prefijo = re.split(prefijo, UDP_IP_SEND)
	equipo_sin_prefijo = equipo_sin_prefijo[1]
	#Invocamos a menu_tarea.sh enviándole como parámetro el número del equipo
	cmd_script_menu_tarea = RUTA_TAREAS + TAREA + "/menu_" + TAREA + ".sh " + equipo_sin_prefijo + ' ' + numero_instancia
	args = shlex.split(cmd_script_menu_tarea)
	p = subprocess.run(args)
