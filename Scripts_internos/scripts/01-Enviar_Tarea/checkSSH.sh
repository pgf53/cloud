#!/bin/sh

. ${CLOUD_CONFIG_INTERNA}

#Recibe como argumento un equipo devuelve
#el método SSH de acceso para ese equipo
#La consulta se realiza en estado_equipos-inicial.txt
EQUIPO="$1"
MODO_SSH=$(grep "${PREFIJO_NOMBRE_EQUIPO}${EQUIPO}" "${FILE_ESTADO_EQUIPOS_INICIAL}" | grep "${SSH_CERTIFICADO}")
[ "${MODO_SSH}" = "" ] && MODO_SSH="${SSH_KEY}" || MODO_SSH="${SSH_CERTIFICADO}"
#printf "%s" "${MODO_SSH}"
if [ "${MODO_SSH}" = "${SSH_CERTIFICADO}" ]; then
	export SSH_COMANDO="${SSH_COMANDO_CERTIFICADO}"
	export SCP_COMANDO="${SCP_COMANDO_CERTIFICADO}"
elif [ "${MODO_SSH}" = "${SSH_KEY}" ]; then
	export SSH_COMANDO="${SSH_COMANDO_KEY}"
	export SCP_COMANDO="${SCP_COMANDO_KEY}"
else
	echo "Modo SSH no detectado. Se sale..."
	exit 1
fi
