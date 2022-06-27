#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

printf "\n\n\n###########################\n\nSe procede a la descarga del fichero...\n"

for i in ${EQUIPOS_LT}; do

	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

    printf "\n\n###### Equipo LT$i: ###########\n"

	${SCP_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i:/${DESCARGAR_FICHERO_ORIGEN} "${DESCARGAR_FICHERO_DESTINO}"
	# Fichero descargado completamente?
	[ "$?" = "0" ] && printf "\n\n###### Éxito en la descarga del fichero ###########\n" || printf "\n\n###### Se produjo un Error durante la descarga ###########\n"
done
