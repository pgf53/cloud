#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea ELIMINAR las carpetas del cluster de la tarea \"${NOMBRE_TAREA}\" en los equipos \"${EQUIPOS_LT}\" con instancias \"${instancia}\"?" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

DIR_REMOTO_ORIGINAL=${DIR_REMOTO}
for i in ${EQUIPOS_LT}; do
	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

    printf "\n\n###### LIMPIANDO CARPETAS remotas ###########\n"
	for num_instancia in ${instancia}; do
		# Lista de sesiones byobu:  byobu list-sessions
		printf "\n%s\n" "Equipo ${PREFIJO_NOMBRE_EQUIPO}$i ${NOMBRE_TAREA}${num_instancia}...  "
		DIR_REMOTO=${DIR_REMOTO_ORIGINAL}
		DIR_REMOTO=$(printf "%s" ${DIR_REMOTO} | sed "s/${NOMBRE_TAREA}/${NOMBRE_TAREA}${num_instancia}/g")
		${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "rm -Rf ${DIR_REMOTO} 1>/dev/null 2>&1"
	done
done
printf "\n"
