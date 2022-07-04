#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}


#Divide los ficheros de un directorio de  entrada en tantos fragmentos
#como se especifiquen y los envía al directorio de reparto

DIR_TMP="/opt/ficheros_divididos/"	#No en memoria, se trabaja con ficheros grandes.
mkdir -p "${DIR_TMP}"

for i in "${DIR_FICHEROS_DIVIDIR}"* ; do
	if [ ! -f "${i}" ]; then
		printf "No existe el fichero de entrada a dividir. Se sale...\n"
		exit 1 
	fi

	LINEAS_FICHERO_ENTRADA=$(wc -l "${i}" | cut -d' ' -f'1')
	if [ "${DIVISIONES}" -gt "${LINEAS_FICHERO_ENTRADA}" ]; then
		printf "No pueden establecerse más divisiones que líneas tiene el fichero. Se sale...\n"
		exit 1
	fi

	rm -f "${DIR_TMP}"*
	FICHERO_SIN_EXTENSION=$(basename "${i}" | sed "s/${EXTENSION_ENTRADA}//g")
	LINEAS_FICHERO_SALIDA=$(expr ${LINEAS_FICHERO_ENTRADA} / ${DIVISIONES})
	#Dividimos el fichero
	split -d -a 3 -l "${LINEAS_FICHERO_SALIDA}" "${i}" "${DIR_TMP}${FICHERO_SIN_EXTENSION}_"
	#Si la división no es exacta copiamos el contenido del último fichero dividido en el penúltimo
	#y borramos el fichero. Se empieza por el '_000'
	ULTIMO_FICHERO=$((${DIVISIONES}-1))

	if [ "${DIVISIONES}" -gt 10 -a "${DIVISIONES}" -lt 100 ]; then
		if [ -f "${DIR_TMP}${FICHERO_SIN_EXTENSION}_0${ULTIMO_FICHERO}" ]; then
			cat "${DIR_TMP}${FICHERO_SIN_EXTENSION}_0${DIVISIONES}" >> "${DIR_TMP}${FICHERO_SIN_EXTENSION}_0${ULTIMO_FICHERO}"
			rm -f "${DIR_TMP}${FICHERO_SIN_EXTENSION}_0${DIVISIONES}"
		fi
	elif [ "${DIVISIONES}" -eq 10 ]; then
		if [ -f "${DIR_TMP}${FICHERO_SIN_EXTENSION}_0${DIVISIONES}" ]; then
			cat "${DIR_TMP}${FICHERO_SIN_EXTENSION}_0${DIVISIONES}" >> "${DIR_TMP}${FICHERO_SIN_EXTENSION}_00${ULTIMO_FICHERO}"
			rm -f "${DIR_TMP}${FICHERO_SIN_EXTENSION}_0${DIVISIONES}"
		fi
	elif [ "${DIVISIONES}" -lt 10 ]; then
		if [ -f "${DIR_TMP}${FICHERO_SIN_EXTENSION}_00${DIVISIONES}" ]; then
			cat "${DIR_TMP}${FICHERO_SIN_EXTENSION}_00${DIVISIONES}" >> "${DIR_TMP}${FICHERO_SIN_EXTENSION}_00${ULTIMO_FICHERO}"
			rm -f "${DIR_TMP}${FICHERO_SIN_EXTENSION}_00${DIVISIONES}"
		fi
	elif [ "${DIVISIONES}" -ge 100 ]; then
		if [ -f "${DIR_TMP}${FICHERO_SIN_EXTENSION}_${DIVISIONES}" ]; then
			echo "${DIR_TMP}${FICHERO_SIN_EXTENSION}_${DIVISIONES}"
			echo "${DIR_TMP}${FICHERO_SIN_EXTENSION}_${ULTIMO_FICHERO}"
			cat "${DIR_TMP}${FICHERO_SIN_EXTENSION}_${DIVISIONES}" >> "${DIR_TMP}${FICHERO_SIN_EXTENSION}_${ULTIMO_FICHERO}"
			rm -f "${DIR_TMP}${FICHERO_SIN_EXTENSION}_${DIVISIONES}"
		fi
	fi

	#Transferimos ficheros divididos con extensión al directorio de reparto.
	for j in "${DIR_TMP}"* ; do
		NOMBRE_FICHERO_DIVIDIDO=$(basename "${j}")
		mv "${j}" "${DIR_FICHEROS_REPARTIR}${NOMBRE_FICHERO_DIVIDIDO}${EXTENSION_ENTRADA}"
	done
done 
