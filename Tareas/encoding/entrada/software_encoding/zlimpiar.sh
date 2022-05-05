#!/bin/sh

# Borrar ficheros de comparaciones

# Cargar rutas: Ajustar
ENTRADA="./Entrada"
SALIDA="./Salida"

clear

#### 

# Borar carpetas
rm -Rf ${ENTRADA}
rm -Rf ${SALIDA}

# Crear carpetas vacias
mkdir -p ${ENTRADA}  2>&1 1>/dev/null
mkdir -p ${SALIDA}   2>&1 1>/dev/null
