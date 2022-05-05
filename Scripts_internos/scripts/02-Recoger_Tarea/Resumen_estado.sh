#!/bin/sh

# Cargar variables de configuracion
. ../config_interna.sh


printf "%s\n" "COMPROBANDO ESTADO DE ${NOMBRE_TAREA} EN LOS EQUIPOS"
for i in ${EQUIPOS_LT}; do
	${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "cd ${DIR_REMOTO_ENVIO_DESCOMP};  ./${SCRIPT_ESTADO_PEDRO} ${NOMBRE_TAREA}"
done

#Borramos el fichero anterior
rm -f "${FILE_ESTADO_PEDRO}"

#Una vez tenemos los ficheros de cada equipo individual
for i in "${SUBDIR_LOCAL_RESULTADOS}"*.txt; do
	cat "${i}" >> "${FILE_ESTADO_PEDRO}"
	rm -f "${i}"
done

