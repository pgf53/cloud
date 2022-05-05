#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

printf "\n\n%s\n" "¿Seguro que desea ELIMINAR los Estados de la tarea \"${NOMBRE_TAREA}\" de los equipos \"${EQUIPOS_LT}\"?"
printf "\n%s\n\n" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

rm -rf "${SUBDIR_LOCAL_RESULTADOS_ESTADO}"* 1>/dev/null 2>&1
[ $? -eq 0 ] && printf "Directorio limpiado con éxito\n"
