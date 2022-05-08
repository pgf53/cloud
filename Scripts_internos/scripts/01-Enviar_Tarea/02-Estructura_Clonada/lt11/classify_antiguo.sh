#!/bin/sh

#carga de fichero de configuración
. ./config.sh

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

insertaAttacks1to1()
{

	uri_actual="$1"
	index_line="$2"
	IN_URI="$3"

	if [ ${URIS_FORMAT} = "basic" ]; then 
		packet="Packet [${uri_actual}]"
		index_result=$(echo "${index_line}" | awk -F "	" '{OFS="	"; $1=""; $2=""; print}')	#Eliminamos columnas de timestamp y de uri del index
		index_result=$(echo "${index_result}" | sed 's/		/	/')	#Ajustamos el formato
		printf "%s\t%s%s"   "${packet}"   "${IN_URI}"   "${index_result}" >> "${OUT_ATTACKS_INFO}"
		printf \\n															>> "${OUT_ATTACKS_INFO}"
		echo "${IN_URI}" >> "${OUT_ATTACKS}"
	elif [ ${URIS_FORMAT} = "extended" ]; then
		id=$(echo "${IN_URI}" | cut -d'	' -f1)	#cogemos el id (primer campo de fichero de entrada)
		id="ID [${id}]"
		uri=$(echo "${IN_URI}" | cut -d'	' -f2)	#cogemos la uri (segundo campo de fichero de entrada)
		index_result=$(echo "${index_line}" | awk -F "	" '{OFS="	"; $1=""; $2=""; print}')	#Eliminamos columnas de timestamp y de uri del index
		index_result=$(echo "${index_result}" | sed 's/		/	/')	#Ajustamos el formato
		printf "%s\t%s%s"   "${id}"   "${uri}"   "${index_result}" >> "${OUT_ATTACKS_INFO}"
		printf \\n							 >> "${OUT_ATTACKS_INFO}"
		echo "${uri}" >> "${OUT_ATTACKS}"
	fi
}

insertaClean1to1()
{

	IN_URI="$1"

	if [ ${URIS_FORMAT} = "basic" ]; then
		echo "${IN_URI}" >> "${OUT_CLEAN}"
		elif [ ${URIS_FORMAT} = "extended" ]; then 
		uri=$(echo "${IN_URI}" | cut -d'	' -f2)	#cogemos la uri (segundo campo de fichero de entrada)
		echo "${uri}" >> "${OUT_CLEAN}"
	fi
}


insertaAttacksMultiple()
{

	analysis_file="$1"
	index_line="$2"

	if [ "${LAUNCH_TYPE}" = "offline" ]; then 
		uri_original=$(echo "${analysis_file}" | cut -d'	' -f2)	#extraemos URI_original
		index_result=$(echo "${index_line}" | awk -F "	" '{OFS="	"; $1=""; $2=""; print}')	#Eliminamos columnas de timestamp y de uri del index
		index_result=$(echo "${index_result}" | sed 's/		/	/')	#Ajustamos el formato
		echo "${analysis_file}${index_result}" >> "${OUT_ATTACKS_INFO}"	#Escribimos resultado en fichero de "*-info.attacks"
		echo "${uri_original}" >> "${OUT_ATTACKS}"	#Escribimos la uri de ataque en fichero ".attacks
	elif [ "${LAUNCH_TYPE}" = "online-local" -o "${LAUNCH_TYPE}" = "online-remoto" ]; then 
		uri_original="$3"
		principio=$(echo "${analysis_file}" | cut -d'	' -f1,2)	#extraemos Packet/ID	URI_original
		index_result=$(echo "${index_line}" | awk -F "	" '{OFS="	"; $1=""; $2=""; print}')	#Eliminamos columnas de timestamp y de uri del index
		index_result=$(echo "${index_result}" | sed 's/		/	/')	#Ajustamos el formato
		echo "${principio}${index_result}" >> "${OUT_ATTACKS_INFO}"	#Escribimos resultado en fichero de "*-info.attacks"
		echo "${uri_original}" >> "${OUT_ATTACKS}"	#Escribimos la uri de ataque en fichero ".attacks"
	fi

}


### Main()

FILE_INDEX="$2"	#fichero de index de entrada
FILE_ACCESS="$3"	#fichero de access_log de entrada
OUT_ATTACKS="${DIR_ROOT}/${DIROUT_ATTACKS}/$(basename ${FILE_INDEX%.*}).attacks"	#fichero de ataque generado
OUT_ATTACKS_INFO="${DIR_ROOT}/${DIROUT_ATTACKS}/$(basename ${FILE_INDEX%.*})-info.attacks"	#fichero resumen de ataques
OUT_ATTACKS_INFO_HIDE="${DIR_ROOT}/${DIROUT_ATTACKS}/$(basename ${FILE_INDEX%.*})-info_hide.attacks"	#fichero resumen de ataques
OUT_CLEAN="${DIR_ROOT}/${DIROUT_CLEAN}/$(basename ${FILE_INDEX%.*}).clean"	#fichero de limpias generado

#Patrones de búsqueda
START_CHARACTERS="Uri ["
END_CHARACTERS="]	"

if [ ! "${URIS_FORMAT}" = "basic" -a ! "${URIS_FORMAT}" = "extended" ]; then 
	printf "\nURIS_FORMAT inválido. Las opciones soportadas son \"basic\" o \"extended\". Se sale...\n"
	exit 1
fi

if [ "${LAUNCH_MODE}" = "1to1" ]; then
	IN_URI="$1"	#linea a analizar de fichero de entrada original
	uri_actual="$4"	#número de uri actual del fichero de entrada

	index_line=$(tail -1 "${FILE_INDEX}")	#tomamos última línea de index registrada
	index_uri=$(extraerIntervalo "${index_line}" "${START_CHARACTERS}" "${END_CHARACTERS}")	#extraemos la uri de fichero index
	if [ "${LAUNCH_TYPE}" = "online-local" -o "${LAUNCH_TYPE}" = "online-remoto" ]; then
		uri_log=$(tail -1 "${FILE_ACCESS}" | awk '{print $7}')	#tomamos la última uri registrada en el access_log
		#uri_log=$(cat "${FILE_ACCESS}" | awk '{print $7}')	#tomamos la última uri registrada en el access_log
		#uri_log=$(echo "${uri_log}" | sed 's/\\"/"/g')	#el access_log sustituye '"' por '\"'  por lo que invertimos este cambios
		uri_log=$(echo "${uri_log}" | sed -e 's/\\"/"/g' -e 's/\\\\/\\/g')	#el access_log sustituye '"' por '\"', '\' por '\\','–' por \xe2\x80\x93 por lo que invertimos estos cambios
		if [ "${uri_log}" = "${index_uri}" ]; then
			insertaAttacks1to1 "${uri_actual}" "${index_line}" "${IN_URI}"
		else
			insertaClean1to1 "${IN_URI}"
		fi
	elif [ "${LAUNCH_TYPE}" = "offline" ]; then
		if [ ${URIS_FORMAT} = "basic" ]; then
			uri="${IN_URI}"
		elif [ ${URIS_FORMAT} = "extended" ]; then
			uri=$(echo "${IN_URI}" |  cut -d'	' -f2)
		fi
		index_uri=$(echo "${index_uri}" |  sed 's/%5C/\\/g')	#Deshacemos codificación
		if [ "${index_uri}" = "${uri}" ]; then
			insertaAttacks1to1 "${uri_actual}" "${index_line}" "${IN_URI}"
		else
			insertaClean1to1 "${IN_URI}"
		fi
	fi

elif [ "${LAUNCH_MODE}" = "multiple" ]; then
	FILE_URI="$1"	#fichero de uri de entrada
	uri_actual=1	#contador para saber número de uri en el fichero (usado en URIS_FORMAT = basic)

	#Cambiar ruta a /dev/shm/ en formato 1-1
	clasificador="/tmp/clasificador.txt"	#fichero temporal usado en la creación de fichero de asociación.
											#El formato de este fichero es: packet_number/id	uri_original
	uri_log="/tmp/uri_log.txt"	#fichero temporal usado en la creación de fichero de asociación. 
								#Toma la uri escrita en fichero "access_log"
	asocia="/tmp/asocia.txt"	#fichero que asocia las uris del ".index" con las del fichero de entrada. 
								#Formato: Packet/ID	URI_original	URI_access_log


	uris_totales=$(wc -l "${FILE_URI}" | cut -d' ' -f1)

	while IFS= read -r input	#Si el formato es "basico" "input=uri lanzada".
	do
		if [ ${URIS_FORMAT} = "basic" ]; then
			packet="Packet [${uri_actual}]"
			printf "%s\t%s"   "${packet}"   "${input}" >> "${clasificador}"
			printf \\n									>> "${clasificador}"
		elif [ ${URIS_FORMAT} = "extended" ]; then
			id=$(echo "${input}" | cut -d'	' -f1)
			id="ID [${id}]"
			uri=$(echo "${input}" | cut -d'	' -f2)
			printf "%s\t%s"   "${id}"   "${uri}" >> "${clasificador}"
			printf \\n									>> "${clasificador}"
		fi
		uri_actual=$((uri_actual+1))	#Incrementamos contador de lectura
	done < "${FILE_URI}"

	if [ "${LAUNCH_TYPE}" = "online-local" -o "${LAUNCH_TYPE}" = "online-remoto" ]; then
		cat "${FILE_ACCESS}" | awk '{print $7}' >> "${uri_log}"	#tomamos las uris del access_log
		#sed -i 's/\\"/"/g' "${uri_log}"	#el access_log sustituye '"' por '\"', por lo que invertimos ese cambio 
		sed -i -e 's/\\"/"/g' -e 's/\\\\/\\/g' "${uri_log}"	#el access_log sustituye '"' por '\"' y '\' por '\\'  por lo que invertimos estos cambios
		paste "${clasificador}" "${uri_log}" >> "${asocia}"	#creamos fichero de asociación de uris de entrada con las recibidas en el servidor
		rm -f "${clasificador}" "${uri_log}"	#una vez creado el fichero de asociación, eliminamos los anteriores

		uri_actual=1
		while IFS= read -r index_line
		do
			index_uri=$(extraerIntervalo "${index_line}" "${START_CHARACTERS}" "${END_CHARACTERS}")	#extraemos la uri de fichero index
			while IFS= read -r uri_asocia
			do
				printf "\r                                          "
				printf "\r(%s/%s)"  "${uri_actual}"  "${uris_totales}"
				uri_actual=$((uri_actual+1))
				uri_server=$(echo "${uri_asocia}" | cut -d'	' -f3)	#extraemos la uri registrada en el access_log
				if [ "${index_uri}" = "${uri_server}" ]; then
					insertaAttacksMultiple "${uri_asocia}" "${index_line}"
					sed -i "1d" "${asocia}"	#eliminamos linea procesada
					break
				else
					echo "${uri_asocia}" | cut -d'	' -f2 >> "${OUT_CLEAN}"	#escribimos la uri limpia en fichero "*.clean"
					sed -i "1d" "${asocia}"	#eliminamos linea procesada
				fi
			done < "${asocia}"
		done < "${FILE_INDEX}"

		rm -f "${asocia}" "${FILE_ACCESS}"	#eliminamos fichero de asociación y de access una vez hemos finalizado la clasificación

	elif [ "${LAUNCH_TYPE}" = "offline" ]; then
		uri_actual=1
		while IFS= read -r index_line
		do
			index_uri=$(extraerIntervalo "${index_line}" "${START_CHARACTERS}" "${END_CHARACTERS}")	#extraemos la uri de fichero index
			index_uri=$(echo "${index_uri}" |  sed 's/%5C/\\/g')	#Deshacemos codificación
			while IFS= read -r clasificador_line
			do
				printf "\r                                          "
				printf "\r(%s/%s)"  "${uri_actual}"  "${uris_totales}"
				uri_actual=$((uri_actual+1))
				uri_original=$(echo "${clasificador_line}" | cut -d'	' -f2)	#extraemos URI_original
				if [ "${index_uri}" = "${uri_original}" ]; then
					insertaAttacksMultiple "${clasificador_line}" "${index_line}" "${uri_original}"
					sed -i "1d" "${clasificador}"	#eliminamos linea procesada
					break 
				else 
					echo "${uri_original}" >> "${OUT_CLEAN}"	#escribimos la uri limpia en fichero "*.clean"
					sed -i "1d" "${clasificador}"	#eliminamos linea procesada
				fi
			done < "${clasificador}"
		done < "${FILE_INDEX}"
		rm -f "${clasificador}" "${FILE_ACCESS}"	#eliminamos fichero de clasificación y de access una vez hemos finalizado
	fi

	#si "HIDE_COLUMMNS" = "yes" eliminamos columnas opcionales
	COLUMNS=$(echo ${OPTIONAL_COLUMNS} | tr " " ",")
	if [ "${HIDE_COLUMNS}" = "yes" ]; then
		cut --complement -d'	' -f${COLUMNS} "${OUT_ATTACKS_INFO}" >> "${OUT_ATTACKS_INFO_HIDE}"
	fi

	#Imprimimos cabecera resumen de fichero "*-info.attacks"
	num_clean=$(wc -l "${OUT_CLEAN}" | cut -d' ' -f1)
	num_ataques=$(wc -l "${OUT_ATTACKS}" | cut -d' ' -f1)
	IMPRIMIR1="---------------------- Statistics of URIs analyzed------------------------"
	IMPRIMIR2="[${uris_totales}] input, [${num_clean}] clean, [${num_ataques}] attacks"
	IMPRIMIR3="--------------------------- Analysis results -----------------------------"
	sed -i "1i$IMPRIMIR3"  "${OUT_ATTACKS_INFO}"
	sed -i "1i$IMPRIMIR2"  "${OUT_ATTACKS_INFO}"
	sed -i "1i$IMPRIMIR1"  "${OUT_ATTACKS_INFO}"

	#Imprimimos cabecera en fichero "*-info_hide.attacks" si existe
	if [ -f "${OUT_ATTACKS_INFO_HIDE}" ]; then
		sed -i "1i$IMPRIMIR3"  "${OUT_ATTACKS_INFO_HIDE}"
		sed -i "1i$IMPRIMIR2"  "${OUT_ATTACKS_INFO_HIDE}"
		sed -i "1i$IMPRIMIR1"  "${OUT_ATTACKS_INFO_HIDE}"
	fi
fi
