#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

#Comprobamos estado de la tarea en aquellos equipos no finalizados
while IFS= read -r line
do
	LINEA_EQUIPO=$(printf "%s" "${line}" | sed "s/^Equipo ${PREFIJO_NOMBRE_EQUIPO}.*/linea_equipo/g")
	if [ "${LINEA_EQUIPO}" = "linea_equipo" ]; then
		EQUIPO=$(printf "%s" "${line}" | cut -d':' -f'1' | cut -d' ' -f'2')
		ESTADO_ACTUAL=$(printf "$line" | awk -F"\t" 'BEGIN{FS=OFS="\t"} {print $NF}')
		if [ "${ESTADO_ACTUAL}" = "${EJECUTANDOSE}" ]; then
			TIPO_SSH=$(printf "$line" | awk -F"\t" '{print $5}')
			[ "${TIPO_SSH}" = "${SSH_KEY}" ] && SSH_COMANDO="${SSH_COMANDO_KEY}" || SSH_COMANDO="${SSH_COMANDO_CERTIFICADO}"
			COMANDO_PRUEBA="echo ''"
			${SSH_COMANDO} "${USER_REMOTO}"@${EQUIPO} "${COMANDO_PRUEBA}" 2>/dev/null
				if [ $? -eq 0 ]; then

				else
					nueva_linea=$(printf "$line" | awk -v estado="${}" -F"\t" 'BEGIN{FS=OFS="\t"} {print $NF}')
				fi
		fi
	fi
done < "${FILE_ESTADO}"

		LINEA_ESTADO=$(awk -v pat="${equipo}:" -F"\t" '$0 ~ pat { print $0 }' "${FILE_ESTADO}")
		ESTADO_ACTUAL=$(printf awk -v pat="$equipo" -F"\t" '{ print $NF }')
		#progreso_actual=$(awk -v pat="$equipo" -F"\t" '$0 ~ pat { print $(NF-1) }' "${FILE_ESTADO}" | sed -e "s/(//g" -e "s/)//g" | cut -d'/' -f1)
		#progreso_total=$(awk -v pat="$equipo" -F"\t" '$0 ~ pat { print $(NF-1) }' "${FILE_ESTADO}" | sed -e "s/(//g" -e "s/)//g" | cut -d'/' -f2)
		#if [ "${progreso_actual}" -lt "${progreso_total}" ]; then
		if [ "${ESTADO_ACTUAL}" != "${FINALIZADA}" ]; then
			CMD_REMOTO_CONSULTA_FICHEROS="ls -1 ${DIR_REMOTO_ENTRADAS_FINALIZADAS}"
			procesados=$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${CMD_REMOTO_CONSULTA_FICHEROS}")
			if [ $? -eq 0 ]; then
				#Actualizamos a 'si' la columna 'terminados' de aquellos ficheros presentes en el directorio 'entradas_finalizadas'
				#del equipo remoto
				for j in ${procesados}
				do
					nueva_linea=$(awk -v pat="$j" -v OFS='\t' '$0 ~ pat {$2="si"; print $0}' "${FILE_ESTADO_LISTADO_FICHEROS}")
					sed -i "s/^$j\t.*/$nueva_linea/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
				done


				#Pasamos a verificar el estado
				export equipo_consultado="${PREFIJO_NOMBRE_EQUIPO}${i}"
				export i
				export INVOCACION="CONSULTA_ESTADO_TAREA"
				. "${SCRIPT_ESTADO_EQUIPOS}"
			else
				
			fi
		actualizacion="$(date)"
		#sed -i "s/^Última actualización:.*/Última actualización: $actualizacion/g" ${FILE_ESTADO}
		sed -i "s/^Última actualización:.*/Última actualización: $actualizacion/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
		fi


