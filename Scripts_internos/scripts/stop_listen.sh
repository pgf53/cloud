#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

proceso=$(basename "${SCRIPT_MENSAJE_UDP}")	#Proceso de escucha
existe_proceso=$(ps ax | pgrep "${proceso}")
if [ "${existe_proceso}" != "" ]; then
	pkill ${proceso} && printf "proceso de escucha finalizado.\n"
fi

#Debemos eliminar las sesiones byobu que monitorizan para enviar los mensajes UDP
#en los equipos remotos, para todas las tareas. También debe realizarse cuando
#detenemos la ejecución de una tarea en un equipo remoto.
