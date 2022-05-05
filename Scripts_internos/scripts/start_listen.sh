#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}


#Invocado desde menú global
export PREFIJO_NOMBRE_EQUIPO
proceso=$(basename "${SCRIPT_MENSAJE_UDP}")	#Proceso de escucha
existe_proceso=$(ps ax | pgrep "${proceso}")
if [ "${existe_proceso}" = "" ]; then
	"${SCRIPT_MENSAJE_UDP}" "${EQUIPO_SERVIDOR}" "${PUERTO_ESCUCHA_SERVIDOR}" "${DIR_TAREAS}" &
	[ "$?" -eq 0 ] && printf "Proceso de escucha activado en segundo plano\n"
fi
