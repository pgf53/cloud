#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

#Funciones

#Recibe fichero y añade en primera línea la fecha 
#y hora actual
add_last_update()
{
	OUTPUT_FILE="$1"
	actualizacion=$(printf "Última actualización: %s" "$(date)")
	fecha=$(grep "Última actualización:" ${OUTPUT_FILE})
	[ "${fecha}" != "" ] && sed -i "s/^Última actualización.*/${actualizacion}/g" "${OUTPUT_FILE}" ||  sed -i "1i${actualizacion}\n" "${OUTPUT_FILE}"
}


#El objetivo de este script es actualizar manualmente
#el script de estado y el script de listado_fichero

#Comprobamos estado de la tarea en aquellos equipos no finalizados
#Los equipos ya finalizados no requieren de actualización

#Existen tres posibilidades en los equipos no finalizados:
#1 El equipo se torna indisponible y por lo tanto tarea interrumpida
#2 El equipo está disponible pero la tarea no existe. Tarea interrumpida
#3 El equipo está disponible y la tarea en ejecución. No se hace nada

while IFS= read -r line
do
	LINEA_EQUIPO=$(printf "%s" "${line}" | sed "s/^Equipo ${PREFIJO_NOMBRE_EQUIPO}.*/linea_equipo/g")
	if [ "${LINEA_EQUIPO}" = "linea_equipo" ]; then
		EQUIPO=$(printf "%s" "${line}" | cut -d':' -f'1' | cut -d' ' -f'2')
		ESTADO_ACTUAL=$(printf "$line" | awk -F"\t" 'BEGIN{FS=OFS="\t"} {print $NF}')
		if [ "${ESTADO_ACTUAL}" != "${FINALIZADA}" ]; then
			TIPO_SSH=$(printf "$line" | awk -F"\t" '{print $6}')
			[ "${TIPO_SSH}" = "${SSH_KEY}" ] && SSH_COMANDO="${SSH_COMANDO_KEY}" || SSH_COMANDO="${SSH_COMANDO_CERTIFICADO}"
			COMANDO_PRUEBA="echo ''"
			${SSH_COMANDO} "${USER_REMOTO}"@${EQUIPO} "${COMANDO_PRUEBA}" < /dev/null
				if [ $? -eq 0 ]; then
					existe_proceso=$(ps ax | pgrep "${PROCESO_PARA_ESTADO}")
					if [ "${existe_proceso}" = "" ]; then
						NUEVA_LINEA=$(printf "$line" | awk -v interrumpida="${INTERRUMPIDA}" -F"\t" 'BEGIN{FS=OFS="\t"} {$NF=interrumpida;print $0}')
						LINEA_EQUIPO=$(printf "%s" "${line}" | sed -e "s#\[#\\\[#g" -e "s#\]#\\\]#g")
						NUEVA_LINEA=$(printf "%s" "${NUEVA_LINEA}" | sed -e "s#\[#\\\[#g" -e "s#\]#\\\]#g")
						sed -i "s#${LINEA_EQUIPO}#${NUEVA_LINEA}#g" "${FILE_ESTADO}"
					fi
				else
					NUEVA_LINEA=$(printf "$line" | awk -v disponibilidad="${NO_DISPONIBLE}" -v interrumpida="${INTERRUMPIDA}" -F"\t" 'BEGIN{FS=OFS="\t"} {$5=disponibilidad;$NF=interrumpida;print $0}')
					LINEA_EQUIPO=$(printf "%s" "${line}" | sed -e "s#\[#\\\[#g" -e "s#\]#\\\]#g")
					NUEVA_LINEA=$(printf "%s" "${NUEVA_LINEA}" | sed -e "s#\[#\\\[#g" -e "s#\]#\\\]#g")
					sed -i "s#${LINEA_EQUIPO}#${NUEVA_LINEA}#g" "${FILE_ESTADO}"
				fi
		fi
	fi
done < "${FILE_ESTADO}"

add_last_update "${FILE_ESTADO}"

#Una vez hemos actualizado el fichero de estado, pasamos
#a actualizar el fichero de listado a partir de este.

while IFS= read -r line
do
	LINEA_EQUIPO=$(printf "%s" "${line}" | sed "s/^Equipo ${PREFIJO_NOMBRE_EQUIPO}.*/linea_equipo/g")
	if [ "${LINEA_EQUIPO}" = "linea_equipo" ]; then
		EQUIPO=$(printf "%s" "${line}" | cut -d':' -f'1' | cut -d' ' -f'2')
		ESTADO_ACTUAL=$(printf "$line" | awk -F"\t" 'BEGIN{FS=OFS="\t"} {print $NF}')
		DISPONIBILIDAD=$(printf "$line" | awk -F"\t" 'BEGIN{FS=OFS="\t"} {print $NF}')
		if [ "${ESTADO_ACTUAL}" != "${FINALIZADA}" -a "${ESTADO_ACTUAL}" = "${DISPONIBLE}" ]; then
			TIPO_SSH=$(printf "$line" | awk -F"\t" '{print $6}')
			[ "${TIPO_SSH}" = "${SSH_KEY}" ] && SSH_COMANDO="${SSH_COMANDO_KEY}" || SSH_COMANDO="${SSH_COMANDO_CERTIFICADO}"
			CMD_REMOTO_CONSULTA_FICHEROS="ls -1 ${DIR_REMOTO_ENTRADAS_FINALIZADAS}"
			PROCESADOS=$(${SSH_COMANDO} "${USER_REMOTO}"@${EQUIPO} "${CMD_REMOTO_CONSULTA_FICHEROS}") 2>/dev/null
			if [ $? -eq 0 ]; then
			#Actualizamos a 'si' la columna 'terminados' de aquellos ficheros presentes en el directorio 'entradas_finalizadas'
			#del equipo remoto
				for fichero in ${PROCESADOS}; do
					NUEVA_LINEA=$(awk -v pat="$fichero" -v OFS='\t' '$0 ~ pat {$2="si"; print $0}' "${FILE_ESTADO_LISTADO_FICHEROS}")
					sed -i "s/^$fichero\t.*/$NUEVA_LINEA/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
				done
			fi
		fi
	fi
done < "${FILE_ESTADO}"

add_last_update "${FILE_ESTADO_LISTADO_FICHEROS}"

