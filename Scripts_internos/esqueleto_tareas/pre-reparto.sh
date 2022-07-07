#!/bin/sh

#Script que permite desplazar ficheros que superen el número establecido en la variable
#'max_line' al directorio de division de ficheros. 

max_lines=30000

for i in "entrada/ficheros_entrada/"* ; do

num_lineas=$(wc -l "$i" | cut -d' ' -f1)
[ "${num_lineas}" -ge "${max_lines}" ] && mv "$i" entrada/ficheros_dividir

done
