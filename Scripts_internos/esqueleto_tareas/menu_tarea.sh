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
					1 "Clonar directorios" \
					2 "Repartir ficheros" \
					3 "Enviar" \
					4 "Ejecutar" \
					5 "Consultar estado" \
					6 "Recoger resultados" \
					7 "Limpiar estado" \
					8 "Limpiar tarea")

	case ${respuesta} in
		1)	#Ejecutamos la tarea en equipo remoto
			. "${SCRIPT_CLONAR_ESTRUCTURA}"
			#cd ${DIR_SCRIPT_ENVIO}
			#. ${SCRIPT_EJECUCION} ${DIRCLOUD}cloud_tarea_${tarea}.conf
			#cd "${ACTUAL}"
		;;
		2)
			. "${SCRIPT_REPARTIR_MANUAL}"
		;;
		3)
			. "${SCRIPT_ENVIO}"
		;;
		4)
			if [ -f "${FILE_ESTADO_LISTADO_FICHEROS}" -o -f "${FILE_ESTADO}" ]; then 
				. "${SCRIP_RELANZAMIENTO}"
			else
				. "${SCRIPT_LANZAR}"
			fi
		;;
		5)
			. "${SCRIPT_ESTADO}"
		;;
		6)
			respuesta=$(dialog --title "Equipos de recogida" \
						--stdout \
						--inputbox "Seleccione los equipos de los que recoger los resultados:" 0 0)
			preparar_lista_equipos "$respuesta"
			. "${SCRIPT_RECOGER}" "${EQUIPOS_LT}"
			#. "${SCRIPT_RECOGER}" "05"	#Usado para no dar fallos en menú global. Parámetro sin uso.
		;;
		7)
			. "${SCRIPT_LIMPIAR_ESTADO}"
		;;
		8)
			. "${SCRIPT_LIMPIAR_TAREA}"
		;;
	esac
else
	. "${SCRIPT_RECOGER}" "$1"
fi


# Restaurar la carpeta de invocación
cd "${ACTUAL}"

