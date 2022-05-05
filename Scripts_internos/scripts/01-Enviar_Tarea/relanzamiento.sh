#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

#Funciones
#Encuentra el equipo al que pertenece un fichero de entrada
encuentra_equipos()
{
	#Leemos el fichero de reparto de ficheros, si encontramos linea cogemos equipo
	#si encontramos el fichero guardamos ese equipo y salimos
	while IFS= read -r line
	do
		patron=$(printf "%s" "${line}" | sed 's/^Equipo.*/Equipo/g')
		if [ "${patron}" = "Equipo" ];then
			equipo=$(printf "%s" "${line}" | cut -d' ' -f2 | sed 's/://g')
			#echo "este es el equipo dentro de encuentra_equipos: ${equipo}"
		fi
		if [ "${line}" = "${fichero}" ];then
			printf "%s" "${equipo}"
			break
		fi
	done < ${FICHERO_REPARTO}
}


###RECUPERACIÓN DE FICHEROS TERMINADOS PERO NO RECOGIDOS
nombre_fecha=$(printf "%s" "$(date)" | sed 's/ /-/g')
mkdir -p "${SUBDIR_LOCAL_RESULTADOS_ESTADO}${nombre_fecha}" 2>&1 1>/dev/null

#Comprobamos el estado e intentamos recuperar ficheros terminados no recogidos
ficheros_entrada=$(ls -1 ${DIR_FICHEROS_REPARTIR})
#Actualizamos estado consultando a los equipos
export TIPO_ESTADO="consulta"
. "${SCRIPT_ESTADO}"

#Buscamos equipos que contienen ficheros terminados y no recogidos
for fichero in ${ficheros_entrada}
do
	#equipos_relanzamiento=$(encuentra_equipos)
	#echo "$equipos_relanzamiento"
	terminado=$(awk -v pat="$fichero" -F"\t" '$0 ~ pat { print $2 }' "${FILE_ESTADO_LISTADO_FICHEROS}")
	recogido=$(awk -v pat="$fichero" -F"\t" '$0 ~ pat { print $3 }' "${FILE_ESTADO_LISTADO_FICHEROS}")
	if [ "${terminado}" != "${recogido}" ]; then
		#echo "${fichero}"
		equipo=$(encuentra_equipos)
		existe_equipo=$(printf "%s" "${listado_equipos}" | grep "${equipo}")
		[ "${existe_equipo}" = "" ] && listado_equipos="${listado_equipos} ${equipo}"
		#echo "${listado_equipos}"
		#printf "este es el listado de los equipos: %s\n" "$listado_equipos"
		#Enviamos recogida a esos equipos
	fi
	#Eliminamos espacio inicial del listado de equipos y prefijo para invocación de recogida
	listado_equipos=$(printf "%s" "${listado_equipos}" | sed -e 's/^ //g' -e "s/${PREFIJO_NOMBRE_EQUIPO}//g")
done
#Si existe algún equipo en el que recoger, invocamos script de recogida.
[ "${listado_equipos}" != "" ] && "${SCRIPT_RECOGER}" "${listado_equipos}"


#Determinamos si es necesario realizar relanzamiento tras recogida de ficheros
activar_recogida=0

for fichero in "${DIR_FICHEROS_REPARTIR}"*
do
	nombre_fichero=$(basename "${fichero}")
	recogido=$(awk -v pat="$nombre_fichero" -F"\t" '$0 ~ pat { print $3 }' "${FILE_ESTADO_LISTADO_FICHEROS}")
	if [ "${recogido}" = "no" ]; then
		activar_recogida=1
		break
	fi
done

if [ "${activar_recogida}" -eq 1 ]; then
	###RELANZAMIENTO USANDO LOS FICHEROS QUE NO HAN PODIDO RECUPERARSE
	#1º Establecer de alguna forma equipos disponibles

	#2º Determinar ficheros no procesados después de recogida, eliminando los ya procesados.
	for fichero in "${DIR_FICHEROS_REPARTIR}"*
	do
		nombre_fichero=$(basename "${fichero}")
		recogido=$(awk -v pat="$nombre_fichero" -F"\t" '$0 ~ pat { print $3 }' "${FILE_ESTADO_LISTADO_FICHEROS}")
		if [ "${recogido}" = "si" ]; then
			rm -f "${fichero}"
		fi
	done


	#3º Mover logs antiguos a directorio

	for file in "${SUBDIR_LOCAL_RESULTADOS_ESTADO}"*
	do
		[ -f "$file" ] && mv "$file" "${SUBDIR_LOCAL_RESULTADOS_ESTADO}${nombre_fecha}"
	done

	printf "Se guardarán logs de estado anteriores en directorio: ${SUBDIR_LOCAL_RESULTADOS_ESTADO}${nombre_fecha}\n"
	printf "Procediendo a relanzamiento...\n"

	#4º Iniciar nuevo lanzamiento

	#4.1 Clonamos directorios de la Tarea
	. "${SCRIPT_CLONAR_ESTRUCTURA}"

	#4.2 Repartimos ficheros de entrada NO procesados entre los
	#equipos seleccionados
	. "${SCRIPT_REPARTIR_MANUAL}"

	#4.3 Enviamos la Tarea a equipos seleccionados
	. "${SCRIPT_ENVIO}"

	#4.4 Realizamos el lanzamiento
	. "${SCRIPT_LANZAR}"
else 
	printf "Todos los ficheros de entrada han sido procesados y recogidos de los equipos remoto. Se sale...\n\n"
fi
