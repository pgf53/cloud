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

    #rm -Rf "${TMP}"  2>&1 1>/dev/null
    > "${TMP}"
    
    NTOTAL_ENTRADAS="$(wc -l "${file}" | cut -f1 -d " ")"

    lineaDetectorActual=0
    # Deshacer el Percent Encoding línea a línea
    while read -r linea; do
	   printf "A: %s\n" "$linea"
	   printf "B%s\n" "${SCRIPTS_COMPLEMENTARIOS}undo_percent_encoding.py "${linea}""
	   printf "%s\n" "$(${SCRIPTS_COMPLEMENTARIOS}undo_percent_encoding.py "${linea}")" >> "${TMP}"

	   # Imprimimos en pantalla la linea del detector (uri) que esta actualmente siendo analizada (progreso)
	   lineaDetectorActual=$((lineaDetectorActual+1))		# Incrementamos contador de lectura
	   printf "\r                                                                        "
	   printf "\rLinea: %s/%s"  "${lineaDetectorActual}"  "${NTOTAL_ENTRADAS}"

    done < "${file}"

    mv "${TMP}" "${SALIDA}"
done

rm -Rf ${TMP}  2>&1 1>/dev/null
