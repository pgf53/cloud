#!/usr/bin/python3.6

import socket
import select
import sys

UDP_IP_LISTEN = str(sys.argv[1]) #IP de escucha (debe establecerse automáticamente)
#UDP_PORT_LISTEN = int(sys.argv[2])	#Puerto de escucha
UDP_IP_SEND = str(sys.argv[2])	#IP a la que enviar los resultados
UDP_PORT_SEND = int(sys.argv[3])	#Puerto al que enviar los resultados
TAREA = str(sys.argv[4])
FIN = str(sys.argv[5])
TIEMPO_ENTRE_REINTENTOS = int(sys.argv[6])
NUM_MAX_REINTENTOS = int(sys.argv[7])
NUM_INTENTOS = 0
separador = " "
data = ""

#print(UDP_IP_LISTEN + "	" + UDP_PORT_LISTEN + "	" + UDP_IP_SEND + "	" + UDP_PORT_SEND + "	")
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#sock.bind((UDP_IP_LISTEN, UDP_PORT_LISTEN))	#Creamos socket de escucha
sock.bind((UDP_IP_LISTEN, 0))	#Creamos socket de escucha
UDP_PORT_LISTEN = sock.getsockname()[1]
MESSAGE = UDP_IP_LISTEN + separador + str(UDP_PORT_LISTEN) + separador + TAREA + separador + FIN
MESSAGE = MESSAGE.encode()

while True:
	sock.sendto(MESSAGE, (UDP_IP_SEND, UDP_PORT_SEND))	#Enviamos mensaje UDP

	#Esperamos 5 segundos ACK
	#Si no lo recibimos, reenviamos.
	sock.setblocking(0)
	#ready = select.select([sock], [], [], 5)
	ready = select.select([sock], [], [], TIEMPO_ENTRE_REINTENTOS)
	if ready[0]:	
		data, addr = sock.recvfrom(1024)

		with open('send.log', "a+") as file_object:
			# Move read cursor to the start of file.
			file_object.seek(0)
			# If file is not empty then append '\n'
			recibido = file_object.read(100)
			if len(recibido) > 0:
				file_object.write("\n")
			 # Append text at the end of file
			file_object.write("Mensaje recibido del servidor: " + str(data.decode()))

	else:
		with open('send.log', "a+") as file_object:
			# Move read cursor to the start of file.
			file_object.seek(0)
			# If file is not empty then append '\n'
			recibido = file_object.read(100)
			if len(recibido) > 0:
				file_object.write("\n")
			 # Append text at the end of file
			file_object.write("Sin datos que leer. NO RESPUESTA DEL SERVIDOR")


	with open('send.log', "a+") as file_object:
		# Move read cursor to the start of file.
		file_object.seek(0)
		# If file is not empty then append '\n'
		recibido = file_object.read(100)
		if len(recibido) > 0:
			file_object.write("\n")
		 # Append text at the end of file
		file_object.write("Mensaje enviado por cliente: " + UDP_IP_LISTEN + separador + str(UDP_PORT_LISTEN) + separador + TAREA + separador + FIN + " to: " + str(UDP_IP_SEND) + ":" + str(UDP_PORT_SEND))

	if data == b"ACK":
		print("ACK recibido")
		with open('send.log', "a+") as file_object:
			# Move read cursor to the start of file.
			file_object.seek(0)
			# If file is not empty then append '\n'
			recibido = file_object.read(100)
			if len(recibido) > 0:
				file_object.write("\n")
			 # Append text at the end of file
			file_object.write("Equipo: " + UDP_IP_LISTEN + " Instancia: " + TAREA + " ACK recibido")
		break
	else:
		print("ACK no recibido")

		with open('send.log', "a+") as file_object:
			# Move read cursor to the start of file.
			file_object.seek(0)
			# If file is not empty then append '\n'
			recibido = file_object.read(100)
			if len(recibido) > 0:
				file_object.write("\n")
			 # Append text at the end of file
			file_object.write("Equipo: " + UDP_IP_LISTEN + " Instancia: " + TAREA + " ACK NO recibido")


		NUM_INTENTOS = NUM_INTENTOS + 1
		if NUM_INTENTOS == NUM_MAX_REINTENTOS:
			print("Número máximo de intentos excedido, se descarta el mensaje")

			with open('send.log', "a+") as file_object:
				# Move read cursor to the start of file.
				file_object.seek(0)
				# If file is not empty then append '\n'
				recibido = file_object.read(100)
				if len(recibido) > 0:
					file_object.write("\n")
				 # Append text at the end of file
				file_object.write("Equipo: " + UDP_IP_LISTEN + " Instancia: " + TAREA + " DESCARTADA")

			break



