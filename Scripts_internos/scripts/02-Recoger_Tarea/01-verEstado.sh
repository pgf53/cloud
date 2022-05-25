#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

#Funciones

estado()
{
  clear

	###############LANZAMIENTO####################
	#Se ejecuta en el lanzamiento de una tarea
	#Solo se entra una vez independientemente del número de equipos
	if [ "${TIPO_ESTADO}" = "lanzamiento" ]; then

		#Creamos 'lista_ficheros.txt'
		#Generamos columna de nombres
		ls -1 "${DIR_FICHEROS_REPARTIR}" | awk 'BEGIN{OFS="\t";} {print $1, "no", "no";}' > "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Introducimos columna que identifica a qué equipo ha sido asignado el fichero
		while IFS= read -r line
		do
			fichero=$(printf "%s" "${line}" | cut -d'	' -f'1')
			equipo=$(encuentra_equipos)
			instancia=$(printf "%s" "${equipo}" | rev | cut -d'_' -f'1' | rev)
			equipo=$(printf "%s" "${equipo}" | sed "s/_${instancia}//g")
			if [ "${equipo}" != "" ]; then
				#Creamos la nueva línea que incluye el equipo al que ha sido asignado el fichero
				nueva_linea=$(awk -v equipo="$equipo" -v instancia="${instancia}" -v pat="$fichero" -F"\t" 'BEGIN{FS=OFS="\t"} $0 ~ pat { print $0 OFS equipo FS instancia}' "${FILE_ESTADO_LISTADO_FICHEROS}")
				#Sustituimos la línea antigua por la nueva que incluye el equipo.
				sed -i "s/${fichero}.*/${nueva_linea}/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
			fi
		done < "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Imprimimos progreso inicial
		ficheros_total=$(ls "${DIR_FICHEROS_REPARTIR}" | wc -l)
		PROGRESO=$(printf "PROGRESO: (0/%s) FICHEROS FINALIZADOS\n" "${ficheros_total}")
		sed -i "1i$PROGRESO\n" "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Imprimimos Instrucciones
		instrucciones="#########Instrucciones#######\nPrimera columna: nombre del fichero. Segunda columna: ¿Terminado en equipo remoto?. Tercera columna: ¿Recogido en el servidor?. Cuarta columna: equipo en el que se ha desplegado el fichero. Quinta columna: Instancia de despliegue del fichero\n" 
		actualizacion=$(printf "Última actualización: %s" "$(date)")
		sed -i "1i$instrucciones" "${FILE_ESTADO_LISTADO_FICHEROS}"
		#Imprimimos fecha y hora de creación
		sed -i "1i${actualizacion}\n" "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Invocamos a SCRIPT_ESTADO_EQUIPOS para creación de estado_tarea:
		 export INVOCACION="CREA_ESTADO_TAREA"
		. "${SCRIPT_ESTADO_EQUIPOS}"


	###############RECOGIDA##########################
	elif [ "${TIPO_ESTADO}" = "recogida" ]; then
		echo "ESTOS SON LOS FICHEROS DETECTADOS COMO FINALIZADOS: ${procesados}"

		#Actualizamos 'lista_ficheros.txt'
		progreso=0
		for fichero_entrada in ${procesados}
		do
			progreso=$((progreso+1))
			#Si hemos llegado aquí es que el fichero se ha descargado correctamente.
			nueva_linea=$(awk -v pat="$fichero_entrada" -v OFS='\t' '$0 ~ pat {$2="si"; $3="si"; print $0}' "${FILE_ESTADO_LISTADO_FICHEROS}")
			sed -i "s/^$fichero_entrada\t.*/$nueva_linea/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
			ficheros_terminados=$(awk 'BEGIN{FS=OFS="\t"} $2=="si" && $3=="si" {print $1}' ${FILE_ESTADO_LISTADO_FICHEROS} | wc -l)
			sed -i "s# (.*/# (${ficheros_terminados}/#g" "${FILE_ESTADO_LISTADO_FICHEROS}"
		done
		actualizacion="$(date)"
		sed -i "s/^Última actualización:.*/Última actualización: $actualizacion/g" "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Actualizamos 'estado_nombretarea.txt'
		export equipo
		export progreso
		export num_instances
		export INVOCACION="ACTUALIZA_ESTADO_TAREA_RECOGIDA"
		. "${SCRIPT_ESTADO_EQUIPOS}"

	fi

  printf "\n\n###############################\n\n"
}


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
		fi
		if [ "${line}" = "${fichero}" ];then
			printf "%s" "${equipo}"
			break
		fi
	done < ${FICHERO_REPARTO}
}


estado

printf "\n\nResultados de Estado guardados en el directorio:\n\n%s\n\n" "$(echo ${SUBDIR_LOCAL_RESULTADOS_ESTADO})"
