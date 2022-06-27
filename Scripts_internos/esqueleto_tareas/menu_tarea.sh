#!/bin/sh

# Menu de control de la herramienta de Cloud MultiTarea

### Funciones
anadir_equipo_si_valido()
{
    EQUIP="$1"

    # Quitamos ceros iniciales
    EQUIP="${EQUIP#0}"

    # Debe ser un entero
    if [ -z "${EQUIP##*[!0-9-]*}" ]; then
	printf "\n\n### ERROR: Valor de equipo NO valido: %s\n" "${EQUIP}"
    else
	# Si esta entre 1-9 => Debe tener "0" delante "01-09"
	if [ "${EQUIP}" -ge 0 -a "${EQUIP}" -le 9 ]; then
	    if [ -z "${LISTA_PROCESADA}" ]; then
		LISTA_PROCESADA="0${EQUIP}"
	    else
		LISTA_PROCESADA="${LISTA_PROCESADA} 0${EQUIP}"
	    fi
	else
	    if [ -z "${LISTA_PROCESADA}" ]; then
		LISTA_PROCESADA="${EQUIP}"
	    else
		LISTA_PROCESADA="${LISTA_PROCESADA} ${EQUIP}"
	    fi
	fi
    fi
}

preparar_lista_equipos()
{
    [ "$1" != "" ] && EQUIPOS_LT="$1"

    LISTA_PROCESADA=""
    # Procesar rangos (e.g. "01-05" => "01 02 03 04 05")
    for e in ${EQUIPOS_LT}; do

	# Si tiene "-" (rango) => Procesarlo
	printf "%s" "${e}" | grep -F "-" 1>/dev/null 2>&1
	if [ "$?" = "0" ]; then
	    INICIO="$(printf "%s" "${e}" | cut -d"-" -f1)"
	    FIN="$(printf "%s" "${e}" | cut -d"-" -f2)"
	    for n in $(seq $INICIO $FIN); do
		anadir_equipo_si_valido "${n}"
	    done

	# SIN rango
	else
	    # Numero normal
	    anadir_equipo_si_valido "${e}"
	fi
    done

    EQUIPOS_LT="${LISTA_PROCESADA}"

	[ -z "${EQUIPOS_LT}" ] && { printf "\n\nNo se ha establecido ningun equipo (EQUIPOS_LT) de trabajo. Se sale...\n\n"; exit 1; }
}

#Comprueba la disponibilidad de
#los equipos en los instantes previos
#al lanzamiendo. Permite determinar automáticamente
#los equipos disponibles y ejecutar el análisis sobre estos.
comprueba_lanzamiento()
{
	equipos_disponibles=$(awk -v disponible="${DISPONIBLE}" 'BEGIN{FS=OFS="\t"} $5==disponible {print $1}' ${FILE_ESTADO_EQUIPOS_INICIAL} | cut -d':' -f'1' | cut -d' ' -f'2')
	equipos_no_disponibles=$(awk -v disponible="${DISPONIBLE}" 'BEGIN{FS=OFS="\t"} $5!="" && $5!=disponible {print $1}' ${FILE_ESTADO_EQUIPOS_INICIAL} | cut -d':' -f'1' | cut -d' ' -f'2')

	#mostramos resultados al usuario
	if [ "${equipos_no_disponibles}" != "" -a "${equipos_disponibles}" != "" ]; then
		for equipo in ${equipos_no_disponibles}; do
			lista_equipos_no_disponibles="${lista_equipos_no_disponibles} ${equipo}"
		done
		lista_equipos_no_disponibles=$(printf "%s" "${lista_equipos_no_disponibles}" | sed "s/^ //g")
		dialog --title "Equipos NO disponibles" \
				--stdout \
				--backtitle "¡Atención!: los equipos \"${lista_equipos_no_disponibles}\" no se encuentran disponibles" \
				--yesno "¿Desea continuar con la ejecución omitiendo los equipos no disponibles?." 0 0
		respuesta="$?" #0 afirmativa, 1 negativa
		#Eliminamos equipos no disponibles de cloud_tarea.conf
		if [ "${respuesta}" -eq 0 ]; then
			for equipo in ${equipos_disponibles}; do
				equipo_sin_prefijo=$(printf "%s" "$equipo" | sed "s/${PREFIJO_NOMBRE_EQUIPO}//g")
				equipos_a_ejecutar="${equipos_a_ejecutar} ${equipo_sin_prefijo}"
			done
			equipos_a_ejecutar=$(printf "%s" "${equipos_a_ejecutar}" | sed "s/^ //g")
			var_equipos=$(cat "${DIR_TAREA}cloud_${NOMBRE_TAREA}.conf" | grep -m 1 "EQUIPOS_LT=")
			sed -i "s/${var_equipos}/EQUIPOS_LT=\"${equipos_a_ejecutar}\"/g" "${DIR_TAREA}cloud_${NOMBRE_TAREA}.conf"
			#recargamos la configuración con los nuevos equipos.
			. ${CLOUD_CONFIG_INTERNA}
		else
			dialog --title "Información" \
				--msgbox "Configure los equipos para que estén disponibles o modifique la selección para reintentar. " 0 0
			exit 1
		fi
	elif [ "${equipos_disponibles}" = "" ]; then
		dialog --title "Indisponibilidad de Equipos" \
				--msgbox "Ningún equipo se encuentra disponible para la ejecución de la tarea.\n\nSe sale..." 0 0
		exit 1
	else
		dialog --title "Disponibilidad de Equipos" \
				--msgbox "¡Todos los equipos seleccionados se encuentran disponibles!.\n\nPreparando Ejecución..." 0 0
	fi

}

#Devuelve lista con equipos que han sido enviados
#a equipo remoto
equipos_usados_tarea()
{
	#Verificamos si el equipo se envió (tenía contenido)
	for equipo in ${EQUIPOS_LT}; do
		contenido=$(grep "${PREFIJO_NOMBRE_EQUIPO}${equipo} " ${FILE_ESTADO})
		if [ "${contenido}" = "" ]; then
			EQUIPOS_LT=$(printf "%s" "${EQUIPOS_LT}" | sed -e "s/${equipo}//g" -e "s/  / /g")
		fi
	done
	printf "%s" "${EQUIPOS_LT}"
}

#Realiza el lanzamiento completo de una tarea
lanzamiento()
{
	#1 Verificiamos la disponibilidad de los equipos seleccionados
	export INVOCACION="MENU_TAREA_LANZAMIENTO"
	. "${SCRIPT_ESTADO_EQUIPOS}"
	#comprueba_lanzamiento
	#2 Clonamos Tarea para cada equipo
	. "${SCRIPT_CLONAR_ESTRUCTURA}"
	#3 Dividimos ficheros presentes en directorio de división
	 [ ! -z "$(ls ${DIR_FICHEROS_DIVIDIR})" ] && . "${SCRIPT_DIVIDIR_FICHERO}"
	#4 Establecemos el reparto de los ficheros
	. "${SCRIPT_REPARTIR_MANUAL}"
	#5 Enviamos a equipos remotos
	. "${SCRIPT_ENVIO}"
	#6 Iniciamos lanzamiento/relanzamiento según proceda
	. "${SCRIPT_LANZAR}"
}

#Obtenemos el directorio de la tarea y lo exportamos
ACTUAL="$(pwd)" && cd "$(dirname $0)" && export DIR_TAREA="$(pwd)/"
#Obtenemos el nombre de la tarea y lo exportamos
NOMBRE_TAREA=$(basename "${DIR_TAREA}")
#Exportamos la ruta del fichero de configuración de la tarea
export CLOUD_CONFIG_INTERNA="./../../Scripts_internos/scripts/cloud_config_interna.conf"

#Cuando se invoca el estado desde el menú es de tipo 'consulta'
export TIPO_ESTADO="consulta"
#Cargamos en el menú el fichero de configuración interno
#que a su vez cargará el archivo de configuración de la tarea
. ${CLOUD_CONFIG_INTERNA}

######### Menu de invocacion (dialog)
#ls
if [ "$#" -eq 0 ]; then
	respuesta=$(dialog --title "Menú ${NOMBRE_TAREA}" \
					--stdout \
					--menu "Selecciona una opción:" 0 0 0 \
					1 "Lanzamiento Completo" \
					2 "Consultar estado" \
					3 "Recoger resultados" \
					4 "Matar tarea" \
					5 "Limpiar Directorios en equipos remotos" \
					6 "Limpiar tarea" \
					7 "Fusionar ficheros" \
					8 "Ejecutar o Enviar ficheros en los equipos remotos")

	case ${respuesta} in
		1)
			if [ -f "${FILE_ESTADO}" ]; then
				equipos_no_finalizados=$(awk -v tarea_ejecutandose="${EJECUTANDOSE}" -v tarea_interrumpida="${INTERRUMPIDA}" 'BEGIN{FS=OFS="\t"} $NF==tarea_ejecutandose || $NF==tarea_interrumpida {print $1}' ${FILE_ESTADO})
				if [ "${equipos_no_finalizados}" = "" ]; then
					dialog --title "Tarea Completada" \
							--stdout \
							--backtitle "¡Atención!: la tarea se detecta como completada." \
							--yesno "¿Desea eliminar los datos de la tarea, e iniciar un relanzamiento?." 0 0
					respuesta="$?" #0 afirmativa, 1 negativa
	#Eliminamos equipos no disponibles de cloud_tarea.conf
					if [ "${respuesta}" -eq 0 ]; then
						#Limpiamos datos de la tarea
						. "${SCRIPT_LIMPIAR_TAREA}"
						#Iniciamos el lanzamiento
						lanzamiento
					fi
				else
					#Actualizamos estado de la tarea
					. "${SCRIPT_ESTADO_CONSULTA}"
					#Invocamos Script de relanzamiento
					. "${SCRIP_RELANZAMIENTO}"
					[ "${RELANZAMIENTO}" = "OK" ] && lanzamiento
				fi
			else
				lanzamiento
			fi
		;;
		2)
			. "${SCRIPT_ESTADO_CONSULTA}"
		;;
		3)
			respuesta=$(dialog --title "Extraer Resultados" \
						--stdout \
						--inputbox "Introduzca los equipos en los que desee realizar la recogida.\n\nDejar en blanco para recoger los datos de todos los equipos.\n\nPara realizar la recogida de todos los equipos exceptuando uno, usar el prefijo \"-\" seguido del equipo a evitar (e.g. \"-03\").\n\nNota: para más información sobre el estado de los equipos consulte:\n\"${FILE_ESTADO}\"" 0 0)
			#Descartamos equipo en el que no queremos realizar la recogida
			guion=$(printf "%s" "${respuesta}" | grep '^-')
			if [ "${guion}" != "" ]; then
				equipo_descartado=$(printf "%s" "${respuesta}" | cut -d'-' -f'2')
				EQUIPOS_LT=$(printf "%s" "${EQUIPOS_LT}" | sed -e "s/${equipo_descartado}//g" -e "s/  / /g")
				preparar_lista_equipos
			else
				preparar_lista_equipos "$respuesta"
			fi

			respuesta=$(dialog --title "Recoger Instancia" \
						--stdout \
						--inputbox "Introduzca las instancias de la que desee recoger los resultados.\n\nDejar en blanco para recoger de todas las instancias del equipo" 0 0)
			if [ "${respuesta}" != "" ]; then
				for num_instancia in ${respuesta}; do
					num_instancia=$(printf "%s" "${num_instancia}" | sed "s/^0//g")
					instancia="${instancia} ${num_instancia}"
				done
			else
				for num_instancia in $(eval echo "{1..$N_INSTANCIA}"); do
					num_instancia=$(printf "%s" "${num_instancia}" | sed "s/^0//g")
					instancia="${instancia} ${num_instancia}"
				done
			fi

			export instancia=$(printf "%s" "${instancia}" | sed "s/^ //g")
			#Verificamos si el equipo se envió (tenía contenido)
			EQUIPOS_LT=$(equipos_usados_tarea)
			. "${SCRIPT_RECOGER}" "${EQUIPOS_LT}"
			#. "${SCRIPT_RECOGER}" "05"	#Usado para no dar fallos en menú global. Parámetro sin uso.
		;;
		4)
			respuesta=$(dialog --title "Detener Tarea" \
						--stdout \
						--inputbox "Introduzca los equipos en los que desee detener la tarea.\n\nDejar en blanco para detener la tarea de todos los equipos\n\nNota: para más información sobre el estado de los equipos consulte:\n\"${FILE_ESTADO}\"" 0 0)
			[ "${respuesta}" != "" ] && preparar_lista_equipos "${respuesta}"
			EQUIPOS_LT=$(equipos_usados_tarea)

			respuesta=$(dialog --title "Detener Instancia" \
						--stdout \
						--inputbox "Introduzca las instancias en las que desee detener la tarea.\n\nDejar en blanco para detener todas las instancias del equipo\n\nNota: para más información sobre el estado de los equipos consulte:\n\"${FILE_ESTADO}\"" 0 0)
			if [ "${respuesta}" != "" ]; then
				for num_instancia in ${respuesta}; do
					num_instancia=$(printf "%s" "${num_instancia}" | sed "s/^0//g")
					instancia="${instancia} ${num_instancia}"
				done
			else
				for num_instancia in $(eval echo "{1..$N_INSTANCIA}"); do
					num_instancia=$(printf "%s" "${num_instancia}" | sed "s/^0//g")
					instancia="${instancia} ${num_instancia}"
				done
			fi
			export instancia=$(printf "%s" "${instancia}" | sed "s/^ //g")

			#Verificamos si el equipo se envió (tenía contenido)
			. "${SCRIPT_MATAR}" "${EQUIPOS_LT}"
			. "${SCRIPT_ESTADO_CONSULTA}"
		;;
		5)
			respuesta=$(dialog --title "Limpiar Tarea Remota" \
						--stdout \
						--inputbox "Introduzca los equipos en los que desee limpiar la tarea.\n\nDejar en blanco para limpiar la tarea de todos los equipos\n\nNota: para más información sobre el estado de los equipos consulte:\n\"${FILE_ESTADO}\"" 0 0)
			[ "${respuesta}" != "" ] && preparar_lista_equipos "${respuesta}"

			respuesta=$(dialog --title "Limpiar Instancias" \
						--stdout \
						--inputbox "Introduzca las instancias en las que desee limpiar la tarea.\n\nDejar en blanco para limpiar todas las instancias del equipo\n\nNota: para más información sobre el estado de los equipos consulte:\n\"${FILE_ESTADO}\"" 0 0)
			if [ "${respuesta}" != "" ]; then
				for num_instancia in ${respuesta}; do
					num_instancia=$(printf "%s" "${num_instancia}" | sed "s/^0//g")
					instancia="${instancia} ${num_instancia}"
				done
			else
				for num_instancia in $(eval echo "{1..$N_INSTANCIA}"); do
					num_instancia=$(printf "%s" "${num_instancia}" | sed "s/^0//g")
					instancia="${instancia} ${num_instancia}"
				done
			fi
			export instancia=$(printf "%s" "${instancia}" | sed "s/^ //g")

			#Verificamos si el equipo se envió (tenía contenido)
			EQUIPOS_LT=$(equipos_usados_tarea)
			. "${SCRIPT_LIMPIAR}" "${EQUIPOS_LT}"
		;;
		6)
			. "${SCRIPT_LIMPIAR_TAREA}"
		;;
		7)
			#Cargo variables para Fusionador
			set -a; source "${CLOUD_CONFIG_INTERNA}"; set +a
			python3 "${SCRIPT_FUSIONAR_FICHERO}"
		;;
		8)
			respuesta=$(dialog --title "Submenú ${NOMBRE_TAREA}" \
				--stdout \
				--menu "Selecciona una opción:" 0 0 0 \
				1 "Ejecutar comando en los equipos remotos" \
				2 "Subir fichero" \
				3 "Descargar fichero")

			case ${respuesta} in
				1)
					respuesta2=$(dialog --title "Ejecutar comandos" \
							--stdout \
							--inputbox "Introduzca los equipos en los que desee Ejecutar los comandos.\n\nDejar en blanco para ejecutar en todos los equipos." 0 0)
					preparar_lista_equipos "$respuesta2"
					. "${SCRIPT_EJECUTAR_COMANDO}" "${EQUIPOS_LT}"
				;;
				2)
					respuesta2=$(dialog --title "Subir fichero" \
							--stdout \
							--inputbox "Introduzca los equipos en los que desee realizar la subida.\n\nDejar en blanco para subir a todos los equipos." 0 0)
					preparar_lista_equipos "$respuesta2"
					. "${SCRIPT_SUBIR_FICHERO}" "${EQUIPOS_LT}"
				;;
				3)
					respuesta2=$(dialog --title "Subir fichero" \
							--stdout \
							--inputbox "Introduzca los equipos en los que desee realizar la descarga.\n\nDejar en blanco para descargar de todos los equipos." 0 0)
					preparar_lista_equipos "$respuesta2"
					. "${SCRIPT_DESCARGAR_FICHERO}" "${EQUIPOS_LT}"
				;;
			esac
		;;
	esac
else
	export instancia="${2}"
	. "${SCRIPT_RECOGER}" "$1"
fi


# Restaurar la carpeta de invocación
cd "${ACTUAL}"
