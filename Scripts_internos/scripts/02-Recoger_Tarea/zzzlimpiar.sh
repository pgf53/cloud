#!/bin/sh

# Borrar ficheros de comparaciones

clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea LIMPIAR todas las carpetas LOCALES de \"Recogida\" de esta tarea (${NOMBRE_TAREA})... (Ctrl-C para Salir)"
read tecla


# Cargar rutas: Ajustar
RESULTADOS="${SUBDIR_LOCAL_RESULTADOS}"
EXTRAIDOS="${SUBDIR_LOCAL_RESULTADOS_DESCOMPRIMIDOS}"

clear

#### 

# Borar carpetas
rm -Rf ${RESULTADOS}

# Crear carpetas vacias
mkdir -p "${RESULTADOS}${EXTRAIDOS}"  2>&1 1>/dev/null
