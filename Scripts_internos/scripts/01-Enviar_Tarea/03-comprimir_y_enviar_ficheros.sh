#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}
#. ../config_interna.sh
ACTUAL="$(pwd)"

clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea ENVIAR los ficheros de la Tarea \"${NOMBRE_TAREA}\" a los equipos \"${EQUIPOS_LT}\"?." "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

for i in ${EQUIPOS_LT}; do

	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

	#MODO_SSH=$(. "${SCRIPT_CHECK_SSH}" "${i}")
	#if [ "${MODO_SSH}" = "${SSH_CERTIFICADO}" ]; then
	#	SSH_COMANDO="${SSH_COMANDO_CERTIFICADO}"
	#	SCP_COMANDO="${SCP_COMANDO_CERTIFICADO}"
	#elif [ "${MODO_SSH}" = "${SSH_KEY}" ]; then
	#	SSH_COMANDO="${SSH_COMANDO_KEY}"
	#	SCP_COMANDO="${SCP_COMANDO_KEY}"
	#else
	#	echo "Modo SSH no detectado. Se sale..."
	#	exit 1
	#fi

    printf "\n\n###### Comprimiendo/Enviando ficheros a Equipo LT$i (Tarea \"${NOMBRE_TAREA}\") ###########\n"

	if [ "$(ls ${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}${i}/${SUBDIR_TAREA_ENTRADA})" ]; then
		# Crear fichero comprimido con la Tarea (Estructura+Ficheros de analisis) para este equipo
		# en "DIR_FILE_ANALISIS" (03-Ficheros_Montados/)
		FICHERO_ANALISIS_ENVIAR="${DIR_FILE_ANALISIS}${PREFIJO_NOMBRE_EQUIPO}$i${EXT_FILE_ANALISIS}" #/opt/nuevo_Cloud/Scripts_internos/scripts/01-Enviar_Tarea/03-Ficheros_Desplegados/lt05-${NOMBRE_TAREA}.tar.gz
		cd "${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}$i/"
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

		# Desplegar fichero con variables configuracion internas
		${SCP_COMANDO} "${DIR_SCRIPTS_INTERNOS}${FILE_CONFIG_INTERNA}"	  "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${DIR_REMOTO_ENVIO} # 1>/dev/null 2>&1
	fi
	# Restaurar la carpeta de invocación
	cd "${ACTUAL}" 
done
