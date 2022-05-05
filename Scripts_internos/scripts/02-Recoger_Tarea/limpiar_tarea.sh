#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

printf "\n\n%s\n" "¿Seguro que desea ELIMINAR el estado y las salidas de la tarea \"${NOMBRE_TAREA}\" de los equipos \"${EQUIPOS_LT}\"?"
printf "\n%s\n\n" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

#Directorio de la tarea estado/
rm -rf "${SUBDIR_LOCAL_RESULTADOS_ESTADO}"* 1>/dev/null 2>&1

#Directorio de la tarea salida/
rm -f "${SUBDIR_LOCAL_RESULTADOS_COMPRIMIDOS}"* 1>/dev/null 2>&1
rm -rf "${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}"* 1>/dev/null 2>&1

[ $? -eq 0 ] && printf "Tarea limpiada con éxito\n"
