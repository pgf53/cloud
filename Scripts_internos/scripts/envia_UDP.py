#!/usr/bin/python3.6

import socket
import select
import sys

UDP_IP_LISTEN = str(sys.argv[1]) #IP de escucha (debe establecerse automáticamente)
UDP_IP_SEND = str(sys.argv[2])	#IP a la que enviar los resultados
UDP_PORT_SEND = int(sys.argv[3])	#Puerto al que enviar los resultados
TAREA = str(sys.argv[4])
FIN = str(sys.argv[5])
TIEMPO_ENTRE_REINTENTOS = int(sys.argv[6])
NUM_MAX_REINTENTOS = int(sys.argv[7])
NUM_INTENTOS = 0
separador = " "
data = ""

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP_LISTEN, 0))	#Creamos socket de escucha
UDP_PORT_LISTEN = sock.getsockname()[1]
MESSAGE = UDP_IP_LISTEN + separador + str(UDP_PORT_LISTEN) + separador + TAREA + separador + FIN
MESSAGE = MESSAGE.encode()

while True:
	sock.sendto(MESSAGE, (UDP_IP_SEND, UDP_PORT_SEND))	#Enviamos mensaje UDP

	#Esperamos 5 segundos ACK
	#Si no lo recibimos, reenviamos.
	sock.setblocking(0)
	ready = select.select([sock], [], [], TIEMPO_ENTRE_REINTENTOS)
	if ready[0]:	
		data, addr = sock.recvfrom(1024)

	if data == b"ACK":
		print("ACK recibido")
		break
	else:
		print("ACK no recibido")
		NUM_INTENTOS = NUM_INTENTOS + 1
		if NUM_INTENTOS == NUM_MAX_REINTENTOS:
			print("Número máximo de intentos excedido, se descarta el mensaje")
			break
