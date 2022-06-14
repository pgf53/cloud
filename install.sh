#!/bin/sh

EQUIPOS="02 03 05-15 17-28"
. Scripts_internos/scripts/cloud_config_interna.conf "${EQUIPOS}"

for i in ${EQUIPOS_LT}; do
	${SCP_COMANDO_KEY} "install_nemesida.sh"	"${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i://opt
	${SSH_COMANDO_KEY} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "cd /opt; ./install_nemesida.sh" 
done



