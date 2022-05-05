#!/bin/sh

if [ $# -ne 0 ]; then
    echo Sin argumentos
    exit 1
fi



SCRIPTS_COMPLEMENTARIOS="./zComplementos/"


DIRIN="./Entrada/"
[ -d  "${DIRIN}" ] || { echo "No existe el directorio de entrada \"${DIRIN}\". Se sale..." && exit 1; }

DIROUT="./Salida/"
rm -Rf "${DIROUT}"  2>&1 1>/dev/null
mkdir -p ${DIROUT}  2>&1 1>/dev/null

#Temporales
TMP="/dev/shm/file.tmp"


# Para cada fichero de entrada
for file in "${DIRIN}"*; do
    SALIDA="${DIROUT}${file##*/}"
    printf "\nProcesando: ${file}\n"

    rm -Rf "${TMP}"  2>&1 1>/dev/null
    > "${TMP}"

    # Aplicar el Percent Encoding línea a línea
    while read -r linea; do
	printf "%s\n" "$(${SCRIPTS_COMPLEMENTARIOS}aplicar_url_percent_encoding.py "${linea}")" >> "${TMP}"
    done < "${file}"

    mv "${TMP}" "${SALIDA}"

	#Generamos salida de fichero procesado.
	nombre_fichero=$(basename "${file}")
	touch "entradas_finalizadas/${nombre_fichero}"
done

rm -Rf ${TMP}  2>&1 1>/dev/null
