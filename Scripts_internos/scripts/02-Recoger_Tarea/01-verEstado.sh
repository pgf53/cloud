#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

#Funciones

estado()
{
  clear
  #printf "\nEstado tarea \"${NOMBRE_TAREA}\" en los equipos \"${EQUIPOS_LT}\":\nHora actual: %s\n\n" "$(date)"
  lanzamiento=0

  for i in ${EQUIPOS_LT}; do

    #printf "%s:" "LT${i}"

    # ON/OFF
	#Atención!! Eliminar la interfaz (-I eth1) cuando se despliegue en el laboratorio
    #arping -c 1 "${PREFIJO_NOMBRE_EQUIPO}$i" 1>/dev/null 2>&1
	#arping -I eth1 -c 1 "${PREFIJO_NOMBRE_EQUIPO}$i" 1>/dev/null 2>&1
    #[ "$?" = "0" ] && POWER="ON" || POWER="OFF"

    # SO:
    #[ "${POWER}" = "ON" ] && SO="$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${CMD_SO_REMOTO}" 2>/dev/null)" || SO=" --- "

    # ESTADO TAREA:
    #ESTADO_TAREA="$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${CMD_ESTADO_TAREA}" 2>/dev/null)"
    #[ -z "${ESTADO_TAREA}" ] && ESTADO_TAREA="TERMINADA!"

	#printf "\t%s\t(%s)\tTarea... %s\n" "${POWER}" "${SO}" "${ESTADO_TAREA}" 
	

	###############LANZAMIENTO####################
	#Se ejecuta en el lanzamiento de una tarea
	#Solo se entra una vez independientemente del número de equipos
	if [ "${TIPO_ESTADO}" = "lanzamiento" -a "${lanzamiento}" -eq 0 ]; then

		lanzamiento=1
		#Creamos 'lista_ficheros.txt'
		#Generamos columna de nombres
		ls -1 "${DIR_FICHEROS_REPARTIR}" | awk 'BEGIN{OFS="\t";} {print $1, "no", "no";}' > "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Introducimos columna que identifica a qué equipo ha sido asignado el fichero
		while IFS= read -r line
		do
			fichero=$(printf "%s" "${line}" | cut -d'	' -f'1')
			equipo=$(encuentra_equipos)
			if [ "${equipo}" != ""  ]; then
				#Creamos la nueva línea que incluye el equipo al que ha sido asignado el fichero
				nueva_linea=$(awk -v equipo="$equipo" -v pat="$fichero" -F"\t" 'BEGIN{FS=OFS="\t"} $0 ~ pat { print $0 OFS equipo}' "${FILE_ESTADO_LISTADO_FICHEROS}")
				#linea_a_modificar=$(awk -v pat="$fichero" -F"\t" '$0 ~ pat { print $0}' "${FILE_ESTADO_LISTADO_FICHEROS}")
				#Sustituimos la línea antigua por la nueva que incluye el equipo.
				sed -i "s/${fichero}.*/${nueva_linea}/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
			fi
		done < "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Imprimimos Instrucciones
		instrucciones="#########Instrucciones#######\nPrimera columna: nombre del fichero. Segunda columna: ¿Terminado en equipo remoto?. Tercera columna: ¿Recogido en el servidor?. Cuarta columna: equipo en el que se ha desplegado el fichero.\n\n" 
		actualizacion=$(printf "Última actualización: %s" "$(date)")
		sed -i "1i$instrucciones" "${FILE_ESTADO_LISTADO_FICHEROS}"
		sed -i "1i$actualizacion" "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Invocamos a SCRIPT_ESTADO_EQUIPOS para creación de estado_tarea:
		 export INVOCACION="CREA_ESTADO_TAREA"
		. "${SCRIPT_ESTADO_EQUIPOS}"
		
		#Creamos 'estado_nombretarea.txt'
		#rm -f "${FILE_ESTADO}"
		#for j in ${EQUIPOS_LT}
		#do
		#	num_ficheros_asignados=$(ls "${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}${j}/${SUBDIR_TAREA_ENTRADA}" | wc -l)
			#[ $? -ne 0 ] && echo "Debe esperar a comprobar el estado de los equipos antes de lanzar una nueva tarea simultánea"
		#	printf "Equipo: %s%s\t%s\t%s\t(0/%s)\tEjecutándose\n" "${PREFIJO_NOMBRE_EQUIPO}" "${j}" "${POWER}" "${SO}" "${num_ficheros_asignados}" >> "${FILE_ESTADO}"
		#done
		#actualizacion=$(printf "Última actualización: %s" "$(date)")
		#sed -i "1i$actualizacion" "${FILE_ESTADO}"


	###############RECOGIDA##########################
	elif [ "${TIPO_ESTADO}" = "recogida" ]; then
		echo "ESTOS SON LOS FICHEROS DETECTADOS COMO FINALIZADOS: ${procesados}"

		#Actualizamos 'lista_ficheros.txt'
		progreso=0
		for fichero_entrada in ${procesados}
		do
			progreso=$((progreso+1))
			#sed -i "s/^$j\t.*/$j\tsi\tsi/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
			#Si hemos llegado aquí es que el fichero se ha descargado correctamente.
			nueva_linea=$(awk -v pat="$fichero_entrada" -v OFS='\t' '$0 ~ pat {$2="si"; $3="si"; print $0}' "${FILE_ESTADO_LISTADO_FICHEROS}")
			sed -i "s/^$fichero_entrada\t.*/$nueva_linea/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
		done
		actualizacion="$(date)"
		sed -i "s/^Última actualización:.*/Última actualización: $actualizacion/g" "${FILE_ESTADO_LISTADO_FICHEROS}"

		#Actualizamos 'estado_nombretarea.txt'
		export equipo_recogido="${PREFIJO_NOMBRE_EQUIPO}${i}"
		export progreso
		export INVOCACION="ACTUALIZA_ESTADO_TAREA_RECOGIDA"
		. "${SCRIPT_ESTADO_EQUIPOS}"


		#num_ficheros_asignados=$(ls "${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}${i}/${SUBDIR_TAREA_ENTRADA}" | wc -l)
		#num_ficheros_asignados=$(num_ficheros)
		#Actualización del progreso
		#sed -i "s/^Equipo: ${PREFIJO_NOMBRE_EQUIPO}${i}\t${POWER}\t${SO}\t.*\//Equipo: ${PREFIJO_NOMBRE_EQUIPO}${i}\t${POWER}\t${SO}\t(${progreso}\//g" "${FILE_ESTADO}"
		#actualizacion="$(date)"
		#sed -i "s/^Última actualización:.*/Última actualización: $actualizacion/g" "${FILE_ESTADO}"
		#Actualización del estado
		#equipo="${PREFIJO_NOMBRE_EQUIPO}${i}"
		#progreso_actual=$(awk -v pat="$equipo" -F"\t" '$0 ~ pat { print $4 }' "${FILE_ESTADO}" | sed -e "s/(//g" -e "s/)//g" | cut -d'/' -f1)
		#progreso_total=$(awk -v pat="$equipo" -F"\t" '$0 ~ pat { print $4 }' "${FILE_ESTADO}" | sed -e "s/(//g" -e "s/)//g" | cut -d'/' -f2)
		#echo "PROGRESO: ${progreso_actual}/${progreso_total}"
		#if [ "${progreso_actual}" -eq "${progreso_total}" ]; then
			#echo "ENTRA EN EL FINAL"
			#sed -i "s/^Equipo: ${PREFIJO_NOMBRE_EQUIPO}${i}\t${POWER}\t${SO}\t(${progreso_actual}\/${progreso_total})\t.*/Equipo: ${PREFIJO_NOMBRE_EQUIPO}${i}\t${POWER}\t${SO}\t(${progreso_actual}\/${progreso_total})\tFinalizada/g" "${FILE_ESTADO}"
		#actualizacion="$(date)"
		#sed -i "s/^Última actualización:.*/Última actualización: $actualizacion/g" "${FILE_ESTADO}"
		#fi

	################CONSULTA######################
	elif [ "${TIPO_ESTADO}" = "consulta" ];  then
		#Comprobamos estado de la tarea en aquellos equipos no finalizados
		equipo="${PREFIJO_NOMBRE_EQUIPO}${i}"
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
			fi
		actualizacion="$(date)"
		#sed -i "s/^Última actualización:.*/Última actualización: $actualizacion/g" ${FILE_ESTADO}
		sed -i "s/^Última actualización:.*/Última actualización: $actualizacion/g" "${FILE_ESTADO_LISTADO_FICHEROS}"
		fi

	fi 

  done

  printf "\n\n###############################\n\n"
}

#función que cuenta los ficheros asignados a un equipo
num_ficheros()
{
	patron="Número de Ficheros asignados:"	#Indica final de ficheros repartidos para un equipo
	en_equipo=0
	while IFS= read -r line
	do
		line_num_fichero=$(printf "%s" "${line}" | grep "${patron}")
		if [ "${line}" = "Equipo ${PREFIJO_NOMBRE_EQUIPO}${i}:" ]; then
			en_equipo=1
		elif [ "${line}" = "${line_num_fichero}" -a "${en_equipo}" -eq 1 ]; then
			num_fichero=$(printf "%s" "${line}" | cut -d':' -f2 | sed 's/ //g')
			printf "%s" "${num_fichero}"
			break
		fi
	done < ${FICHERO_REPARTO}
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
			#echo "este es el equipo dentro de encuentra_equipos: ${equipo}"
		fi
		if [ "${line}" = "${fichero}" ];then
			printf "%s" "${equipo}"
			break
		fi
	done < ${FICHERO_REPARTO}
}

#rm -f "${FICHERO_SALIDA_ESTADO_OLD}"  1>/dev/null 2>&1
#mv "${FICHERO_SALIDA_ESTADO}" "${FICHERO_SALIDA_ESTADO_OLD}"  1>/dev/null 2>&1
#estado | tee "${FICHERO_SALIDA_ESTADO}"
# Borramos primera linea del fichero (caracteres extraños)
#sed -i '1d' "${FICHERO_SALIDA_ESTADO}"
estado

#Última actualización: Mon Apr 18 12:52:59 CEST 2022
#Equipo: lt05	(0/2)	Ejecutándose
#Equipo: lt06	(9/9)	Finalizada

printf "\n\nResultados de Estado guardados en el fichero:\n\n%s\n\n" "$(echo ${FICHERO_SALIDA_ESTADO} | rev | cut -d"/" -f1-2 | rev)"
