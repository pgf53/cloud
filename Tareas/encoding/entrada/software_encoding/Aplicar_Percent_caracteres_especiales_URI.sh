#!/bin/sh

if [ $# -ne 0 ]; then
    echo Sin argumentos
    exit 1
fi


DIRIN="./Entrada/"
[ -d  "${DIRIN}" ] || { echo "No existe el directorio de entrada \"${DIRIN}\". Se sale..." && exit 1; }


DIROUT="./Salida/"
rm -Rf "${DIROUT}"  2>&1 1>/dev/null
mkdir -p ${DIROUT}  2>&1 1>/dev/null

clear

for i in "${DIRIN}"* ; do
    SALIDA="${DIROUT}${i##*/}"
    printf "\nProcesando: ${i}\n"

    # Aplicar Percent Encoding a: Espacios ' ' -> %20
    sed -e 's/ /%20/g' -e 's/!/%21/g' -e 's/#/%23/g' -e 's/$/%24/g' -e 's/\&/%26/g' -e "s/'/%27/g" -e 's/(/%28/g' -e 's/)/%29/g' -e 's/@/%40/g' "${i}" > "${SALIDA}"
done

