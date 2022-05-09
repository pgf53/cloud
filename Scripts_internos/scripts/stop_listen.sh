#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

proceso=$(basename "${SCRIPT_MENSAJE_UDP}")	#Proceso de escucha
existe_proceso=$(ps ax | pgrep "${proceso}")
if [ "${existe_proceso}" != "" ]; then
	pkill ${proceso} && printf "proceso de escucha finalizado.\n"
fi
