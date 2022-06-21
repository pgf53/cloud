#!/bin/sh

max_lines=160000

for i in "entrada/ficheros_entrada/"* ; do

num_lineas=$(wc -l "$i" | cut -d' ' -f1)
[ "${num_lineas}" -ge "${max_lines}" ] && mv "$i" entrada/ficheros_dividir

done
