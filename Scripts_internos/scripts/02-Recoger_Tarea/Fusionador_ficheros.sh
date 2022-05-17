#!/bin/sh

#Fusionador de framework
#Comprueba que se ha recibido fichero completo de resultados y los unifica
#Directorios 02-Log/ 03-Index/ 04A-Attacks/ 04B-Clean/

#funciones
imprimirCabecera ()
{

	#Imprimimos cabecera resumen de fichero "*-info.attacks"
	if [ -f "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04B-Clean/${FICHERO_SIN_EXTENSION}${EXTENSION_CLEAN}" ]; then
		num_clean=$(wc -l "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04B-Clean/${FICHERO_SIN_EXTENSION}${EXTENSION_CLEAN}" | cut -d' ' -f1)
	else
		num_clean=0
	fi

	if [ -f "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_ATTACKS}" ]; then
		num_ataques=$(wc -l "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_ATTACKS}" | cut -d' ' -f1)
	else
		num_ataques=0
	fi

	uris_totales=$((num_ataques+num_clean))
	IMPRIMIR1="---------------------- Statistics of URIs analyzed------------------------"
	IMPRIMIR2="[${uris_totales}] input, [${num_clean}] clean, [${num_ataques}] attacks"
	IMPRIMIR3="--------------------------- Analysis results -----------------------------"
	sed -i "1i$IMPRIMIR3"  "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_INFO_ATTACKS}"
	sed -i "1i$IMPRIMIR2"  "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_INFO_ATTACKS}"
	sed -i "1i$IMPRIMIR1"  "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_INFO_ATTACKS}"

	#Imprimimos cabecera en fichero "*-info_hide.attacks" si existe
	if [ -f "${OUT_ATTACKS_INFO_HIDE}" ]; then
		sed -i "1i$IMPRIMIR3"  "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_INFO_HIDE_ATTACKS}"
		sed -i "1i$IMPRIMIR2"  "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_INFO_HIDE_ATTACKS}"
		sed -i "1i$IMPRIMIR1"  "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_INFO_HIDE_ATTACKS}"
	fi
}

#Usada en modalidad básica para ordenar los packets de un fichero cortado.
ordena_paquetes()
{
	#Cogemos la columna del paquete (primera columna)
	cat "$1" | awk -F"\t" '{print $1}' | cut -d' ' -f'2' > ordena_paquetes.txt
	#Dejamos solo el número de paquete
	sed -i -e "s/\[//g" -e "s/\]//g" ordena_paquetes.txt
	#aplicamos algoritmo para determinar la posición de la uri en fichero original
	while IFS= read -r line
	do
		posicion_segun_fichero=$((${2}*${lineas_por_paquete}))
		posicion_real=$((${line}+${posicion_segun_fichero}))
		sed -i "s/^Packet \[${line}\]/Packet \[${posicion_real}\]/g" "$1"
	done < ordena_paquetes.txt
}

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

for i in "${DIR_FICHEROS_DIVIDIR}"* ; do
	FICHERO_SIN_EXTENSION=$(basename "${i}" | sed "s/${EXTENSION_ENTRADA}//g")
	NUMERO_FICHEROS_PRESENTES=$(ls "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}02-Log/" | grep "${FICHERO_SIN_EXTENSION}_" | wc -l)
	FICHEROS_PRESENTES=$(ls "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}02-Log/" | grep "${FICHERO_SIN_EXTENSION}_")
	#Si se han recibido todos los fragmentos:
	if [ "${NUMERO_FICHEROS_PRESENTES}" -eq "${DIVISIONES}" ]; then
		lineas_fichero_a_dividir=$(wc -l "${i}" | cut -d' ' -f'1')
		lineas_por_paquete=$(expr ${lineas_fichero_a_dividir} / ${DIVISIONES})
		
		#Fusionamos Logs
		for fichero in ${FICHEROS_PRESENTES}; do
			cat "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}02-Log/${fichero}" >> "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}02-Log/${FICHERO_SIN_EXTENSION}${EXTENSION_LOG}"
			rm -f "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}02-Log/${fichero}"
		done
		#Fusionamos Index
		FICHEROS_PRESENTES=$(ls "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}03-Index/" | grep "${FICHERO_SIN_EXTENSION}_")
		for fichero in ${FICHEROS_PRESENTES}; do
			cat "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}03-Index/${fichero}" >> "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}03-Index/${FICHERO_SIN_EXTENSION}${EXTENSION_INDEX}"
			rm -f "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}03-Index/${fichero}"
		done
		#Fusionamos Attacks
		FICHEROS_PRESENTES=$(ls "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/" | grep -v "${FICHERO_SIN_EXTENSION}_.*-info" | grep "${FICHERO_SIN_EXTENSION}_")
		for fichero in ${FICHEROS_PRESENTES}; do
			#Comprobamos el formato
			FORMATO_BASICO=$(sed "s/^Packet.*/fichero de tipo basico/g" "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}" | grep "fichero de tipo basico")
			#FORMATO_BASICO="patata"
			if [ "${FORMATO_BASICO}" != "" ]; then
				#Tenemos que establecer el número de paquete correctamente
				numero_fichero=$(printf "%s" ${fichero} | sed "s/.*_//g" | sed "s/\..*//g" | sed "s/^0//g")
				[ ${numero_fichero} -gt 0 ] && ordena_paquetes "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}" "${numero_fichero}"
			fi
			cat "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}" >> "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_ATTACKS}"
			rm -f "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}"
		done
		#Fusionamos Clean
		FICHEROS_PRESENTES=$(ls "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04B-Clean/" | grep "${FICHERO_SIN_EXTENSION}_")
		for fichero in ${FICHEROS_PRESENTES}; do
			cat "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04B-Clean/${fichero}" >> "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04B-Clean/${FICHERO_SIN_EXTENSION}${EXTENSION_CLEAN}"
			rm -f "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04B-Clean/${fichero}"
		done
		#Fusionamos -info.attacks
		FICHEROS_PRESENTES=$(ls "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/" | grep "${FICHERO_SIN_EXTENSION}_.*${EXTENSION_INFO_ATTACKS}")
		for fichero in ${FICHEROS_PRESENTES}; do
			LINEAS_INFO_ATTACKS=$(wc -l "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}" | cut -d' ' -f'1')
			tail -$((LINEAS_INFO_ATTACKS-3)) "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}" | tail -$((LINEAS_INFO_ATTACKS-3)) >> "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_INFO_ATTACKS}"
			rm -f "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}"
		done
		#Fusionamos -info_hide.attacks si existe
		FICHEROS_PRESENTES=$(ls "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/" | grep "${FICHERO_SIN_EXTENSION}_.*${EXTENSION_INFO_HIDE_ATTACKS}")
		if [ "${FICHEROS_PRESENTES}" != "" ]; then
			for fichero in ${FICHEROS_PRESENTES}; do
				LINEAS_INFO_ATTACKS=$(wc -l "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}" | cut -d' ' -f'1')
				tail -$((LINEAS_INFO_ATTACKS-3)) "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}" | tail -$((LINEAS_INFO_ATTACKS-3)) >> "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${FICHERO_SIN_EXTENSION}${EXTENSION_INFO_HIDE_ATTACKS}"
				rm -f "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}${SUBDIR_REMOTO_RECOGIDA}04A-Attacks/${fichero}"
			done
		fi
		
		#Establecemos cabeceras de -info
		imprimirCabecera
	fi
done
