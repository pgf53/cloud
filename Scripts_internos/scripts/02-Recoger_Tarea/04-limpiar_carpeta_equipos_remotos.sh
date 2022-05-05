#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea ELIMINAR las carpetas del cluster de la tarea \"${NOMBRE_TAREA}\" en los equipos \"${EQUIPOS_LT}\"?" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

for i in ${EQUIPOS_LT}; do
	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

	#MODO_SSH=$(. "${SCRIPT_CHECK_SSH}" "${i}")
	#if [ "${MODO_SSH}" = "${SSH_CERTIFICADO}" ]; then
	#	SSH_COMANDO="${SSH_COMANDO_CERTIFICADO}"
	#	SCP_COMANDO="${SCP_COMANDO_CERTIFICADO}"
	#elif [ "${MODO_SSH}" = "${SSH_KEY}" ]; then
	#	SSH_COMANDO="${SSH_COMANDO_KEY}"
	#	SCP_COMANDO="${SCP_COMANDO_KEY}"
	#else
	#	echo "Modo SSH no detectado. Se sale..."
	#	exit 1
	#fi
    printf "\n\n###### LIMPIANDO CARPETAS remotas ###########\n"

    # Lista de sesiones byobu:  byobu list-sessions
    printf "\n%s" "Equipo ${PREFIJO_NOMBRE_EQUIPO}$i...  "
    ${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "rm -Rf ${DIR_REMOTO} 1>/dev/null 2>&1"
done
printf "\n"
