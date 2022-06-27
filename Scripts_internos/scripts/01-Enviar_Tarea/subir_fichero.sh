#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

printf "\n\n\n###########################\n\nSe procede al envío del fichero...\n"

for i in ${EQUIPOS_LT}; do

    printf "\n\n###### Equipo LT$i: ###########\n"

	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

	# Desplegar
	${SSH_COMANDO}  "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "${COMANDO_PRUEBA}" 2>/dev/null

done
