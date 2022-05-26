#!/bin/sh

# Script ejecutado en equipo remoto en el que lanzar la tarea
. ./cloud_config_interna.conf

#Obtenemos el número de ficheros de entrada asignado a este equipo
#num_ficheros_entrada=$(ls "${DIR_REMOTO_ENVIO_DESCOMP}${SUBDIR_TAREA_ENTRADA}" | wc -l)

#Obtenemos la IP y el puerto del cliente. Esto se realiza para abrir socket de escucha
#y recepcionar ACK del servidor
EQUIPO_CLIENTE=$(ls | grep .tar.gz | cut -d'-'  -f'1')
#if expr "${equipo_cliente}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
#	ip_equipo_cliente="${equipo_cliente}"
#else
#	ip_equipo_cliente=$(cat /etc/hosts | grep "${equipo_cliente}" | awk '{print $1}')
#fi

#Obtenemos la IP y el puerto del servido. Esto se realiza para abrir socket de envío
#de mensaje UDP al servidor
#if expr "${IP_SERVIDOR}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
#	ip_equipo_servidor=${IP_SERVIDOR}
#else
#	ip_equipo_servidor=$(cat /etc/hosts | grep "${IP_SERVIDOR}" | awk '{print $1}')
#fi

#Variable de control de estado de la tarea desplegada. Valor '0'-> En ejecución
FIN=0
#Ficheros procesados
FICHEROS_PROCESADOS=0

#Monitorizamos la llegada de ficheros a directorio '${DIR_REMOTO_ENTRADAS_FINALIZADAS}'
#Con la creación de un fichero disparamos el evento
inotifywait -q -m -e create --format %f "${DIR_REMOTO_ENTRADAS_FINALIZADAS}" |
while read ARCHIVO; do
	fichero_procesado="${ARCHIVO}"

	#Comprobamos estado de la tarea
	existe_proceso=$(byobu ls | grep "${NOMBRE_TAREA}:")
	printf "este es el proceso que en teoría sigue en ejecución: $existe_proceso"

	if [ "${existe_proceso}" = "" ]; then
		FIN=1
	fi

	#Antes de detener por 'x' segundos la ejecución comprobamos 
	if [ "${FIN}" -eq 0 -a "${PERIODO_ENTRE_RECOGIDAS}" -gt 0 ]; then
		sleep "${PERIODO_ENTRE_RECOGIDAS}"

		#Comprobamos después de la espera el valor de FIN
		existe_proceso=$(byobu ls | grep "${NOMBRE_TAREA}:")
		[ "${existe_proceso}" = "" ] && FIN=1
	fi
	
	#Al detectarse un nuevo fichero como finalizado añadimos uno
	FICHEROS_PROCESADOS=$((FICHEROS_PROCESADOS+1))
	#./"${FILE_SCRIPT_ENVIA_UDP}" "${ip_equipo_cliente}" "${PUERTO_ESCUCHA_CLIENTE}" "${ip_equipo_servidor}" "${PUERTO_ESCUCHA_SERVIDOR}" "${NOMBRE_TAREA}"
	if [ "${FIN}" -eq 1 -o "${NUM_FICHEROS_A_RECOGER}" -eq 0 -a "${PERIODO_ENTRE_RECOGIDAS}" -eq 0 -o "${NUM_FICHEROS_A_RECOGER}" -eq "${FICHEROS_PROCESADOS}" -o "${PERIODO_ENTRE_RECOGIDAS}" -gt 0 ]; then
		#Reseteamos el número de ficheros procesados para envío por número de ficheros
		FICHEROS_PROCESADOS=0
		./"${FILE_SCRIPT_ENVIA_UDP}" "${EQUIPO_CLIENTE}" "${EQUIPO_SERVIDOR}" "${PUERTO_ESCUCHA_SERVIDOR}" "${NOMBRE_TAREA}" "${FIN}" "${TIEMPO_ENTRE_REINTENTOS}" "${NUM_MAX_REINTENTOS}"
	fi
	#num_ficheros_procesados=$(ls "${DIR_REMOTO_ENTRADAS_FINALIZADAS}" | wc -l)
	#if [ "${num_ficheros_entrada}" -eq "${num_ficheros_procesados}" ]; then
		#Una vez hemos procesado los ficheros asignados, matamos la sesión.
	if [ "${FIN}" -eq 1 ]; then
		byobu kill-session -t "${NOMBRE_TAREA}_${SESION_BYOBU_MONITORIZA_SALIDA}"
		echo "fin de proceso de envío UDP"
	fi
done
