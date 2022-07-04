#!/bin/sh

# Script ejecutado en equipo remoto en el que lanzar la tarea
. ./cloud_config_interna.conf


EQUIPO_CLIENTE=$(ls | grep .tar.gz | cut -d'-'  -f'1')

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
	#Hacemos un ciclo de espera para detectar si la tarea ha finalizado (e.g detención del servidor)
	sleep 0.2
	existe_proceso=$(byobu ls | grep "${NOMBRE_TAREA}:")

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
	if [ "${FIN}" -eq 1 -o "${NUM_FICHEROS_A_RECOGER}" -eq 0 -a "${PERIODO_ENTRE_RECOGIDAS}" -eq 0 -o "${NUM_FICHEROS_A_RECOGER}" -eq "${FICHEROS_PROCESADOS}" -o "${PERIODO_ENTRE_RECOGIDAS}" -gt 0 ]; then
		#Reseteamos el número de ficheros procesados para envío por número de ficheros
		FICHEROS_PROCESADOS=0
		./"${FILE_SCRIPT_ENVIA_UDP}" "${EQUIPO_CLIENTE}" "${EQUIPO_SERVIDOR}" "${PUERTO_ESCUCHA_SERVIDOR}" "${NOMBRE_TAREA}" "${FIN}" "${TIEMPO_ENTRE_REINTENTOS}" "${NUM_MAX_REINTENTOS}"
	fi

	#Una vez hemos procesado los ficheros asignados, matamos la sesión.
	if [ "${FIN}" -eq 1 ]; then
		byobu kill-session -t "${NOMBRE_TAREA}_${SESION_BYOBU_MONITORIZA_SALIDA}"
		echo "fin de proceso de envío UDP"
	fi
done
