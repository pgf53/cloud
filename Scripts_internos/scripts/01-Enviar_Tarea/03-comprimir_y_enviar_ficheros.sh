#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}
#. ../config_interna.sh
ACTUAL="$(pwd)"

clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea ENVIAR los ficheros de la Tarea \"${NOMBRE_TAREA}\" a los equipos \"${EQUIPOS_LT}\"?." "Pulse una tecla para continuar... (Ctrl-C para Salir)"
[ "${FAST_MODE}" -eq 0 ] && read tecla

EXT_FILE_ANALISIS_ORIGINAL=${EXT_FILE_ANALISIS}
DIR_REMOTO_ORIGINAL=${DIR_REMOTO}
DIR_REMOTO_ENVIO_ORIGINAL=${DIR_REMOTO_ENVIO}
DIR_REMOTO_RECOGIDA_ORIGINAL=${DIR_REMOTO_RECOGIDA}
FILE_CONFIG_ORIGINAL=${FILE_CONFIG}

for i in ${EQUIPOS_LT}; do

	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

    printf "\n\n###### Comprimiendo/Enviando ficheros a Equipo LT$i (Tarea \"${NOMBRE_TAREA}\") ###########\n"
	for num_instances in $(eval echo "{1..$N_INSTANCIA}"); do
		if [ "$(ls ${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}${i}/${NOMBRE_TAREA}${num_instances}/${SUBDIR_TAREA_ENTRADA})" ]; then
			# Crear fichero comprimido con la Tarea (Estructura+Ficheros de analisis) para este equipo
			# en "DIR_FILE_ANALISIS" (03-Ficheros_Montados/)

			#Cargamos valores originales
			EXT_FILE_ANALISIS=${EXT_FILE_ANALISIS_ORIGINAL}
			DIR_REMOTO=${DIR_REMOTO_ORIGINAL}
			DIR_REMOTO_ENVIO=${DIR_REMOTO_ENVIO_ORIGINAL}
			DIR_REMOTO_RECOGIDA=${DIR_REMOTO_RECOGIDA_ORIGINAL}
			FILE_CONFIG=${FILE_CONFIG_ORIGINAL}

			##########Adaptación para incluir las 'n' instacias por equipo####################################################
			EXT_FILE_ANALISIS=$(printf "%s" ${EXT_FILE_ANALISIS} | sed "s/${NOMBRE_TAREA}/${NOMBRE_TAREA}${num_instances}/g")
			DIR_REMOTO=$(printf "%s" ${DIR_REMOTO} | sed "s/${NOMBRE_TAREA}/${NOMBRE_TAREA}${num_instances}/g")
			DIR_REMOTO_ENVIO=$(printf "%s" ${DIR_REMOTO_ENVIO} | sed "s/${NOMBRE_TAREA}/${NOMBRE_TAREA}${num_instances}/g")
			DIR_REMOTO_RECOGIDA=$(printf "%s" ${DIR_REMOTO_RECOGIDA} | sed "s/${NOMBRE_TAREA}/${NOMBRE_TAREA}${num_instances}/g")
			FILE_CONFIG=$(printf "%s" ${FILE_CONFIG} | sed "s/${NOMBRE_TAREA}/${NOMBRE_TAREA}${num_instances}/g")
			FICHERO_ANALISIS_ENVIAR="${DIR_FILE_ANALISIS}${PREFIJO_NOMBRE_EQUIPO}${i}${EXT_FILE_ANALISIS}"
			###################################################################################################################

			#renombramos fichero de configuración de la tarea
			mv "${DIR_TAREA}${FILE_CONFIG_ORIGINAL}" "${DIR_TAREA}${FILE_CONFIG}"

			cd "${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}${i}/${NOMBRE_TAREA}${num_instances}/"
			rm -Rf   "${FICHERO_ANALISIS_ENVIAR}" 1>/dev/null 2>&1
			tar cfvz "${FICHERO_ANALISIS_ENVIAR}" "./"
			cd "${DIR_LOCAL_ENVIO}"

			# Crear dir remoto y limpiar ficheros a copiar
			${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "rm -Rf ${DIR_REMOTO} 1>/dev/null 2>&1; mkdir -p ${DIR_REMOTO_ENVIO} 1>/dev/null 2>&1; mkdir -p ${DIR_REMOTO_RECOGIDA} 1>/dev/null 2>&1; cd ${DIR_REMOTO}"

			# Desplegar fichero analisis
			${SCP_COMANDO} "${FICHERO_ANALISIS_ENVIAR}"        "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${DIR_REMOTO_ENVIO} 1>/dev/null 2>&1

			# Desplegar script remoto
			${SCP_COMANDO} "${DIR_SCRIPTS_INTERNOS}${FILE_SCRIPT_REMOTO}" "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${DIR_REMOTO_ENVIO} 1>/dev/null 2>&1

			# Desplegar script monitorización de salida para recogida automática
			${SCP_COMANDO} "${DIR_SCRIPTS_INTERNOS}${FILE_SCRIPT_MONITORIZA_SALIDA}" "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${DIR_REMOTO_ENVIO} 1>/dev/null 2>&1

			# Desplegar script de envío de mensaje UDP
			${SCP_COMANDO} "${DIR_SCRIPTS_INTERNOS}${FILE_SCRIPT_ENVIA_UDP}" "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${DIR_REMOTO_ENVIO} 1>/dev/null 2>&1

			# Desplegar fichero con variables configuracion de la Tarea
			${SCP_COMANDO} "${DIR_TAREA}${FILE_CONFIG}"	  "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${DIR_REMOTO_ENVIO} 1>/dev/null 2>&1
			#Una vez desplegado lo restauramos a valor original de la tarea
			mv "${DIR_TAREA}${FILE_CONFIG}" "${DIR_TAREA}${FILE_CONFIG_ORIGINAL}"

			# Desplegar fichero con variables configuracion internas
			${SCP_COMANDO} "${DIR_SCRIPTS_INTERNOS}${FILE_CONFIG_INTERNA}"	  "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${DIR_REMOTO_ENVIO} # 1>/dev/null 2>&1
		fi
		# Restaurar la carpeta de invocación
		cd "${ACTUAL}" 
	done
done
