#!/bin/sh

#exportamos el directorio de 'cloud_config_interna.conf' y lo cargamos
export CLOUD_CONFIG_INTERNA="./Scripts_internos/scripts/cloud_config_interna.conf"
export INVOCACION="MENU_GLOBAL"
. ${CLOUD_CONFIG_INTERNA}


#opciones
respuesta=$(dialog --title "Menú Global" \
					--stdout \
					--menu "Selecciona una opción:" 0 0 0 \
					1 "Mostrar estado de los equipos" \
					2 "Crear Tarea" \
					3 "Borrar Tarea" \
					4 "Seleccionar Tarea" \
					5 "Mostrar Tareas" \
					6 "Lanzar escucha" \
					7 "Detener escucha")
#echo "Has elegido: $respuesta"

case ${respuesta} in

	1)
		"${SCRIPT_ESTADO_EQUIPOS}"
	;;
	2)	#Creación de Tarea
		respuesta=$(dialog --title "Nombre Tarea" \
							--stdout \
							--inputbox "Establezca un nombre para la tarea:" 0 0)

		if [ "${respuesta}" != "" ]; then

			# Carpetas a crear
			DIR_TAREA_NUEVA="./Tareas/${respuesta}"

			# Carpeta con estructuras modelo
			DIR_TAREA_MODELO="./Scripts_internos/esqueleto_tareas/"

			if [ -d "${DIR_TAREA_NUEVA}" ]; then
				dialog --title "Nombre Tarea" \
						--msgbox "No se ha podido crear la tarea. Ya existe una tarea con ese nombre." 0 0
			else
				cp -Rf "${DIR_TAREA_MODELO}" "${DIR_TAREA_NUEVA}"
				#Renombramos ficheros de configuración adaptándolos al nombre de la tarea
				mv "${DIR_TAREA_NUEVA}/cloud_tarea.conf" "${DIR_TAREA_NUEVA}/cloud_${respuesta}.conf"
				mv "${DIR_TAREA_NUEVA}/menu_tarea.sh" "${DIR_TAREA_NUEVA}/menu_${respuesta}.sh"
				mv "${DIR_TAREA_NUEVA}/entrada/software_tarea/" "${DIR_TAREA_NUEVA}/entrada/software_${respuesta}/"
				#Damos permisos a ficheros creados 
				chmod +x "${DIR_TAREA_NUEVA}/cloud_${respuesta}.conf"
				chmod +x "${DIR_TAREA_NUEVA}/menu_${respuesta}.sh"
				#Creada con éxito
				dialog --title "Nombre Tarea" \
						--msgbox "¡Tarea ${respuesta} creada con éxito!" 10 30
			fi
		else
			dialog --title "Nombre Tarea" \
			--msgbox "No se ha podido crear la tarea. El nombre de la tarea no puede estar vacío" 0 0
			exit 0
		fi
	;;
	3)	#Eliminación de Tarea
		dialog --title "Instrucciones" \
				--msgbox "Desplácese sobre la Tarea que desee Eliminar, a continuación pulse tecla 'space' y por último seleccione 'OK'" 0 0
		respuesta=$(dialog --title "Seleccione el directorio de la tarea a eliminar" \
							--stdout \
							--dselect Tareas/  14 70)
		if [ -d ${respuesta} ]; then
			dialog --title "Borrado de Tareas" \
					--yesno "Está seguro de que desea eliminar la tarea ubicada en: ${respuesta} " 0 0
			ans=$?
			if [ $ans -eq 0 ]; then
				DIR_TAREA_BORRAR="${respuesta}"
				rm -Rf "${DIR_TAREA_BORRAR}"
				dialog --title "Borrado" \
						--msgbox "${respuesta} Eliminado con éxito" 0 0
			fi
		else
			dialog --title "Error" \
				--msgbox "Error. No se encuentra la tarea: ${respuesta}" 0 0
		fi
	;;
	4)	#Selección de Tarea
		dialog --title "Instrucciones" \
				--msgbox "Desplácese sobre la Tarea que desee seleccionar, a continuación pulse tecla 'space' y por último seleccione 'OK'" 0 0
		respuesta=$(dialog --title "Selecciona el directorio de la tarea" \
							--stdout \
							--dselect Tareas/  14 70)
		if [ -d ${respuesta} ]; then
			tarea=$(basename ${respuesta})
			dialog --title "Tareas" --msgbox "Ha seleccionado la tarea: ${tarea}" 0 0
			${respuesta}/menu_${tarea}.sh
		else
			dialog --title "Error" \
					--msgbox "Error. No se encuentra la tarea: ${respuesta}" 0 0
		fi
	;;
	5)	#Muestra las Tareas existentes
		ls Tareas/ > /tmp/tareas.txt
		sed -i 's/ /\\n/g' /tmp/tareas.txt
		dialog --title "Tareas" \
				--textbox /tmp/tareas.txt 10 30
		rm -f /tmp/tareas.txt
	;;
	6)	#Lanza el demonio de escucha
		proceso=$(basename "${SCRIPT_MENSAJE_UDP}")
		existe_proceso=$(ps | grep "${proceso}")
		if [ "${existe_proceso}" = "" ]; then
			"${SCRIPT_LANZAR_ESCUCHA}" "01"
			[ "$?" -eq 0 ] && dialog --title "Demonio de escucha" \
									--msgbox "Proceso de escucha activado" 0 0
		else
			dialog --title "Demonio de escucha" \
									--msgbox "Proceso en ejecución" 0 0
		fi
	;;
	7)	#Detiene el demonio de escucha
		"${SCRIPT_PARAR_ESCUCHA}" "01"
	;;
esac



