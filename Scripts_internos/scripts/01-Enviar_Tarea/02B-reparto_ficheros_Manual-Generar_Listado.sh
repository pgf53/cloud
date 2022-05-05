#!/bin/sh

#Exportamos directorio de tarea
#export ${DIR_TAREA}
# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}



#funciones
#Recibe un número 'x' y crea un fichero de texto con los 'x'
#ficheros con mayor número de líneas.
#A partir de ese fichero, crea un directorio al que transfiere los 'x' 
#ficheros con mayor número de líneas
mayores_ficheros ()
{
wc -l "copia"/* | sort -n |tail -n $(($1+1)) | head -n $(($1)) > top.txt
sed -i 's/^ *//g' top.txt

while IFS= read -r input
do
	fichero=$(printf "%s %s" ${input} | awk '{print $2}')
	mv ${fichero} ficheros_top
done < top.txt
}

generar_listado ()
{
IMPRIMIR1="----------------------Resumen del reparto------------------------"
printf "%s\n\n" "${IMPRIMIR1}" > "${FICHERO_REPARTO}"

for equipo in "${DIR_ESTRUCTURA_CLONADA}"*
do
	if [ -d "${equipo}" -a "$(ls ${equipo}/${SUBDIR_TAREA_ENTRADA})" ]; then
		nombre_equipo=$(basename ${equipo})
		printf "%s\n" "Equipo ${nombre_equipo}:" >> "${FICHERO_REPARTO}"
		ls "${equipo}/${SUBDIR_TAREA_ENTRADA}" >> "${FICHERO_REPARTO}"
		num_lineas=$(wc -l "${equipo}/${SUBDIR_TAREA_ENTRADA}"* | tail -n 1 | awk '{print $1}')
		num_ficheros=$(ls "${equipo}/${SUBDIR_TAREA_ENTRADA}" | wc -l)
		printf "%s\n" "Número de líneas totales asignadas: ${num_lineas}" >> "${FICHERO_REPARTO}"
		printf "%s\n\n" "Número de Ficheros asignados: ${num_ficheros}" >> "${FICHERO_REPARTO}"
	fi
done

}

#Main

#####REPARTO SECUENCIAL
if [ "${REPARTO}" = "secuencial" ]; then
	#Comprobamos que el directorio contenga ficheros que repartir
	if [ "$(ls ${DIR_FICHEROS_REPARTIR})" ]; then
		numero_ficheros=$(ls "${DIR_FICHEROS_REPARTIR}" | wc -l)
		equipos_totales=$(ls "${DIR_ESTRUCTURA_CLONADA}" | wc -l)

		cociente=$(expr ${numero_ficheros} / ${equipos_totales})
		resto=$(expr ${numero_ficheros} % ${equipos_totales})
		copia_entrada="${DIR_TAREA_ENTRADA}copia_ficheros_entrada/"
		rm -rf "${copia_entrada}"
		cp -rf "${DIR_FICHEROS_REPARTIR}" "${copia_entrada}"

		contador=0
		for equipo in "${DIR_ESTRUCTURA_CLONADA}"*
		do
			for file in "${copia_entrada}"*
			do
				[ -z "${copia_entrada}" ] && break
				if [ "${contador}" -lt "${cociente}" ]; then
					mv "${file}" "${equipo}/${SUBDIR_TAREA_ENTRADA}"
					contador=$((contador+1))
				elif [ "${contador}" -eq "${cociente}" -a "${resto}" -gt 0 ]; then
					mv "${file}" "${equipo}/${SUBDIR_TAREA_ENTRADA}"
					contador=0
					resto=$((resto-1))
					break
				else
					contador=0
					break
				fi
			done
		done

		#Generamos fichero resumen con el reparto
		generar_listado

		#Borramos archivos temporales
		rm -rf ${copia_entrada}

	else 
		printf "No Hay ningún fichero que repartir. Se sale..."
		exit 1
	fi

#####REPARTO POR TAMAÑO
else
	if [ "$(ls ${DIR_FICHEROS_REPARTIR})" ]; then
		dir_ficheros="${DIR_FICHEROS_REPARTIR}"
		dir_equipos_clonados="${DIR_ESTRUCTURA_CLONADA}"
		dir_in_tarea="${SUBDIR_TAREA_ENTRADA}"
		contador=1
		recuento_fichero="recuento.txt"
		numero_ficheros=$(ls "${DIR_FICHEROS_REPARTIR}" | wc -l)

		#Obtenemos el número de equipos, para ello obtenemos los directorios presentes en 02-Estructura_Clonada/
		iteraciones_iniciales=$(find ${dir_equipos_clonados} -mindepth 1 -maxdepth 1 -type d | wc -l)
		[ "${numero_ficheros}" -lt "${iteraciones_iniciales}" ] && iteraciones_iniciales="${numero_ficheros}"

		rm -rf copia ficheros_top top.txt

		#Trabajaremos con una copia del directorio donde se encuentran los ficheros a repartir.
		cp -rf "${dir_ficheros}" "copia"

		#Directorio donde transferiremos los ficheros con mayor número de líneas.
		mkdir ficheros_top
		mayores_ficheros "${iteraciones_iniciales}"

		#Se asigna inicialmente un fichero a cada equipo. 
		#La asignación se efectúa en orden decreciente, es decir,
		#se asignan siempre los ficheros con mayor número de líneas
		#primero
		for i in "ficheros_top/"*
		do
			for j in "${dir_equipos_clonados}"*
			do
				if [ ! "$(ls ${j}/${dir_in_tarea})" ]; then
					mv "${i}" "${j}/${dir_in_tarea}"
					break
				fi
			done
		done

		#Comprobamos que exista algún fichero que repartir en el directorio "copia"
		if [ "$(ls copia/)" ]; then
			for i in "copia/"*
			do
				#Recorremos los equipos calculando el número de líneas asignadas
				for j in "${dir_equipos_clonados}"*
				do
					num_lineas=$(wc -l "${j}/${dir_in_tarea}"* | tail -n 1 | awk '{print $1}')
					printf "%s	%s\n" ${j} ${num_lineas} >> "${recuento_fichero}"
				done
				menor=$(awk '{print $2}' "${recuento_fichero}" | sort -n | head -n 1)

				#Obtenemos la linea con el equipo al que pertenece el menor número de líneas
				#Se usa 'head -n 1' por si existen varios equipos con numero de líneas coincidentes.
				equipo=$(awk -F"\t" -v menor="${menor}" '$2 == menor' ${recuento_fichero} | head -n 1 | awk '{print $1}')
				#Transfiero al directorio 'ficheros_top/' el fichero con mayor número de líneas en el directorio 'copia/'
				mayores_ficheros 1

				#Transfiero el fichero con mayor número de líneas al equipo que contiene el menor número de líneas
				mv "ficheros_top/"* "${equipo}/${dir_in_tarea}"
				numero_ficheros=$((numero_ficheros-1))
				rm -f ${recuento_fichero}
			done
		fi

		#Generamos fichero resumen con el reparto
		generar_listado
		#Borramos archivos temporales
		rm -rf ${recuento_fichero} copia ficheros_top top.txt
	else 
		printf "No Hay ningún fichero que repartir. Se sale..."
		exit 1
	fi
fi
