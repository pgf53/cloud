#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

printf "\n\n\n###########################\n\nEjecutando comando...\n"

for i in ${EQUIPOS_LT}; do

    printf "\n\n###### Equipo LT$i: ###########\n"

	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

	# Ejecutar
	while IFS= read -r comando
	do
		${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${comando}" 2>/dev/null
	done < "${FILE_COMANDOS_REMOTOS}"

done
