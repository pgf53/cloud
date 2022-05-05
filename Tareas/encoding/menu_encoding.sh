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
	while IFS= read -r line
	do
		equipo_indisponible=$(printf "%s" "${line}" | awk -v disponibilidad="${NO_DISPONIBLE}" -F"\t" 'BEGIN{FS=OFS="\t"} $0 ~ disponibilidad { print $1 }' | cut -d':' -f'1' | cut -d' ' -f'2')
		if [ "${equipo_indisponible}" != "" ]; then
			lista_equipos_indisponibles="${lista_equipos_indisponibles} ${equipo_indisponible}"
		else 
			equipo_disponible=$(printf "%s" "${line}" | cut -d':' -f'1' | cut -d' ' -f'2')
			lista_equipos_disponibles="${lista_equipos_disponibles} ${equipo_disponible}"
		fi
	done < "${FILE_ESTADO_EQUIPOS_INICIAL}"

	#eliminamos espacios iniciales
	lista_equipos_indisponibles=$(printf "%s" "${lista_equipos_indisponibles}" | sed 's/^ //g')
	lista_equipos_disponibles=$(printf "%s" "${lista_equipos_disponibles}" | sed 's/^ //g')

	#mostramos resultados al usuario
	if [ "${lista_equipos_indisponibles}" != "" -a "${lista_equipos_disponibles}" != "" ]; then
	dialog --title "Equipos NO disponibles" \
			--stdout \
			--backtitle "¡Atención!: los equipos \"${lista_equipos_indisponibles}\" no se encuentran disponibles" \
			--yesno "¿Desea continuar con la ejecución omitiendo los equipos no disponibles?." 0 0
	respuesta="$?" #0 afirmativa, 1 negativa
	#Eliminamos equipos no disponibles de cloud_tarea.conf
		if [ "${respuesta}" -eq 0 ]; then
			lista_equipos_disponibles_sin_prefijo=$(printf "%s" "${lista_equipos_disponibles}" | sed "s/${PREFIJO_NOMBRE_EQUIPO}//g")
			var_equipos=$(cat "${DIR_TAREA}cloud_${NOMBRE_TAREA}.conf" | grep -m 1 "EQUIPOS_LT=")
			sed -i "s/${var_equipos}/EQUIPOS_LT=\"${lista_equipos_disponibles_sin_prefijo}\"/g" "${DIR_TAREA}cloud_${NOMBRE_TAREA}.conf"
			#recargamos la configuración con los nuevos equipos.
			. ${CLOUD_CONFIG_INTERNA}
			echo "${EQUIPOS_LT}"
		else
			dialog --title "Información" \
				--msgbox "Configure los equipos para que estén disponibles o modifique la selección para reintentar. " 0 0
			exit 1
		fi
	elif [ "${lista_equipos_disponibles}" = "" ]; then
		dialog --title "Indisponibilidad de Equipos" \
				--msgbox "Ningún equipo se encuentra disponible para la ejecución de la tarea.\n\nSe sale..." 0 0
		exit 1
	else
		dialog --title "Disponibilidad de Equipos" \
				--msgbox "¡Todos los equipos seleccionados se encuentran disponibles!.\n\nPreparando Ejecución..." 0 0
	fi

}

#Obtenemos el directorio de la tarea y lo exportamos
ACTUAL="$(pwd)" && cd "$(dirname $0)" && export DIR_TAREA="$(pwd)/"
#Obtenemos el nombre de la tarea y lo exportamos
NOMBRE_TAREA=$(basename "${DIR_TAREA}")
#Exportamos la ruta del fichero de configuración de la tarea
#CLOUD_CONFIG_TAREA="${DIR_TAREA}cloud_${NOMBRE_TAREA}.conf"
#exportamos el directorio de 'cloud_config_interna.conf' y lo cargamos
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
					2 "Clonar directorios" \
					3 "Repartir ficheros" \
					4 "Enviar" \
					5 "Ejecutar" \
					6 "Consultar estado" \
					7 "Recoger resultados" \
					8 "Limpiar estado" \
					9 "Limpiar tarea")

	case ${respuesta} in
		1)
			#QUITAR!
			. "${SCRIPT_LIMPIAR_TAREA}"
			#1 Verificiamos la disponibilidad de los equipos seleccionados
			export INVOCACION="MENU_TAREA_LANZAMIENTO"
			. "${SCRIPT_ESTADO_EQUIPOS}"
			comprueba_lanzamiento
			#2 Clonamos Tarea para cada equipo
			. "${SCRIPT_CLONAR_ESTRUCTURA}"
			#3 Establecemos el reparto de los ficheros
			. "${SCRIPT_REPARTIR_MANUAL}"
			#4 Enviamos a equipos remotos
			. "${SCRIPT_ENVIO}"
			#5 Iniciamos lanzamiento/relanzamiento según proceda
			if [ -f "${FILE_ESTADO_LISTADO_FICHEROS}" -o -f "${FILE_ESTADO}" ]; then 
				. "${SCRIP_RELANZAMIENTO}"	#DEBE CONTEMPLAR LA DISPONIBILIDAD DE LOS EQUIPOS. REVISAR!!!!!
			else
				. "${SCRIPT_LANZAR}"
			fi
		;;
		2)	#Ejecutamos la tarea en equipo remoto
			. "${SCRIPT_CLONAR_ESTRUCTURA}"
			#cd ${DIR_SCRIPT_ENVIO}
			#. ${SCRIPT_EJECUCION} ${DIRCLOUD}cloud_tarea_${tarea}.conf
			#cd "${ACTUAL}"
		;;
		3)
			. "${SCRIPT_REPARTIR_MANUAL}"
		;;
		4)
			. "${SCRIPT_ENVIO}"
		;;
		5)
			if [ -f "${FILE_ESTADO_LISTADO_FICHEROS}" -o -f "${FILE_ESTADO}" ]; then 
				. "${SCRIP_RELANZAMIENTO}"
			else
				. "${SCRIPT_LANZAR}"
			fi
		;;
		6)
			. "${SCRIPT_ESTADO}"
		;;
		7)
			dialog --title "Instrucciones para la recogida" \
			--msgbox "Introduzca los equipos a recoger siguiendo el mismo formato que para EQUIPOS_LT.\n\nDejar en blanco para recoger en todos los equipos.\n\nPuede descartar recoger de todos los equipos menos uno si introduce -xx (siendo xx el equipo a omitir)" 0 0
			respuesta=$(dialog --title "Equipos de recogida" \
						--stdout \
						--inputbox "Seleccione los equipos de los que recoger los resultados:" 0 0)
			#Descartamos equipo en el que no queremos realizar la recogida
			guion=$(printf "%s" "${respuesta}" | grep '^-')
			if [ "${guion}" != "" ]; then
				equipo_descartado=$(printf "%s" "${respuesta}" | cut -d'-' -f'2')
				EQUIPOS_LT=$(printf "%s" "${EQUIPOS_LT}" | sed -e "s/${equipo_descartado}//g" -e "s/  / /g")
				preparar_lista_equipos
			else
				preparar_lista_equipos "$respuesta"
			fi
			. "${SCRIPT_RECOGER}" "${EQUIPOS_LT}"
			#. "${SCRIPT_RECOGER}" "05"	#Usado para no dar fallos en menú global. Parámetro sin uso.
		;;
		8)
			. "${SCRIPT_LIMPIAR_ESTADO}"
		;;
		9)
			. "${SCRIPT_LIMPIAR_TAREA}"
		;;
	esac
else
	. "${SCRIPT_RECOGER}" "$1"
fi


# Restaurar la carpeta de invocación
cd "${ACTUAL}"

