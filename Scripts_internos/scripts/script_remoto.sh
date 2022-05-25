#!/bin/sh

# Script ejecutado en equipo remoto en el que lanzar la tarea
. ./cloud_config_interna.conf


EQUIPO="$1"

# Descomprimir fichero analisis
rm -Rf   "${DIR_REMOTO_ENVIO_DESCOMP}" 1>/dev/null 2>&1
mkdir -p "${DIR_REMOTO_ENVIO_DESCOMP}" 1>/dev/null 2>&1
tar xfvz "${PREFIJO_NOMBRE_EQUIPO}${EQUIPO}${EXT_FILE_ANALISIS}" -C "${DIR_REMOTO_ENVIO_DESCOMP}"

# Creamos directorio de 'entradas_finalizadas' para recogida automática
mkdir -p "${DIR_REMOTO_ENTRADAS_FINALIZADAS}" 1>/dev/null 2>&1


# Ejecutar analisis
printf "\nEjecutando tarea "${NOMBRE_TAREA}"...\n"
printf "\nPara acceder a sesion: \"byobu\" (MonoTarea) o \"byobu attach-session -t ${NOMBRE_TAREA}\" (MultiTarea, \"byoby list-sessions\")\n"
printf "\nNOTA: Salir de \"byobu\" con \"F6\" y de \"SSH\" con \"exit\"...\n\n\n"

byobu new-session -s "${NOMBRE_TAREA}_${SESION_BYOBU_MONITORIZA_SALIDA}" -d "./${FILE_SCRIPT_MONITORIZA_SALIDA}"
byobu new-session -s "${NOMBRE_TAREA}" -d "cd ${DIR_REMOTO_EJECUCION}; ./${SCRIPT_EJECUTAR}"
