#!/bin/sh

# Cargar variables de configuracion
. ../config_interna.sh


clear
printf "\n\n%s\n" "¿Seguro que desea ENCENDER los equipos \"${EQUIPOS_LT}\"?"
printf "\n%s\n\n" "NOTA: Se recomienda, ANTES, programar en OpenGnSys el SO a arrancar!!"
printf "\n%s\n" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

for i in ${EQUIPOS_LT}; do
    printf "\n\n###### ENCENDIENDO EQUIPOS REMOTOS ###########\n"

    # Lista de sesiones byobu:  byobu list-sessions
    printf "\n%s" "Equipo ${PREFIJO_NOMBRE_EQUIPO}$i...  "
    wol $i
done
printf "\n\n\n%s\n\n%s\n\n\n" "##############################################" "Puede usar el script de estado para comprobar el estado de los equipos"
