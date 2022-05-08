#!/bin/sh

#### Cargar configuracion
. ./framework_config_interna.sh
. ./framework_config.sh

#Obtenemos nombre de equipo
nombre_equipo=$(ls ./.. | grep .tar.gz | cut -d'-' -f1)
#Obtenemos el nombre de la tarea
nombre_tarea="$1"
#Obtenemos número total de ficheros a analizar en el equipo
ficheros_totales=$(ls "${DIR_ROOT}/${DIRIN_URI}/" | wc -l)
#Obtenemos progreso actual consultando la existencia de ficheros en la salida
progreso=$(ls "${DIR_ROOT}/${DIROUT_CLEAN}/" | wc -l)

#Listamos sesiones byobu en ejecución 
byobu ls | cut -d':' -f1 > /dev/shm/lista_byobu.txt

#Comprobamos si la tarea sigue en ejecución
while IFS= read -r tarea
do
	if [ "${tarea}" = "${nombre_tarea}" ]; then
		estado="En progreso..."
		break
	else
		estado="Listo"
	fi
done <  /dev/shm/lista_byobu.txt

#Borramos listado
rm -f /dev/shm/lista_byobu.txt

#Generamos fichero resumen de estado
printf "%s" "Equipo ${nombre_equipo}: ${progreso}/${ficheros_totales} ficheros analizados.	${estado}" > "${DIR_ROOT}/${RESULTADOS_CLOUD}_${nombre_equipo}.txt"

#Enviamos fichero resumen
if [ "${SSH_PASS}" = "yes" ]; then
	sshpass -p "${PASS_CLOUD}" scp "${DIR_ROOT}/${RESULTADOS_CLOUD}_${nombre_equipo}.txt" "${USER_CLOUD}"@"${SOURCE_DEVICE}":"${DIR_CLOUD}"
elif [ "${SSH_PASS}" = "no" ]; then
	scp "${DIR_ROOT}/${RESULTADOS_CLOUD}_${nombre_equipo}.txt" "${USER_CLOUD}"@"${SOURCE_DEVICE}":"${DIR_CLOUD}"
fi
