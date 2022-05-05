#!/bin/sh

# Cargar variables de configuracion
. ../config_interna.sh


# Crear copia para cada equipo
NUM_TOTAL_FICHEROS_REPARTIR="$(ls "${DIR_FICHEROS_REPARTIR}" | wc -l)"

# Calcular reparto
NUM_EQUIPOS="$(echo ${EQUIPOS_LT} | wc -w)"

SUELO="$((NUM_TOTAL_FICHEROS_REPARTIR/NUM_EQUIPOS))"

ULTIMO_EQUIPO="$( echo ${EQUIPOS_LT} | rev | cut -d" " -f1 | rev)"

# Comprobar si ha habido decimales
if [ "$((NUM_EQUIPOS*SUELO))" = "${NUM_TOTAL_FICHEROS_REPARTIR}" ]; then
    # Reparto exacto
    NUM_FICHEROS_POR_EQUIPO="${SUELO}"
    NUM_FICHEROS_ULTIMO_EQUIPO="${NUM_FICHEROS_POR_EQUIPO}"
    ULTIMO_DISTINTO="No"
else
    # Reparto no exacto => Techo (el ultimo equipo tendra menos ficheros)
    NUM_FICHEROS_POR_EQUIPO="$((SUELO+1))"
    NUM_FICHEROS_ULTIMO_EQUIPO="$((NUM_TOTAL_FICHEROS_REPARTIR-(NUM_EQUIPOS-1)*NUM_FICHEROS_POR_EQUIPO))"
    ULTIMO_DISTINTO="Si"
fi

RESUMEN_ULTIMO=""
[ "${ULTIMO_DISTINTO}" = "Si" ] && RESUMEN_ULTIMO="; ${NUM_FICHEROS_ULTIMO_EQUIPO} en ultimo ${PREFIJO_NOMBRE_EQUIPO}${ULTIMO_EQUIPO}"
RESUMEN_REPARTO="${NUM_TOTAL_FICHEROS_REPARTIR} ficheros (${NUM_FICHEROS_POR_EQUIPO}/equipo${RESUMEN_ULTIMO})"

clear
MENSAJE="###### Reparto AUTOMATICO (equitativo) de ficheros (Tarea \"${NOMBRE_TAREA}\"): ${RESUMEN_REPARTO}) ###########"
printf "\n\n%s\n" "${MENSAJE}"
printf "\nPREVIAMENTE, se clonara la estructura de directorios de la tarea (una carpeta por equipo remoto)\n"
printf "\n\n%s\n\n%s\n" "¿Seguro que desea (clonar y) repartir los ficheros de la Tarea \"${NOMBRE_TAREA}\" entre las carpetas de los equipos \"${EQUIPOS_LT}\"?." "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

eval "printf \"\n\" | . \"${SCRIPT_CLONAR_ESTRUCTURA}\" \"${EQUIPOS_LT}\""
[ "$(head -1 ${VAR_MEMORIA_SALIR})" = "1" ] && exit 1				# Paso de variable de hijo a padre

# Fichero Resumen Repartor
printf "%s\n\n" "${MENSAJE}" > "${FICHERO_REPARTO}"




# Pasar al siguiente equipo
pasar_siguiente_equipo()
{

    if [ "${contador_ficheros_pendientes_repartir_equipo_actual}" = "0" ]; then
	SIGUIENTE_EQUIPO="$(printf "%s" "${EQUIPOS_PENDIENTES_REPARTO}" | cut -d" " -f1)"
	EQUIPOS_PENDIENTES_REPARTO="$(printf "%s" "${EQUIPOS_PENDIENTES_REPARTO}" | cut -d" " -f2-)"
	# Comprobamos si equipo normal o ultimo
	if [ "${ULTIMO_DISTINTO}" = "Si" -a "${SIGUIENTE_EQUIPO}" = "${ULTIMO_EQUIPO}" ]; then
	    num_ficheros_repartir_equipo_actual="${NUM_FICHEROS_ULTIMO_EQUIPO}"
	else
	    num_ficheros_repartir_equipo_actual="${NUM_FICHEROS_POR_EQUIPO}"
	fi
	contador_ficheros_pendientes_repartir_equipo_actual="${num_ficheros_repartir_equipo_actual}"
	contador_ficheros_repartidos_equipo_actual=0
	LISTA_FICHEROS_EQUIPO_ACTUAL=""
	printf "\n"		# Para contadores pantalla en lineas separadas
    fi
}

# Generar Informe de Reparto
generar_informe()
{
    FICHERO_ACTUAL="$1"
    # Eliminar ruta
    FICHERO_ACTUAL="${FICHERO_ACTUAL##*/}"
    # Eliminar (primera) extension:
    FICHERO_ACTUAL="${FICHERO_ACTUAL%.*}"

    # En PRIMER fichero del equipo
    if [ "${contador_ficheros_repartidos_equipo_actual}" = "1" ]; then
	printf "%s\tFIN[ ]\t%s ficheros\t[%s]-" "${PREFIJO_NOMBRE_EQUIPO}${SIGUIENTE_EQUIPO}" "${num_ficheros_repartir_equipo_actual}" "${FICHERO_ACTUAL}" >> "${FICHERO_REPARTO}"
    fi

    # En TODOS
    LISTA_FICHEROS_EQUIPO_ACTUAL="${LISTA_FICHEROS_EQUIPO_ACTUAL}$(printf "[%s]" "${FICHERO_ACTUAL}")"

    # En ULTIMO fichero del equipo
    if [ "${contador_ficheros_repartidos_equipo_actual}" = "${num_ficheros_repartir_equipo_actual}" ]; then
	printf "[%s]\t%s\n" "${FICHERO_ACTUAL}" "${LISTA_FICHEROS_EQUIPO_ACTUAL}" >> "${FICHERO_REPARTO}"
    fi

    # Comprobar si sobran equipos
    if [ "${contador_ficheros_repartidos_total}" = "${NUM_TOTAL_FICHEROS_REPARTIR}" -a "${SIGUIENTE_EQUIPO}" != "${ULTIMO_EQUIPO}" ]; then
	printf "\n\n\nLos siguientes Equipos han quedado sin ficheros asignados:\n\n%s\n" "${EQUIPOS_PENDIENTES_REPARTO}"
	printf "\n\nSe aconseja eliminarlos de \"\${EQUIPOS_LT}\" (en cloud_tarea.conf.sh) antes de continuar!!!\n\n\n"
    fi
}



EQUIPOS_PENDIENTES_REPARTO="${EQUIPOS_LT}"
contador_ficheros_repartidos_total=0
contador_ficheros_pendientes_repartir_equipo_actual=0
pasar_siguiente_equipo
printf "\n\n###### Reparto de Ficheros a Analizar (tarea \"${NOMBRE_TAREA}\"): ###########\n"
for r in ${DIR_FICHEROS_REPARTIR}*; do

    # Repartir sus ficheros
    contador_ficheros_repartidos_equipo_actual="$((contador_ficheros_repartidos_equipo_actual+1))"

    # Imprimimos en pantalla el Nº URI que esta actualmente siendo analizado (Progreso)
    printf "\r                                          "
    printf "\rEquipo %s%s (fichero %s/%s)"  "${PREFIJO_NOMBRE_EQUIPO}" "${SIGUIENTE_EQUIPO}" "${contador_ficheros_repartidos_equipo_actual}"  "${num_ficheros_repartir_equipo_actual}"

    # Repartimos
    cp "${r}" "${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}${SIGUIENTE_EQUIPO}/${SUBDIR_TAREA_ENTRADA}"

    # Contabilizar
    contador_ficheros_pendientes_repartir_equipo_actual="$((contador_ficheros_pendientes_repartir_equipo_actual-1))"
    contador_ficheros_repartidos_total="$((contador_ficheros_repartidos_total+1))"

    # Generar Informe
    generar_informe "$r"

    # Pasar al siguiente equipo
    pasar_siguiente_equipo
done


printf "\n\n\n### Reparto terminado. ###\n\n"
printf "\n\nGenerado informe resumen del reparto de ficheros en: %s\n\n" "$(echo ${FICHERO_REPARTO} | rev | cut -d"/" -f1-2 | rev)"

