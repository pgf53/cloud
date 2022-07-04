#!/usr/bin/python3.6

import sys
import os
#import linecache
#import subprocess


def ordena_attacks(lista_attacks, fichero_sin_extension):
	ficheros_ataque_ordenados = []
	contador = 0
	numero_ficheros_ataque = len(lista_attacks)
	while contador < numero_ficheros_ataque:
		if contador < 10:
			siguiente_fichero = fichero_sin_extension + "_00" + str(contador) + ".attacks"
			index = lista_attacks.index(siguiente_fichero)
			ficheros_ataque_ordenados.append(lista_attacks[index])
			lista_attacks.pop(index)
		elif contador >= 10 and contador < 100:
			siguiente_fichero = fichero_sin_extension + "_0" + str(contador)  + ".attacks"
			index = lista_attacks.index(siguiente_fichero)
			ficheros_ataque_ordenados.append(lista_attacks[index])
			lista_attacks.pop(index)
		elif contador >= 100:
			siguiente_fichero = fichero_sin_extension + "_" + str(contador)  + ".attacks"
			index = lista_attacks.index(siguiente_fichero)
			ficheros_ataque_ordenados.append(lista_attacks[index])
			lista_attacks.pop(index)
		contador = contador + 1
	return ficheros_ataque_ordenados

def ordena_cleans(lista_cleans, fichero_sin_extension):
	ficheros_clean_ordenados = []
	contador = 0
	numero_ficheros_clean = len(lista_cleans)
	while contador < numero_ficheros_clean:
		if contador < 10:
			siguiente_fichero = fichero_sin_extension + "_00" + str(contador) + ".clean"
			index = lista_cleans.index(siguiente_fichero)
			ficheros_clean_ordenados.append(lista_cleans[index])
			lista_cleans.pop(index)
		elif contador >= 10  and contador < 100:
			siguiente_fichero = fichero_sin_extension + "_0" + str(contador)  + ".clean"
			index = lista_cleans.index(siguiente_fichero)
			ficheros_clean_ordenados.append(lista_cleans[index])
			lista_cleans.pop(index)
		elif contador >= 100:
			siguiente_fichero = fichero_sin_extension + "_" + str(contador)  + ".clean"
			index = lista_cleans.index(siguiente_fichero)
			ficheros_clean_ordenados.append(lista_cleans[index])
			lista_cleans.pop(index)
		contador = contador + 1
	return ficheros_clean_ordenados

def ordena_info_attacks(lista_info_attacks, fichero_sin_extension):
	ficheros_info_attacks_ordenados = []
	contador = 0
	numero_ficheros_info_attacks = len(lista_info_attacks)
	while contador < numero_ficheros_info_attacks:
		if contador < 10:
			siguiente_fichero = fichero_sin_extension + "_00" + str(contador) + "-info.attacks"
			index = lista_info_attacks.index(siguiente_fichero)
			ficheros_info_attacks_ordenados.append(lista_info_attacks[index])
			lista_info_attacks.pop(index)
		elif contador >= 10  and contador < 100:
			siguiente_fichero = fichero_sin_extension + "_0" + str(contador)  + "-info.attacks"
			index = lista_info_attacks.index(siguiente_fichero)
			ficheros_info_attacks_ordenados.append(lista_info_attacks[index])
			lista_info_attacks.pop(index)
		elif contador >= 100:
			siguiente_fichero = fichero_sin_extension + "_" + str(contador)  + "-info.attacks"
			index = lista_info_attacks.index(siguiente_fichero)
			ficheros_info_attacks_ordenados.append(lista_info_attacks[index])
			lista_info_attacks.pop(index)
		contador = contador + 1
	return ficheros_info_attacks_ordenados

def ordena_log(lista_log, fichero_sin_extension):
	ficheros_log_ordenados = []
	contador = 0
	numero_ficheros_log = len(lista_log)
	while contador < numero_ficheros_log:
		if contador < 10:
			siguiente_fichero = fichero_sin_extension + "_00" + str(contador) + ".log"
			index = lista_log.index(siguiente_fichero)
			ficheros_log_ordenados.append(lista_log[index])
			lista_log.pop(index)
		elif contador >= 10  and contador < 100:
			siguiente_fichero = fichero_sin_extension + "_0" + str(contador)  + ".log"
			index = lista_log.index(siguiente_fichero)
			ficheros_log_ordenados.append(lista_log[index])
			lista_log.pop(index)
		elif contador >= 100:
			siguiente_fichero = fichero_sin_extension + "_" + str(contador)  + ".log"
			index = lista_log.index(siguiente_fichero)
			ficheros_log_ordenados.append(lista_log[index])
			lista_log.pop(index)
		contador = contador + 1
	return ficheros_log_ordenados

def ordena_index(lista_index, fichero_sin_extension):
	ficheros_index_ordenados = []
	contador = 0
	numero_ficheros_index = len(lista_index)
	while contador < numero_ficheros_index:
		if contador < 10:
			siguiente_fichero = fichero_sin_extension + "_00" + str(contador) + ".index"
			index = lista_index.index(siguiente_fichero)
			ficheros_index_ordenados.append(lista_index[index])
			lista_index.pop(index)
		elif contador >= 10  and contador < 100:
			siguiente_fichero = fichero_sin_extension + "_0" + str(contador)  + ".index"
			index = lista_index.index(siguiente_fichero)
			ficheros_index_ordenados.append(lista_index[index])
			lista_index.pop(index)
		elif contador >= 100:
			siguiente_fichero = fichero_sin_extension + "_" + str(contador)  + ".index"
			index = lista_index.index(siguiente_fichero)
			ficheros_index_ordenados.append(lista_index[index])
			lista_index.pop(index)
		contador = contador + 1
	return ficheros_index_ordenados


ficheros_divididos = []
posicion = 0
num_ficheros_dividir = len(os.listdir(os.environ["DIR_FICHEROS_DIVIDIR"])) - 1 
progreso = 1

with os.scandir(os.environ["DIR_FICHEROS_DIVIDIR"]) as ficheros_a_dividir:
	for fichero_a_dividir in ficheros_a_dividir:
		if fichero_a_dividir.name != ".gitkeep":
			print(str(fichero_a_dividir.name))
			print(str(progreso) + "/" + str(num_ficheros_dividir))
			num_lineas_totales = sum(1 for i in open(os.environ["DIR_FICHEROS_DIVIDIR"] + fichero_a_dividir.name, 'rb'))
			num_lineas_por_division = num_lineas_totales // int(os.environ["DIVISIONES"])
			fichero_sin_extension = fichero_a_dividir.name.replace(os.environ["EXTENSION_ENTRADA"], "")
			with os.scandir(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"]) as dir_resultados:
				for dir_resultado in dir_resultados:
					if dir_resultado.name == "04A-Attacks":
						with os.scandir(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name) as resultados_ataques:
							ficheros_divididos = []
							for resultado_ataque in resultados_ataques:
								#Dentro de 04A-Attacks en los resultados
								#Procesamos attacks
								if resultado_ataque.name.startswith(fichero_sin_extension + "_") and not resultado_ataque.name.endswith('-info.attacks') and not resultado_ataque.name.endswith('-info-hide.attacks'):
									ficheros_divididos.append(resultado_ataque.name)
							#print("Esta es el num de ficheros divididos: " + str(len(ficheros_divididos)))
							#print(ficheros_divididos)
							#print("Esta es el de divisiones: " + os.environ["DIVISIONES"])
							if len(ficheros_divididos) == int(os.environ["DIVISIONES"]):
								ficheros_ataque_ordenados = ordena_attacks(ficheros_divididos, fichero_sin_extension)
								for fichero_ataque_ordenado in ficheros_ataque_ordenados:
									if os.path.getsize(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_ataque_ordenado) > 0:
										with open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_ataque_ordenado) as f:
											for linea in f:
												if linea.startswith('Packet ['):
													if posicion == 0:
														fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_ATTACKS"], "a")
														fichero_fusionado.write("%s" %linea)
														fichero_fusionado.close()
													else:
														x = linea.split()
														numero_paquete = x[1].replace('[','').replace(']','')
														numero_paquete = num_lineas_por_division * posicion + int(numero_paquete)
														ataque = x[0] + " " + "[" + str(numero_paquete) + "]" + "\t" + x[2] + " " + x[3]
														fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_ATTACKS"], "a")
														fichero_fusionado.write("%s" %ataque)
														fichero_fusionado.write("\n")
														fichero_fusionado.close()
												else:
													fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_ATTACKS"], "a")
													fichero_fusionado.write("%s" %linea)
													fichero_fusionado.close()
											posicion = posicion + 1
									else:
										open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_ATTACKS"], "a").close()

									os.remove(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_ataque_ordenado)
						posicion = 0
					elif dir_resultado.name == "04B-Clean":
						with os.scandir(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name) as resultados_cleans:
							ficheros_divididos = []
							for resultado_clean in resultados_cleans:
								#Dentro de 04B-Clean en los resultados
								#Procesamos cleans
								if resultado_clean.name.startswith(fichero_sin_extension + "_"):
									ficheros_divididos.append(resultado_clean.name)
							if len(ficheros_divididos) == int(os.environ["DIVISIONES"]):
								ficheros_cleans_ordenados = ordena_cleans(ficheros_divididos, fichero_sin_extension)
								#print(str(ficheros_cleans_ordenados) + "\n")
								for fichero_clean_ordenado in ficheros_cleans_ordenados:
									#print(str(fichero_clean_ordenado))
									with open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_clean_ordenado) as f:
										for linea in f:
											if linea.startswith('Packet ['):
												if posicion == 0:
													fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_CLEAN"], "a")
													fichero_fusionado.write("%s" %linea)
													fichero_fusionado.close()
												else:
													x = linea.split()
													numero_paquete = x[1].replace('[','').replace(']','')
													numero_paquete = num_lineas_por_division * posicion + int(numero_paquete)
													limpia = x[0] + " " + "[" + str(numero_paquete) + "]" + "\t" + x[2] + " " + x[3]
													fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_CLEAN"], "a")
													fichero_fusionado.write("%s" %limpia)
													fichero_fusionado.write("\n")
													fichero_fusionado.close()
											else:
												fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_CLEAN"], "a")
												fichero_fusionado.write("%s" %linea)
												fichero_fusionado.close()
										posicion = posicion + 1
									os.remove(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_clean_ordenado)
						posicion = 0
					elif dir_resultado.name == "02-Log":
						with os.scandir(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name) as resultados_log:
							ficheros_divididos = []
							for resultado_log in resultados_log:
								#Dentro de 02-Log en los resultados
								#Procesamos logs
								if resultado_log.name.startswith(fichero_sin_extension + "_"):
									ficheros_divididos.append(resultado_log.name)
							if len(ficheros_divididos) == int(os.environ["DIVISIONES"]):
								ficheros_log_ordenados = ordena_log(ficheros_divididos, fichero_sin_extension)
								fichero_fusionado = os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_LOG"]
								for fichero_log_ordenado in ficheros_log_ordenados:
									fichero_fragmentado = os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_log_ordenado
									call_with_args = "cat '%s' >> '%s'" % (str(fichero_fragmentado), str(fichero_fusionado))
									os.system(call_with_args)
									os.remove(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_log_ordenado)
					elif dir_resultado.name == "03-Index":
						with os.scandir(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name) as resultados_index:
							ficheros_divididos = []
							for resultado_index in resultados_index:
								#Dentro de 03-index en los resultados
								#Procesamos index
								if resultado_index.name.startswith(fichero_sin_extension + "_"):
									ficheros_divididos.append(resultado_index.name)
							if len(ficheros_divididos) == int(os.environ["DIVISIONES"]):
								ficheros_index_ordenados = ordena_index(ficheros_divididos, fichero_sin_extension)
								fichero_fusionado = os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_sin_extension + os.environ["EXTENSION_INDEX"]
								for fichero_index_ordenado in ficheros_index_ordenados:
									fichero_fragmentado = os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_index_ordenado
									call_with_args = "cat '%s' >> '%s'" % (str(fichero_fragmentado), str(fichero_fusionado))
									os.system(call_with_args)
									os.remove(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_index_ordenado)



		#Si se han recibido todos los fragmentos se reconstruye el info-attacks
			with os.scandir(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks") as resultados_info_attacks:
				ficheros_divididos = []
				for resultado_info_attacks in resultados_info_attacks:
					if resultado_info_attacks.name.startswith(fichero_sin_extension + "_") and resultado_info_attacks.name.endswith('-info.attacks'):
						ficheros_divididos.append(resultado_info_attacks.name)
				if len(ficheros_divididos) == int(os.environ["DIVISIONES"]):
					ficheros_info_attacks_ordenados = ordena_info_attacks(ficheros_divididos, fichero_sin_extension)
					for fichero_info_attacks_ordenado in ficheros_info_attacks_ordenados:
						num_lines_info = sum(1 for line_info in open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_info_attacks_ordenado))
						if num_lines_info > 3:
							with open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_info_attacks_ordenado) as f:
									longitud_cabecera = 3
									for linea in f:
										if longitud_cabecera > 0:
											longitud_cabecera = longitud_cabecera - 1
										else:
											if linea.startswith('Packet ['):
												if posicion == 0:
													fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_sin_extension + os.environ["EXTENSION_INFO_ATTACKS"], "a")
													fichero_fusionado.write("%s" %linea)
													fichero_fusionado.close()
												else:
													x = linea.rsplit('	Uri', 1)
													y = x[0].split()
													numero_paquete = y[1].replace('[','').replace(']','')
													numero_paquete = num_lineas_por_division * posicion + int(numero_paquete)
													info_attacks = y[0] + " " + "[" + str(numero_paquete) + "]" + "\t" + x[1]
													fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_sin_extension + os.environ["EXTENSION_INFO_ATTACKS"], "a")
													fichero_fusionado.write("%s" %info_attacks)
													fichero_fusionado.close()
											else:
												fichero_fusionado = open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_sin_extension + os.environ["EXTENSION_INFO_ATTACKS"], "a")
												fichero_fusionado.write("%s" %linea)
												fichero_fusionado.close()
									posicion = posicion + 1
						else:
							open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_sin_extension + os.environ["EXTENSION_INFO_ATTACKS"], "a").close()

						os.remove(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + dir_resultado.name + "/" + fichero_info_attacks_ordenado)
				posicion = 0

				#Escribimos cabecera
				num_clean_totales = sum(1 for i in open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04B-Clean" + "/" + fichero_sin_extension + os.environ["EXTENSION_CLEAN"], 'rb'))
				num_attacks_totales = sum(1 for i in open(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_sin_extension + os.environ["EXTENSION_ATTACKS"], 'rb'))

				IMPRIMIR1 = "---------------------- Statistics of URIs analyzed------------------------\n"
				IMPRIMIR2 = "[" + str(num_lineas_totales) +"] input, " + "[" + str(num_clean_totales) + "] clean, " + "[" + str(num_attacks_totales) + "] attacks\n"
				IMPRIMIR3 = "--------------------------- Analysis results -----------------------------\n"

				if os.path.getsize(os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_sin_extension + os.environ["EXTENSION_INFO_ATTACKS"]) > 0:
					fichero = os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_sin_extension + os.environ["EXTENSION_INFO_ATTACKS"]
					call_with_args = "sed -i '1i%s' '%s'" % (str(IMPRIMIR3), str(fichero))
					os.system(call_with_args)
					call_with_args = "sed -i '1i%s' '%s'" % (str(IMPRIMIR2), str(fichero))
					os.system(call_with_args)
					call_with_args = "sed -i '1i%s' '%s'" % (str(IMPRIMIR1), str(fichero))
					os.system(call_with_args)
				else:
					fichero = os.environ["SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS"] + os.environ["SUBDIR_REMOTO_RECOGIDA"] + "04A-Attacks" + "/" + fichero_sin_extension + os.environ["EXTENSION_INFO_ATTACKS"]
					call_with_args = "echo '%s' >> '%s'" % (str(IMPRIMIR1), str(fichero))
					os.system(call_with_args)
					call_with_args = "echo '%s' >> '%s'" % (str(IMPRIMIR2), str(fichero))
					os.system(call_with_args)
					call_with_args = "echo '%s' >> '%s'" % (str(IMPRIMIR3), str(fichero))
					os.system(call_with_args)
			progreso += 1
