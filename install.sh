#!/bin/sh

EQUIPOS="28"
. Scripts_internos/scripts/cloud_config_interna.conf "${EQUIPOS}"

for i in ${EQUIPOS_LT}; do
	${SCP_COMANDO_CERTIFICADO} "TFM_install.sh"	"${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i://opt
	${SSH_COMANDO_CERTIFICADO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "cd /opt; ./TFM_install.sh" 
done



