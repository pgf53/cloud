#!/bin/sh

# Cargar variables de configuracion
. ../config_interna.sh


# Proceso completo de Envio

clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea CLONAR + REPARTIR + ENVIAR + LANZAR esta tarea \"${NOMBRE_TAREA}\" en los equipos \"${EQUIPOS_LT}\"... (Ctrl-C para Salir)"
read tecla


eval "printf \"\n\" | . \"${SCRIPT_REPARTIR_AUTO}\" \"${EQUIPOS_LT}\""
[ "$(head -1 ${VAR_MEMORIA_SALIR})" = "1" ] && exit 1				# Paso de variable de hijo a padre
eval "printf \"\n\" | . \"${SCRIPT_ENVIO}\"         \"${EQUIPOS_LT}\""
eval "printf \"\n\" | . \"${SCRIPT_LANZAR}\"        \"${EQUIPOS_LT}\""
