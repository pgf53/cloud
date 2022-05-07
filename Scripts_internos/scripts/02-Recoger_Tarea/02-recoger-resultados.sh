#!/bin/sh

# Script usado para recoger Resultados en Cloud/Resultados
# Llamada: recoger-resultados.sh ["01 03 04"]


# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

clear
printf "\n\n%s\n" "¿Seguro que desea RECOGER los Resultados de la tarea \"${NOMBRE_TAREA}\" de los equipos \"${EQUIPOS_LT}\"?"

printf "\nPREVIAMENTE a la recogida, se guardara el ESTADO de los equipos remotos (\"foto\" de la recogida a realizar).\n"

printf "\n%s\n\n" "Pulse una tecla para continuar... (Ctrl-C para Salir)"


[ "${FAST_MODE}" -eq 0 ] && read tecla

#eval "export TIPO_ESTADO=${ESTADO_CON_LISTA_FICHEROS}; ${SCRIPT_ESTADO} \"${EQUIPOS_LT}\""

# Se indica en fichero de estado, que posteriormente se pasa a recoger los ficheros
printf "\n\n\n###########################\n\nSe procede a recoger los Resultados remotos...\n" #| tee -a "${FILE_ESTADO_LISTA_FICHEROS}"

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

    printf "\n\n###### Equipo LT$i: ###########\n"
    # Construir nombre fichero local de recogida para este equipo
    FICHERO_RECOGIDA_NOMBRE="${PREFIJO_NOMBRE_EQUIPO}$i${FILE_RECOGIDA_EXT}" #lt05-framework_Resultados.tar.gz
    FICHERO_RECOGIDA_COMPLETO_REMOTO="${FILE_RECOGIDA_RUTA}${FICHERO_RECOGIDA_NOMBRE}" #/opt/cluster/framework/02-Recoger_Tarea/lt05-framework_Resultados.tar.gz

    if [ -z "${SUBDIR_EXCLUIR_RECOGIDA}" ]; then
	CMD_REMOTO_CONSULTA="ls -1 ${DIR_REMOTO_ENTRADAS_FINALIZADAS}"
	#Nos situamos en /opt/cluster/framework/01-Enviar_Tarea/framework/ y comprimimos Resultados/ como /opt/cluster/framework/02-Recoger_Tarea/lt05-framework_Resultados.tar.gz
	CMD_REMOTO="rm -Rf ${FICHERO_RECOGIDA_COMPLETO_REMOTO} 2>&1 1>/dev/null; cd ${DIR_REMOTO_ENVIO_DESCOMP}; tar cfvz  ${FICHERO_RECOGIDA_COMPLETO_REMOTO} ${SUBDIR_REMOTO_RECOGIDA}"
    else
	CMD_REMOTO="rm -Rf ${FICHERO_RECOGIDA_COMPLETO_REMOTO} 2>&1 1>/dev/null; cd ${DIR_REMOTO_ENVIO_DESCOMP}; tar cfvz  ${FICHERO_RECOGIDA_COMPLETO_REMOTO} ${SUBDIR_REMOTO_RECOGIDA} --exclude=**${SUBDIR_EXCLUIR_RECOGIDA}*"
    fi

    # Preparar (comprimir) fichero con resultados en equipo remoto
    ${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${CMD_REMOTO}"
    [ "$?" = "0" ] && DESCARGA_OK="1" || DESCARGA_OK="0"



    # Descargar fichero con resultados
    if [ "${DESCARGA_OK}" = "1" ]; then
        mkdir -p "${SUBDIR_LOCAL_RESULTADOS_COMPRIMIDOS}" 2>&1 1>/dev/null	#Crea directorio Tareas/framework/salida
        rm -Rf "${SUBDIR_LOCAL_RESULTADOS_COMPRIMIDOS}${FICHERO_RECOGIDA_NOMBRE}" 1>/dev/null 2>&1	#Elimina fichero con el nombre que hemos descargado si existiese
		#Guardamos el fichero comprimido en el equipo remoto, en el directorio 'salida' de la tarea en equipo local
        ${SCP_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${FICHERO_RECOGIDA_COMPLETO_REMOTO} "${SUBDIR_LOCAL_RESULTADOS_COMPRIMIDOS}"
        # Fichero descargado completamente?
        [ "$?" = "0" ] && DESCARGA_OK="1"
    fi

    # Solo descomprimimos si el fichero se ha descargado correctamente
    if [ "${DESCARGA_OK}" = "1" ]; then
	# Descomprimir (en local) fichero con Resultados
	# No borrar subdirectorio de recogidas: para "juntar" los resultados de todos los equipos
	mkdir -p "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}" 2>&1 1>/dev/null #Crea subdirectorio Tareas/framework/salidas/extraidos
	tar xfvz "${SUBDIR_LOCAL_RESULTADOS_COMPRIMIDOS}${FICHERO_RECOGIDA_NOMBRE}" -C "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}"

	# Comprobamos los ficheros de entrada procesados hasta el momento
	export procesados=$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}${i} "${CMD_REMOTO_CONSULTA}")
	echo "ESTOS SON LOS FICHEROS DETECTADOS COMO FINALIZADOS en equipo ${PREFIJO_NOMBRE_EQUIPO}${i}: ${procesados}"
	export TIPO_ESTADO="recogida"
	# Actualizamos estado
	#eval "${SCRIPT_ESTADO} \"${EQUIPOS_LT}\""
	${SCRIPT_ESTADO} "${i}"
    else
	printf "\n\nEquipo ${PREFIJO_NOMBRE_EQUIPO}$i: Error al descargar el fichero ${SUBDIR_LOCAL_RESULTADOS_COMPRIMIDOS}${FICHERO_RECOGIDA_NOMBRE}\n\n"
    fi
done

