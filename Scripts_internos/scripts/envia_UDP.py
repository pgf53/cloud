#!/usr/bin/python3.6

import socket
import select
import sys

UDP_IP_LISTEN = str(sys.argv[1]) #IP de escucha (debe establecerse automáticamente)
UDP_PORT_LISTEN = int(sys.argv[2])	#Puerto de escucha
UDP_IP_SEND = str(sys.argv[3])	#IP a la que enviar los resultados
UDP_PORT_SEND = int(sys.argv[4])	#Puerto al que enviar los resultados
TAREA = str(sys.argv[5])
FIN = str(sys.argv[6])
TIEMPO_ENTRE_REINTENTOS = int(sys.argv[7])
NUM_MAX_REINTENTOS = int(sys.argv[7])
NUM_INTENTOS = 0
separador = " "
MESSAGE = UDP_IP_LISTEN + separador + str(UDP_PORT_LISTEN) + separador + TAREA + separador + FIN
MESSAGE = MESSAGE.encode()
data = ""

#print(UDP_IP_LISTEN + "	" + UDP_PORT_LISTEN + "	" + UDP_IP_SEND + "	" + UDP_PORT_SEND + "	")
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP_LISTEN, UDP_PORT_LISTEN))	#Creamos socket de escucha

while True:
	sock.sendto(MESSAGE, (UDP_IP_SEND, UDP_PORT_SEND))	#Enviamos mensaje UDP
	#Esperamos 5 segundos ACK
	#Si no lo recibimos, reenviamos.
	sock.setblocking(0)
	#ready = select.select([sock], [], [], 5)
	ready = select.select([sock], [], [], TIEMPO_ENTRE_REINTENTOS)
	if ready[0]:	
		data, addr = sock.recvfrom(1024)
	if data == b"ACK":
		print("ACK recibido")
		break
	else:
		print("ACK no recibido")
		sock.sendto(MESSAGE, (UDP_IP_SEND, UDP_PORT_LISTEN))
		NUM_INTENTOS = NUM_INTENTOS + 1
		if NUM_INTENTOS == NUM_MAX_REINTENTOS:
			print("Número máximo de intentos excedido, se descarta el mensaje")
			break



