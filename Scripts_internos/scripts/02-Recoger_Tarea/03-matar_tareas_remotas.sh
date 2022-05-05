#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}


clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea ELIMINAR la tarea \"${NOMBRE_TAREA}\" de los equipos \"${EQUIPOS_LT}\"?" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
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
    printf "\n\n###### CERRANDO Sesiones de byoby ###########\n"

    # Lista de sesiones byobu:  byobu list-sessions
    printf "\n%s" "Equipo ${PREFIJO_NOMBRE_EQUIPO}$i...  "
    #${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "byobu kill-session -t 1"
    ${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "byobu kill-session -t "${NOMBRE_TAREA}_${SESION_BYOBU_MONITORIZA_SALIDA}""
	${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "byobu kill-session -t "${NOMBRE_TAREA}""
	#Después de detener proceso en equipo remoto actualizamos script de estado
	estado=$(grep "${PREFIJO_NOMBRE_EQUIPO}$i:" "${FILE_ESTADO}" | awk -F'\t' '{print $8}')
	if [ "${estado}" != "${FINALIZADA}" ]; then
		linea_a_sustituir=$(grep "${PREFIJO_NOMBRE_EQUIPO}$i:" "${FILE_ESTADO}" | awk -F'\t' '{print $0}')
		linea_nueva=$(grep "${PREFIJO_NOMBRE_EQUIPO}$i:" "${FILE_ESTADO}" | awk -v nuevo_estado="${INTERRUMPIDA}" -F'\t' '{$8=nuevo_estado;print}')
		sed -i "s#${linea_a_sustituir}#${linea_nueva}#g" "${FILE_ESTADO}"

		actualizacion=$(printf "Última actualización: %s" "$(date)")
		sed -i "s/^Última actualización.*/${actualizacion}/g" "${FILE_ESTADO}"
	fi
done
printf "\n\n\n%s\n\n%s\n\n\n" "##############################################" "Puede usar el script de estado para comprobar el estado de los equipos"
