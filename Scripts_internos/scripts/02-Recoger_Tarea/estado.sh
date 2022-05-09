#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

#Funciones

#Evalua el estado de los equipos definidos en 'EQUIPOS_LT'
#genera fichero resumen 
evalua_equipos()
{
	for i in ${EQUIPOS_LT}; do
		if [ ! "$(hostname | grep "${PREFIJO_NOMBRE_EQUIPO}${i}")" ]; then
			printf "Equipo %s%s:\t" "${PREFIJO_NOMBRE_EQUIPO}${i}"

			#####  I) Identificacion ON/OFF #####
			ping -c 1 "${PREFIJO_NOMBRE_EQUIPO}$i" 1>/dev/null 2>&1
			[ "$?" = "0" ] && POWER="ON" || POWER="OFF"
			
			NO_IDENTIFICADO=" --- "
			printf "%s\n" "${POWER}"
			if [ "${POWER}" = "ON" ]; then

				#####  II) Comprobación de conexión ssh #####
				#Probamos acceso con certificado
				COMANDO_PRUEBA="echo ''"

				${SSH_COMANDO_CERTIFICADO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${COMANDO_PRUEBA}" 2>/dev/null
				if [ $? -eq 0 ]; then
					TIPO_ACCESO_SSH="${SSH_CERTIFICADO}"
					SSH_COMANDO="${SSH_COMANDO_CERTIFICADO}"
					crea_estado "${SSH_COMANDO}"
				else
					${SSH_COMANDO_KEY} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${COMANDO_PRUEBA}" 2>/dev/null
					if [ $? -eq 0 ]; then
						TIPO_ACCESO_SSH="${SSH_KEY}"
						SSH_COMANDO="${SSH_COMANDO_KEY}"
						crea_estado "${SSH_COMANDO}"
					else
						#Comprobamos puerto
						[ "$(nmap -p "${PUERTO_SSH}" ${PREFIJO_NOMBRE_EQUIPO}$i | grep closed)" ] && TIPO_ACCESO_SSH="${SIN_CONEXION_SERVICIO}" || TIPO_ACCESO_SSH="${SIN_CONEXION_CREDENCIALES}"
						printf "Equipo %s%s:\t%s\t%s\t%s\t%s\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${NO_IDENTIFICADO}" "${NO_IDENTIFICADO}" "${NO_DISPONIBLE}" "${TIPO_ACCESO_SSH}" >> "${FICHERO_SALIDA}"
					fi
				fi
				
			#Equipo apagado
			else
				printf "Equipo %s%s:\t%s\t%s\t%s\t%s: apagado o sin conexión\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${NO_IDENTIFICADO}" "${NO_IDENTIFICADO}" "${NO_DISPONIBLE}" >> "${FICHERO_SALIDA}"
			fi
		fi
	done
}


crea_estado()
{
	#####  III) Identificacion del SO #####
	SSH_COMANDO="$1"
	WINDOWS="Windows"
	LINUX="Linux"
	SEPARADOR="+++"
	SO=""

	# Probar si: Linux
	COMANDO='[ -e "/etc/fstab" ] && echo '"${SEPARADOR}${LINUX}${SEPARADOR}"

	if [ "$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${COMANDO}" 2>/dev/null)" = "${SEPARADOR}${LINUX}${SEPARADOR}" ]; then
		SO="${LINUX}"
		TIPO_SO="$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${CMD_SO_REMOTO}" 2>/dev/null)" || TIPO_SO="${NO_IDENTIFICADO}"

	# Probar si: Windows
	else
		COMANDO='if exist c:\Windows\ echo '"${SEPARADOR}${WINDOWS}${SEPARADOR}"
		# Ver caracteres no imprimibles:    cat -vfile
		# dos2unix para quitarlos (el ^M)
		[ "$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${COMANDO}" 2>/dev/null | dos2unix)" = "${SEPARADOR}${WINDOWS}${SEPARADOR}" ] && SO="${WINDOWS}"
	fi

	if [ -z "${SO}" ]; then 
		printf "Equipo %s%s:\t%s\t%s\t%s\t%s: SO no reconocido\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${NO_IDENTIFICADO}" "${NO_IDENTIFICADO}" "${NO_DISPONIBLE}" "${TIPO_ACCESO_SSH}" >> "${FICHERO_SALIDA}" 

	else
		#so_compatible=$(printf "%s" "${SO_COMPATIBLES}" | grep "${SO}")
		if [ "$(printf "%s" "${SO_COMPATIBLES}" | grep -i "${SO}")" != "" ]; then
			if [ "$(printf "%s" "${TIPO_SO_COMPATIBLES}" | grep -i "${TIPO_SO}")" != "" ]; then
				#COMPROBAMOS ESCRITURA EN CARPETA REMOTA
				COMANDO_PERMISO="printf Test > ${CARPETA_TAREA}Test"
				${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${COMANDO_PERMISO}" 2>/dev/null
				PERMISO=$?
				if [ "${PERMISO}" -ne 0 ]; then
					printf "Equipo %s%s:\t%s\t%s\t%s\t%s\t%s\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${SO}" "${TIPO_SO}" "${NO_DISPONIBLE}" "${TIPO_ACCESO_SSH}" "${CARPETA_SOLO_LECTURA}" >> "${FICHERO_SALIDA}"
				else
					#SI RESPUESTA="" ESTAMOS EN GENERACIÓN GLOBAL DE ESTADOS (DESDE MENÚ GLOBAL)
					if [ "${respuesta}" = "" ]; then
						comprueba_capacidad
					#SI RESPUESTA!="" ESTAMOS EN UNA TAREA
					else
						comprueba_capacidad
						diagnostico_capacidad=$(awk -v busqueda="${PREFIJO_NOMBRE_EQUIPO}${i}:" -F"\t" 'BEGIN{FS=OFS="\t"} $0 ~ busqueda {print $5}' "${FICHERO_SALIDA}")
						[ "${diagnostico_capacidad}" = "${DISPONIBLE}" ] && comprueba_existe_tarea
					fi
				fi
			else
				printf "Equipo %s%s:\t%s\t%s\t%s\t%s: Versión SO incompatible\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${SO}" "${TIPO_SO}" "${NO_DISPONIBLE}" "${TIPO_ACCESO_SSH}" >> "${FICHERO_SALIDA}"

			fi
		else
			printf "Equipo %s%s:\t%s\t%s\t%s\t%s: SO incompatible\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${SO}" "${TIPO_SO}" "${NO_DISPONIBLE}" "${TIPO_ACCESO_SSH}" >> "${FICHERO_SALIDA}"
		fi
	fi
}


#Recibe fichero y añade en primera línea la fecha 
#y hora actual
add_last_update()
{
	OUTPUT_FILE="$1"
	actualizacion=$(printf "Última actualización: %s" "$(date)")
	fecha=$(grep "Última actualización:" ${OUTPUT_FILE})
	[ "${fecha}" != "" ] && sed -i "s/^Última actualización.*/${actualizacion}/g" "${OUTPUT_FILE}" || sed -i "1i${actualizacion}\n" "${OUTPUT_FILE}"
}


#Determina si un equipo es apto en función
#de su capacidad
comprueba_capacidad()
{
	COMANDO_CAPACIDAD="df -m ${CARPETA_TAREA} | sed -e \"s/  */\t/g\" | tail -1"
	CAPACIDAD_EQUIPO_REMOTO="$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${COMANDO_CAPACIDAD}" | awk '{print $4}' 2>/dev/null)"

	#VERIFICAMOS CAPACIDAD DEL EQUIPO REMOTO
	#RESPUESTA=1 DESCARTAMOS EQUIPO
	if [ "${CAPACIDAD_EQUIPO_REMOTO}" -lt "${CARPETA_TAREA_UMBRAL_MINIMO}" -a "${respuesta_capacidad}" -eq 1 ]; then
		CARPETA_CAPACIDAD_KO="[Carpeta Tarea ESPACIO insuficiente: ${CAPACIDAD_EQUIPO_REMOTO} MB < ${CARPETA_TAREA_UMBRAL_MINIMO} MB]"
		printf "Equipo %s%s:\t%s\t%s\t%s\t%s\t%s\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${SO}" "${TIPO_SO}" "${NO_DISPONIBLE}" "${TIPO_ACCESO_SSH}" "${CARPETA_CAPACIDAD_KO}" >> "${FICHERO_SALIDA}"

	#RESPUESTA=2 CONTINUAMOS EJECUCIÓN
	elif [ "${CAPACIDAD_EQUIPO_REMOTO}" -lt "${CARPETA_TAREA_UMBRAL_MINIMO}" -a "${respuesta_capacidad}" -eq 2 ]; then
		CARPETA_CAPACIDAD_OK="[Carpeta Tarea con poco espacio: ${CAPACIDAD_EQUIPO_REMOTO} MB < ${CARPETA_TAREA_UMBRAL_MINIMO} MB]"
		printf "Equipo %s%s:\t%s\t%s\t%s\t%s\t%s\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${SO}" "${TIPO_SO}" "${DISPONIBLE}" "${TIPO_ACCESO_SSH}" "${CARPETA_CAPACIDAD_OK}" >> "${FICHERO_SALIDA}"

	else
		printf "Equipo %s%s:\t%s\t%s\t%s\t%s\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${SO}" "${TIPO_SO}" "${DISPONIBLE}" "${TIPO_ACCESO_SSH}" >> "${FICHERO_SALIDA}"
	fi
}

#Comprueba que si la tarea ha sido 
#desplegada con anterioridad y determina
#su disponibilidad en base a eso.
comprueba_existe_tarea()
{

	#Siempre en este punto existe información del equipo.
	#Dicha informacin ha sido generada por 'comprueba_capacidad'.
	linea_equipo=$(awk -v busqueda="${PREFIJO_NOMBRE_EQUIPO}${i}:" -F"\t" 'BEGIN{FS=OFS="\t"} $0 ~ busqueda {print $0}' "${FICHERO_SALIDA}")

	#Examinamos direcotorio remoto
	COMANDO_DIRECTORIO="[ -d ${DIR_REMOTO_ENVIO} ] && ls ${DIR_REMOTO_ENVIO}"
	directorio_remoto=$(${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${COMANDO_DIRECTORIO}" 2>/dev/null)

	#RESPUESTA=1. DESCARTAMOS EQUIPO SI EXISTE TAREA REMOTA
	if [ "${respuesta}" -eq 1 ]; then
		if [ "${directorio_remoto}" != "" ]; then
			nueva_linea=$(printf "Equipo %s%s:\t%s\t%s\t%s\t%s\t%s\t%s\n" "${PREFIJO_NOMBRE_EQUIPO}" "${i}" "${POWER}" "${SO}" "${TIPO_SO}" "${NO_DISPONIBLE}" "${TIPO_ACCESO_SSH}" "${CARPETA_EXISTENTE_1}")
			sed -i "s/${linea_equipo}/${nueva_linea}/g" "${FICHERO_SALIDA}"
		fi

	#RESUPESTA=2. ELIMINAMOS DIRECTORIO DE TAREA REMOTA SI EXISTE
	else
		if [ "${directorio_remoto}" != "" ]; then
			sed -i "s/${linea_equipo}/${linea_equipo}\t${CARPETA_EXISTENTE_2}/g" "${FICHERO_SALIDA}"
		fi
	fi
}

#Crea el estado de la Tarea a partir 
#del estado inicial de los equipos
crea_estado_tarea()
{
	while IFS= read -r line
	do
		disponible=$(printf "%s" "${line}" | sed "s#.*\t${DISPONIBLE}\t.*#equipo_disponible#g")
		if [ "${disponible}" = "equipo_disponible" ]; then
			equipo=$(printf "%s" "${line}" | cut -d':' -f'1' | cut -d' ' -f'2')
			#Disponible OK. ¿Tiene ficheros asignados? (caso num_ficheros < num_equipos)
			if [ "$(ls ${DIR_ESTRUCTURA_CLONADA}${equipo}/${SUBDIR_TAREA_ENTRADA})" ]; then
				num_ficheros_asignados=$(ls "${DIR_ESTRUCTURA_CLONADA}${equipo}/${SUBDIR_TAREA_ENTRADA}" | wc -l)
				#info_tarea="(0/${num_ficheros_asignados})\t${EJECUTANDOSE}"
				#linea_estado_tarea="${line}\t${info_tarea}"
		 		printf "%s\t(0/%s)\t%s\n" "${line}" "${num_ficheros_asignados}" "${EJECUTANDOSE}" >> "${FILE_ESTADO}"
			fi
		fi
	done < "${FILE_ESTADO_EQUIPOS_INICIAL}"
}

#Genera resumen de los equipos examinados
#Recibe como argumento el fichero de estado
#donde se generará el resumen
resumen_equipos_iniciales()
{
	FICHERO_RESUMEN="$1"
	num_lineas_estado=$(wc -l "${FICHERO_RESUMEN}" | cut -d' ' -f'1')
	EQUIPOS_ANALIZADOS=$((num_lineas_estado))
	EQUIPOS_DISPONIBLES=$(awk -v equipo_disponible="${DISPONIBLE}" 'BEGIN{FS=OFS="\t"} $5==equipo_disponible {print $1}' ${FICHERO_RESUMEN} | wc -l)
	EQUIPOS_NO_DISPONIBLES=$(grep "${NO_DISPONIBLE}" "${FICHERO_RESUMEN}" | wc -l)
	RESUMEN=$(printf "Equipos analizados [%s]\tEquipos Disponibles [%s]\tEquipos NO disponibles [%s]" "${EQUIPOS_ANALIZADOS}" "${EQUIPOS_DISPONIBLES}" "${EQUIPOS_NO_DISPONIBLES}")
	sed -i "1i${RESUMEN}\n" "${FICHERO_RESUMEN}"
}

#Genera el resumen del progreso de los equipos
resumen_estado_equipos()
{
	contador=0
	while IFS= read -r line
	do
		en_equipo=$(printf "%s" "${line}" | grep "Equipo")
		[ "${en_equipo}" != "" ] && contador=$((contador+1))
	done < "${FILE_ESTADO}"

	TOTAL_EQUIPOS="${contador}"
	RESUMEN_PROGRESO="PROGRESO: (0/${TOTAL_EQUIPOS}) EQUIPOS FINALIZADOS"
	sed -i "1i${RESUMEN_PROGRESO}\n" "${FILE_ESTADO}"
}

#############MAIN###############
#Distinguimos invocaciones desde tres puntos: 
#1 Menú global de Cloud para crear mapa de estado de los equipos
#2 Antes de la ejecución de una Tarea
#3 Para crear/actualizar el estado de una Tarea

#############1º Invocación menú global###############
#Creamos mapa de estado
if [ "${INVOCACION}" = "MENU_GLOBAL" ]; then
	rm -f "${FILE_ESTADO_EQUIPOS}"
	if [ "${ANTE_ESPACIO_CARPETA_INFERIOR_UMBRAL}" -eq 0 ]; then
		respuesta_capacidad=$(dialog --title "Gestión de la capacidad" \
							--stdout \
							--menu "Ante la posibilidad de presentar poco espacio en el equipo remoto, por favor, seleccione una de las opciones." 0 0 0 \
							1 "Descartar equipo" \
							2 "Proseguir")
	else
		respuesta_capacidad="${ANTE_ESPACIO_CARPETA_INFERIOR_UMBRAL}"
	fi
	FICHERO_SALIDA="${FILE_ESTADO_EQUIPOS}"
	evalua_equipos
	#Añadimos recuento de los equipos
	resumen_equipos_iniciales "${FILE_ESTADO_EQUIPOS}"
	add_last_update "${FILE_ESTADO_EQUIPOS}"

#############2º Comprobación previa al lanzamiento###############
#Realizamos comprobación de equipos antes del lanzamiento
elif [ "${INVOCACION}" = "MENU_TAREA_LANZAMIENTO" ]; then
	rm -f "${FILE_ESTADO_EQUIPOS_INICIAL}"
	if [ "${ANTE_CARPETA_TAREA_EXISTE}" -eq 0 ]; then
		respuesta=$(dialog --title "Menú ${NOMBRE_TAREA}" \
							--stdout \
							--menu "Ante la presencia de datos de la tarea en el equipo cliente, por favor, seleccione una de las opciones." 0 0 0 \
							1 "Descartar equipo" \
							2 "Borrar carpeta existente")
	else
		respuesta="${ANTE_CARPETA_TAREA_EXISTE}"
	fi
	if [ "${ANTE_ESPACIO_CARPETA_INFERIOR_UMBRAL}" -eq 0 ]; then
		respuesta_capacidad=$(dialog --title "Gestión de la capacidad" \
							--stdout \
							--menu "Ante la posibilidad de presentar poco espacio en el equipo remoto, por favor, seleccione una de las opciones." 0 0 0 \
							1 "Descartar equipo" \
							2 "Proseguir")
	else
		respuesta_capacidad="${ANTE_ESPACIO_CARPETA_INFERIOR_UMBRAL}"
	fi
	FICHERO_SALIDA="${FILE_ESTADO_EQUIPOS_INICIAL}"
	evalua_equipos
	#Añadimos recuento de los equipos
	resumen_equipos_iniciales "${FILE_ESTADO_EQUIPOS_INICIAL}"
	#Añadimos fecha y hora
	add_last_update "${FILE_ESTADO_EQUIPOS_INICIAL}"

#############3º Crear/actualizar estado de una tarea###############
#Creamos en el lanzamiento y actualizamos el estado en las recogidas
#y consultas. Existen tres casos:

#3.1 Invocación desde fase de lanzamiento: creación 'estado_tarea'
elif [ "${INVOCACION}" = "CREA_ESTADO_TAREA" ]; then
	rm -f "${FILE_ESTADO}"
	#Crearemos fichero 'estado_tarea.txt' a partir de 'estado_equipos_inicial.txt'
	#Omitiendo equipos no disponibles.
	crea_estado_tarea
	if [ -f "${FILE_ESTADO}" ]; then 
		resumen_estado_equipos
		add_last_update "${FILE_ESTADO}"
	fi

#3.2 Invocación debida a recogida
elif [ "${INVOCACION}" = "ACTUALIZA_ESTADO_TAREA_RECOGIDA" ]; then
	#Actualizamos estado por recogida
	FIN=0
	busqueda="Equipo ${equipo}:"
	linea_equipo=$(awk -v busqueda="${busqueda}" -F"\t" 'BEGIN{FS=OFS="\t"} $0 ~ busqueda {print $0}' "${FILE_ESTADO}")
	progreso_total=$(printf "%s" "${linea_equipo}" | awk  -F"\t" 'BEGIN{FS=OFS="\t"} {print $(NF-1)}' | cut -d'/' -f'2' | cut -d')' -f'1')
	update_progress="(${progreso}/${progreso_total})"
	if [ "${progreso}" -lt "${progreso_total}" ]; then
		linea_actualizada=$(printf "%s" "${linea_equipo}" | awk -v update_progress="${update_progress}" -F"\t" 'BEGIN{FS=OFS="\t"} {$(NF-1)=update_progress; print}')
	else
		linea_actualizada=$(printf "%s" "${linea_equipo}" | awk -v update_progress="${update_progress}" -v estado="${FINALIZADA}" -F"\t" 'BEGIN{FS=OFS="\t"} {$(NF-1)=update_progress;$NF=estado;print}')
		FIN=1
	fi
	#para que 'sed' no interprete []
	linea_equipo=$(printf "%s" "${linea_equipo}" | sed -e "s#\[#\\\[#g" -e "s#\]#\\\]#g")
	linea_actualizada=$(printf "%s" "${linea_actualizada}" | sed -e "s#\[#\\\[#g" -e "s#\]#\\\]#g")
	sed -i "s#${linea_equipo}#${linea_actualizada}#g" "${FILE_ESTADO}"
	if [ "${FIN}" -eq 1 ]; then
		finalizados=$(awk -v estado_finalizado="${FINALIZADA}" 'BEGIN{FS=OFS="\t"} $0 ~ estado_finalizado {print $NF}' "${FILE_ESTADO}" | wc -l)
		num_total_equipos=$(grep "PROGRESO:" estado/estado_framework.txt | cut -d'/' -f'2' | cut -d')' -f1)
		sed -i "s#PROGRESO:.*#PROGRESO: (${finalizados}/${num_total_equipos}) EQUIPOS FINALIZADOS#g" "${FILE_ESTADO}"
	fi
	add_last_update "${FILE_ESTADO}"
fi
