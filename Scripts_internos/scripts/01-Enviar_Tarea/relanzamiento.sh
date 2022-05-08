#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

# Comprobamos si tarea en ejecución
en_ejecucion=$(awk -v estado_tarea="${EJECUTANDOSE}" 'BEGIN{FS=OFS="\t"} $0 ~ estado_tarea {print $0}' "${FILE_ESTADO}")
if [ "${en_ejecucion}" != "" ]; then
	dialog --title "Tarea En ejecución" \
			--stdout \
			--backtitle "¡Atención!: se ha detectado que la tarea sigue en ejecución." \
			--yesno "¿Desea detenerla de todos los equipos y proseguir con un nuevo lanzamiento?." 0 0
	respuesta="$?" #0 afirmativa, 1 negativa
	if [ "${respuesta}" -eq 0 ]; then
		. "${SCRIPT_MATAR}"
		. "${SCRIPT_LIMPIAR_TAREA}"
		export RELANZAMIENTO="OK"
		return
	else
		dialog --title "Relanzamiento cancelado" \
				--msgbox "Para poder realizar el relanzamiento es necesario que la tarea no se encuentre en ejecución.\n\nSe sale..." 0 0
		exit 1
	fi
fi

#Una vez nos hemos asegurado que la tarea no se encuentra en ejecución
#continuamos con relanzamiento.

#Recogemos ficheros que se encuentren DISPONIBLES-INTERRUMPIDA

equipos=$(awk -v estado_equipo="${DISPONIBLE}" -v estado_tarea="${INTERRUMPIDA}" 'BEGIN{FS=OFS="\t"} $5==estado_equipo && $NF==estado_tarea {print $1}' ${FILE_ESTADO} | cut -d' ' -f'2' | cut -d':' -f'1')

if [ "${equipos}" != "" ]; then
	for equipo in ${equipos}; do
		equipo_sin_prefijo=$(printf "%s" "$equipo" | sed "s/${PREFIJO_NOMBRE_EQUIPO}//g")
		equipos_a_recoger="${equipos_a_recoger} ${equipo_sin_prefijo}"
	done
	equipos_a_recoger=$(printf "%s" "${equipos_a_recoger}" | sed "s/^ //g")

	#Recogemos de los equipos 'DISPONIBLE-INTERRUMPIDA'
	"${SCRIPT_RECOGER}" "${equipos_a_recoger}"
fi

#Comprobamos si con los ficheros recogidos ha finalizado la tarea
equipos_no_finalizados=$(awk -v tarea_ejecutandose="${EJECUTANDOSE}" -v tarea_interrumpida="${INTERRUMPIDA}" 'BEGIN{FS=OFS="\t"} $NF==tarea_ejecutandose || $NF==tarea_interrumpida {print $1}' ${FILE_ESTADO})
if [ "${equipos_no_finalizados}" != "" ]; then
	#Eliminamos los ficheros del directorio de entrada ya finalizados
	ficheros=$(awk -v recogido="si" 'BEGIN{FS=OFS="\t"} $3==recogido {print $1}' ${FILE_ESTADO_LISTADO_FICHEROS})
	for fichero_entrada_finalizado in ${ficheros}; do
		rm -f "${DIR_FICHEROS_REPARTIR}${fichero_entrada_finalizado}"
	done
	#Creamos directorio con nombre fecha y hora actual
	nombre_fecha=$(printf "%s" "$(date)" | sed 's/ /-/g')
	mkdir -p "${SUBDIR_LOCAL_RESULTADOS_ESTADO}${nombre_fecha}" 2>&1 1>/dev/null
	#guardamos registros de estado del lanzamiento anterior
	for fichero_estado in "${SUBDIR_LOCAL_RESULTADOS_ESTADO}"*
	do
		[ -f "$fichero_estado" ] && mv "$fichero_estado" "${SUBDIR_LOCAL_RESULTADOS_ESTADO}${nombre_fecha}"
	done
	printf "Se guardarán logs de estado anteriores en directorio: ${SUBDIR_LOCAL_RESULTADOS_ESTADO}${nombre_fecha}\n"
	printf "Procediendo a relanzamiento...\n"
	export RELANZAMIENTO="OK"
else
	dialog --title "Tarea finalizada" \
			--msgbox "Tarea finalizada: todos los ficheros han podido ser recuperados." 0 0
	exit 0
fi


