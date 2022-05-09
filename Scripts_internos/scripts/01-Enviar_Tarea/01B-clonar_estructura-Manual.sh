#!/bin/sh

# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}

#funciones
#Comprueba que campos:
#NOMBRE_TAREA, SCRIPT_EJECUTAR, PROCESO_PARA_ESTADO
#No estén vacías
comprueba()
{
if [ "${NOMBRE_TAREA}" = "" -o "${SCRIPT_EJECUTAR}" = "" -o "${PROCESO_PARA_ESTADO}" = "" ]; then
	printf "No se ha podido clonar la tarea. Los campos 'NOMBRE_TAREA', 'SCRIPT_EJECUTAR', 'PROCESO_PARA_ESTADO' no pueden estar vacíos. Se sale..."
	exit 1
fi
}


clear

#Comprobamos valor de variables de cloud_config_interna
comprueba

# Comprobar si se han preparado la Estructura de la Tarea y los Ficheros a repartir (si no, salir)
SALIR=0
printf "\n\nComprobando requisitos...\n\n"
if [ ! "$(ls -A "${DIR_ESTRUCTURA_TAREA}")" ]; then
    printf "\n* ESTRUCTURA TAREA no copiada en:\t\t%s\n" "./$(printf "%s" "${DIR_ESTRUCTURA_TAREA}" | rev | cut -d"/" -f2 | rev)/"
    SALIR=1
fi
if [ ! "$(ls -A "${DIR_FICHEROS_REPARTIR}")" ]; then
    printf "\n* FICHEROS A REPARTIR no copiados en:\t\t%s\n" "./$(printf "%s" "${DIR_FICHEROS_REPARTIR}" | rev | cut -d"/" -f2 | rev)/"
    SALIR=1
fi

[ "${SALIR}" = "1" ] && { printf "\n\nSe sale...\n\n\n"; printf "1" > "${VAR_MEMORIA_SALIR}"; exit 1; }


# Limpiar carpeta de estructuras clonadas
rm -Rf    "${DIR_ESTRUCTURA_CLONADA}"                           1>/dev/null 2>&1

# Crear copia para cada equipo
clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea clonar los ficheros de la Tarea \"${NOMBRE_TAREA}\" para los equipos \"${EQUIPOS_LT}\"?." "Pulse una tecla para continuar... (Ctrl-C para Salir)"
[ "${FAST_MODE}" -eq 0 ] && read
for i in ${EQUIPOS_LT}; do
    printf "\n\n###### Creando copia para Equipo LT$i (Tarea \"${NOMBRE_TAREA}\") ###########\n"

    # Crear carpeta
    mkdir -p  "${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}$i" 1>/dev/null 2>&1

    # Copiar estructura
    cp -Rf    "${DIR_ESTRUCTURA_TAREA}"* "${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}$i"
done
