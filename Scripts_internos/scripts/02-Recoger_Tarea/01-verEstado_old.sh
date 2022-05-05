#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

# Se encapsula en funciona para volcar salida a pantalla y fichero con "tee"
estado()
{
  clear
  printf "\nEstado tarea \"${NOMBRE_TAREA}\" en los equipos \"${EQUIPOS_LT}\":\nHora actual: %s\n\n" "$(date)"

  for i in ${EQUIPOS_LT}; do

    printf "%s:" "LT${i}"

    # ON/OFF
    arping -c 1 "${PREFIJO_NOMBRE_EQUIPO}$i" 1>/dev/null 2>&1
    [ "$?" = "0" ] && POWER="ON" || POWER="OFF"

    # SO:
    [ "${POWER}" = "ON" ] && SO="$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${CMD_SO_REMOTO}" 2>/dev/null)" || SO=" --- "

    # ESTADO TAREA:
    ESTADO_TAREA="$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${CMD_ESTADO_TAREA}" 2>/dev/null)"
    [ -z "${ESTADO_TAREA}" ] && ESTADO_TAREA="TERMINADA!"

    printf "\t%s\t(%s)\tTarea... %s\n" "${POWER}" "${SO}" "${ESTADO_TAREA}" 

    # Salidas extendidas
    if [ "${TIPO_ESTADO}" = "${ESTADO_CON_NUM_FICHEROS}" -o  "${TIPO_ESTADO}" = "${ESTADO_CON_LISTA_FICHEROS}" ]; then

	# Ficheros repartidos al equipo actual
	NUM_FICHEROS_REPARTIDOS_EQUIPOS="$(cat "${FICHERO_REPARTO}" | grep -e "^${PREFIJO_NOMBRE_EQUIPO}${i}" | cut -d"$(printf "\t")" -f3)"   #"
	FICHEROS_REPARTIDOS_EQUIPO="$(     cat "${FICHERO_REPARTO}" | grep -e "^${PREFIJO_NOMBRE_EQUIPO}${i}" | cut -d"$(printf "\t")" -f4)"        #"

	# Se lista la carpeta remota SIN subdirectorios
	FICHEROS_SALIDA_GENERADOS="$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${CMD_ESTADO_TAREA_FICHEROS}" 2>/dev/null)"
	NUM_FICHEROS_SALIDA_GENERADOS="$(printf "%s\n" "${FICHEROS_SALIDA_GENERADOS}" | wc -l)"

	printf "       Ficheros entrada REPARTIDOS:        \t%s\t%s\n" "${NUM_FICHEROS_REPARTIDOS_EQUIPOS}" "${FICHEROS_REPARTIDOS_EQUIPO}"
	printf "       Ficheros procesados (SALIDA remota):\t%s ficheros" "${NUM_FICHEROS_SALIDA_GENERADOS}"
	if [ "${TIPO_ESTADO}" = "${ESTADO_CON_LISTA_FICHEROS}" ]; then
	    # Imprimimos la lista de ficheros tabulada
	    printf "\tLista...\n%s" "$(printf "%s" "${FICHEROS_SALIDA_GENERADOS}" | sed 's/^/\t\t\t\t\t\t\t\t/')"

	fi
	printf "\n\n"
    fi

  done

  printf "\n\n###############################\n\n"
}

if [ "${TIPO_ESTADO}" = "${ESTADO_CON_NUM_FICHEROS}" ]; then
    FICHERO_SALIDA_ESTADO="${FILE_ESTADO_NUM_FICHEROS}"
    FICHERO_SALIDA_ESTADO_OLD="${FILE_ESTADO_NUM_FICHEROS_OLD}"
elif [ "${TIPO_ESTADO}" = "${ESTADO_CON_LISTA_FICHEROS}" ]; then
    FICHERO_SALIDA_ESTADO="${FILE_ESTADO_LISTA_FICHEROS}"
    FICHERO_SALIDA_ESTADO_OLD="${FILE_ESTADO_LISTA_FICHEROS_OLD}"
else
    FICHERO_SALIDA_ESTADO="${FILE_ESTADO}"
    FICHERO_SALIDA_ESTADO_OLD="${FILE_ESTADO_OLD}"
fi

rm -f "${FICHERO_SALIDA_ESTADO_OLD}"  1>/dev/null 2>&1
mv "${FICHERO_SALIDA_ESTADO}" "${FICHERO_SALIDA_ESTADO_OLD}"  1>/dev/null 2>&1
estado | tee "${FICHERO_SALIDA_ESTADO}"
# Borramos primera linea del fichero (caracteres extraños)
sed -i '1d' "${FICHERO_SALIDA_ESTADO}"


printf "\n\nResultados de Estado guardados en el fichero:\n\n%s\n\n" "$(echo ${FICHERO_SALIDA_ESTADO} | rev | cut -d"/" -f1-2 | rev)"
