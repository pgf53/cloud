#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

#Determinamos el tipo de acceso SSH
. "${SCRIPT_CHECK_SSH}" "${i}"


clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea APAGAR los equipos \"${EQUIPOS_APAGAR}\"?" "Pulse una tecla para continuar... (Ctrl-C para Salir)"
read tecla

for i in ${EQUIPOS_APAGAR}; do
    printf "\n\n###### APAGANDO EQUIPOS ###########\n"

    # Lista de sesiones byobu:  byobu list-sessions
    printf "\n%s" "Equipo ${PREFIJO_NOMBRE_EQUIPO}$i...  "
    ${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "poweroff"
done
printf "\n\n\n%s\n\n%s\n\n\n" "##############################################" "Puede usar el script de estado para comprobar el estado de los equipos"
