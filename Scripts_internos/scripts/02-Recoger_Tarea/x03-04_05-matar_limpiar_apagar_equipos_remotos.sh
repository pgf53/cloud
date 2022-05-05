#!/bin/sh

# Cargar variables de configuracion
. ../config_interna.sh

# Proceso completo de Recogida

clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea TERMINAR y LIMPIAR las carpetas del cluster de la tarea \"${NOMBRE_TAREA}\" en los equipos \"${EQUIPOS_LT}\", y APAGAR!! los equipos?" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

printf "\n\n###### LIMPIANDO y APAGANDO EQUIPOS REMOTOS ###########\n"

eval "printf \"%s\" \"\n\" | ${SCRIPT_MATAR}   \"${EQUIPOS_LT}\""

eval "printf \"%s\" \"\n\" | ${SCRIPT_LIMPIAR} \"${EQUIPOS_LT}\""

eval "printf \"%s\" \"\n\" | ${SCRIPT_APAGAR}  \"${EQUIPOS_LT}\""

printf "\n\n\n%s\n\n%s\n\n\n" "##############################################" "Limpiado completado. Puede usar el script de estado para comprobar el estado de los equipos"
