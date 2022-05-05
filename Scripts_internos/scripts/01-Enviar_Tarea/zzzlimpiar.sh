#!/bin/sh

# Borrar ficheros de comparaciones

clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea LIMPIAR todas las carpetas LOCALES de \"Envio\" de esta tarea (${NOMBRE_TAREA})... (Ctrl-C para Salir)"
read tecla


# Cargar rutas: Ajustar
ENTRADA1="${DIR_ESTRUCTURA_TAREA}"
ENTRADA2="${DIR_FICHEROS_REPARTIR}"
ENTRADA3="${DIR_ESTRUCTURA_CLONADA}"
ENTRADA4="${DIR_FILE_ANALISIS}"

clear

#### 

# Borar carpetas
rm -Rf ${ENTRADA1}
rm -Rf ${ENTRADA2}
rm -Rf ${ENTRADA3}
rm -Rf ${ENTRADA4}

# Crear carpetas vacias
mkdir -p ${ENTRADA1}  2>&1 1>/dev/null
mkdir -p ${ENTRADA2}  2>&1 1>/dev/null
mkdir -p ${ENTRADA3}  2>&1 1>/dev/null
mkdir -p ${ENTRADA4}  2>&1 1>/dev/null
