#!/bin/sh

# Cargar variables de configuracion
. ../config_interna.sh

eval "export TIPO_ESTADO=${ESTADO_CON_NUM_FICHEROS}; ${SCRIPT_ESTADO} \"${EQUIPOS_LT}\""

