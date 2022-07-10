#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}


clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea ELIMINAR la tarea \"${NOMBRE_TAREA}\" de los equipos \"${EQUIPOS_LT}\" con instancias \"${instancia}\"?" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

for i in ${EQUIPOS_LT}; do

	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

    printf "\n\n###### CERRANDO Sesiones de byoby ###########\n"

    # Lista de sesiones byobu:  byobu list-sessions
	for num_instancia in ${instancia}; do
		printf "\n%s\n" "Equipo ${PREFIJO_NOMBRE_EQUIPO}$i ${NOMBRE_TAREA}${num_instancia}...  "

		${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "byobu kill-session -t "${NOMBRE_TAREA}${num_instancia}_${SESION_BYOBU_MONITORIZA_SALIDA}""
		${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "byobu kill-session -t "${NOMBRE_TAREA}${num_instancia}""
		#Después de detener proceso en equipo remoto actualizamos script de estado
		estado=$(grep "${PREFIJO_NOMBRE_EQUIPO}$i ${NOMBRE_TAREA}${num_instancia}:" "${FILE_ESTADO}" | awk -F'\t' '{print $8}')
		if [ "${estado}" != "${FINALIZADA}" ]; then
			linea_a_sustituir=$(grep "${PREFIJO_NOMBRE_EQUIPO}$i ${NOMBRE_TAREA}${num_instancia}:" "${FILE_ESTADO}" | awk -F'\t' '{print $0}')
			linea_nueva=$(grep "${PREFIJO_NOMBRE_EQUIPO}$i ${NOMBRE_TAREA}${num_instancia}:" "${FILE_ESTADO}" | awk -v nuevo_estado="${INTERRUMPIDA}" -F'\t' 'BEGIN {OFS = FS} {$8=nuevo_estado;print}')
			sed -i "s#${linea_a_sustituir}#${linea_nueva}#g" "${FILE_ESTADO}"

			actualizacion=$(printf "Última actualización: %s" "$(date)")
			sed -i "s/^Última actualización.*/${actualizacion}/g" "${FILE_ESTADO}"
		fi
	done
done
printf "\n\n\n%s\n\n%s\n\n\n" "##############################################" "Puede usar el script de estado para comprobar el estado de los equipos"
