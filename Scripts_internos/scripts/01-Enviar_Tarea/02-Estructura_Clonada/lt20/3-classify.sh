#!/bin/sh

#### Cargar configuracion
if [ -f "/opt/integrador/config.sh" ]; then
	. /opt/integrador/config.sh	#IMPORTANTE: La ruta del fichero de configuración debe establecerse a mano en cada uno de los scripts
else
	printf "no existe el fichero de configuración \n"
fi

### Funciones

# Busca la cadena indicada en la linea recibida
# Llamada:	buscarCadena   lineaAnalizada  cadenaBuscada
# Devuelve:	1 (encontrada), 0 (otro caso)
buscarCadena()
{
    lineaAnalizada="$1"
    cadenaBuscada="$2"

    printf "%s" "${lineaAnalizada}" | grep -i -s -F -- "${cadenaBuscada}" 2>&1 1>/dev/null
    # NOTA: Explicacion parametros del grep:
    # + "-i": Insensitive
    # + "-s": Silencioso (no imprime en pantalla)
    # + "-F": Desactiva expresiones regulares. Necesario para poder buscar cadenas como "[11/Jul/2019:12:05:46 +0200]"
    #         (igual para URLs con "?") y que los corchetes NO se interpreten como rangos de caracteres a buscar (sino como carecteres normales)
    # + "--": Desactiva la lectura de argumentos. Hace que el siguiente valor se interprete como la cadena a buscar.
    #         necesario para poder buscar cadenas como "--A-" y que el grep no la tome como un argumento.
    [ $? -eq 0 ] && return 1 || return 0		# Grep devuelve "0" si lo encuentra
}

# Comprueba si existe el patron de inicio en la cadena recibida. En caso afirmativo, extrae
# el fragmento de cadena ubicado entre los dos patrones dados
# Llamada: extraerIntervalo   cadenaAnalizar   patronInicio   patronFin
# Devuelve: Imprime (salida estándar) el fragmento extraido (o cadena vacia si no se encuentra)
extraerIntervalo()
{
    cadenaAnalizar="$1"
    patronInicio="$2"
    patronFin="$3"
    intervaloExtraido=""
    TMP1=""

    buscarCadena   "${cadenaAnalizar}"   "${patronInicio}"
    if [ $? -eq 1 ]; then
	TMP1="${cadenaAnalizar#*${patronInicio}}"		# Elimina texto anterior al primer patronInicio (prefijo)
	printf "%s" "${TMP1%%$patronFin*}"			# Elimina texto tras     el primer patronFin    (sufijo)
    fi
}


insertaAttacks()
{

	input_uri="$1"
	index_line="$2"
	uri_actual="$3"

	if [ ${URIS_FORMAT} = "basic" ]; then
		uri="${input_uri}"
		principio="Packet [${uri_actual}]	"
	elif [ ${URIS_FORMAT} = "extended" ]; then
		uri=$(echo "${input_uri}" |  cut -d'	' -f2)
		id=$(echo "${input_uri}" |  cut -d'	' -f1)
		principio="ID [${id}]	"
	fi

	index_result=$(echo "${index_line}" | awk -F "	" '{OFS="	"; $1=""; $2=""; print}')	#Eliminamos columnas de timestamp y de uri del index
	index_result=$(echo "${index_result}" | sed 's/		/	/')	#Ajustamos el formato
	echo "${principio}${uri}${index_result}" >> "${OUT_ATTACKS_INFO}"	#Escribimos resultado en fichero de "*-info.attacks"
	echo "${uri}" >> "${OUT_ATTACKS}"	#Escribimos la uri de ataque en fichero ".attacks
}


### Main()

FILE_URI="$1"	#fichero de uri de entrada
FILE_INDEX="$2"	#fichero de index de entrada
OUT_ATTACKS="${DIR_ROOT}/${DIROUT_ATTACKS}/$(basename ${FILE_INDEX%.*}).attacks"	#fichero de ataque generado
OUT_ATTACKS_INFO="${DIR_ROOT}/${DIROUT_ATTACKS}/$(basename ${FILE_INDEX%.*})-info.attacks"	#fichero resumen de ataques
OUT_ATTACKS_INFO_HIDE="${DIR_ROOT}/${DIROUT_ATTACKS}/$(basename ${FILE_INDEX%.*})-info_hide.attacks"	#fichero resumen de ataques
OUT_CLEAN="${DIR_ROOT}/${DIROUT_CLEAN}/$(basename ${FILE_INDEX%.*}).clean"	#fichero de limpias generado


#Patrones de búsqueda
START_CHARACTERS="Uri ["
END_CHARACTERS="]	"

uris_totales=$(wc -l "${FILE_URI}" | cut -d' ' -f1)

# Modo múltiple de lanzamiento
if [ "${LAUNCH_MODE}" = "multiple" ]; then
	uri_actual=1	#contador para saber número de uri en el fichero (usado en URIS_FORMAT = basic)
	cp "${FILE_INDEX}" index_tmp	#hacemos copia del ".index" La usaremos para agilizar la clasificación

	while IFS= read -r input_uri
	do

		#Imprimimos contadores
		printf "\r                                          "
		printf "\r(%s/%s)"  "${uri_actual}"  "${uris_totales}"
		
		# Obtenemos uri del fichero de entrada
		if [ ${URIS_FORMAT} = "basic" ]; then
			uri="${input_uri}"
		elif [ ${URIS_FORMAT} = "extended" ]; then
			uri=$(echo "${input_uri}" |  cut -d'	' -f2)
		fi
		if [ ! -s index_tmp ]; then #si está vacío
			echo "${uri}" >> "${OUT_CLEAN}"	#Imprimimos en limpia
		else
			while IFS= read -r index_line
			do
				# Obtenemos uri del fichero ".index"
				index_uri=$(extraerIntervalo "${index_line}" "${START_CHARACTERS}" "${END_CHARACTERS}")	#extraemos la uri de fichero index

				if [ "${LAUNCH_TYPE}" = "offline" ]; then
					if [ "${uri}" = "${index_uri}" ]; then
						insertaAttacks "${input_uri}" "${index_line}" "${uri_actual}"
						sed -i "1d" index_tmp
						break
					else 
						echo "${uri}" >> "${OUT_CLEAN}"	#Imprimimos en limpia
						break
					fi

				elif [ "${LAUNCH_TYPE}" = "online-local" -o "${LAUNCH_TYPE}" = "online-remoto" ]; then
					#echo "${uri}	${index_uri}"
					uri_encoded=$(echo "${uri}" | sed -e 's/#/%23/g' -e 's/ /%20/g')
					if [ "${uri_encoded}" = "${index_uri}" ]; then
						insertaAttacks "${input_uri}" "${index_line}" "${uri_actual}"
						sed -i "1d" index_tmp
						break
					else
						echo "${uri}" >> "${OUT_CLEAN}"	#Imprimimos en limpia
						break
					fi
				fi
			done < index_tmp
		fi
		uri_actual=$((uri_actual+1))	#actualizamos contador
	done < "${FILE_URI}"

	[ ! -s index_tmp ] && rm -f index_tmp

elif [ "${LAUNCH_MODE}" = "1to1" ]; then
	IN_URI="$3"	#uri de entrada a procesar
	uri_actual="$4"	#número de la uri en el fichero de entrada
	index_line=$(tail -1 "${FILE_INDEX}")
	index_uri=$(extraerIntervalo "${index_line}" "${START_CHARACTERS}" "${END_CHARACTERS}")	#extraemos la uri de fichero index
		
	if [ ${URIS_FORMAT} = "basic" ]; then
			uri="${IN_URI}"
	elif [ ${URIS_FORMAT} = "extended" ]; then
			uri=$(echo "${IN_URI}" |  cut -d'	' -f2)
	fi

	if [ "${LAUNCH_TYPE}" = "offline" ]; then
		if [ "${uri}" = "${index_uri}" ]; then
			insertaAttacks "${IN_URI}" "${index_line}" "${uri_actual}"
		else
			echo "${uri}" >> "${OUT_CLEAN}"	#Imprimimos en limpia
		fi
	elif [ "${LAUNCH_TYPE}" = "online-local" -o "${LAUNCH_TYPE}" = "online-remoto" ]; then
		uri_encoded=$(echo "${uri}" | sed -e 's/#/%23/g' -e 's/ /%20/g')
		if [ "${uri_encoded}" = "${index_uri}" ]; then
			insertaAttacks "${IN_URI}" "${index_line}" "${uri_actual}"
		else
			echo "${uri}" >> "${OUT_CLEAN}"	#Imprimimos en limpia
		fi
	fi
fi
