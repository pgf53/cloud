#!/bin/sh

#Script que muestra el número de veces que se repite una uri en el fichero de entrada 

#Formato básico
#cat fruit.txt | awk -F',' '{ tfruit[$2]++ } END { for ( fr in tfruit) { print tfruit[fr], fr } }'

FILE_IN="$1"
FILE_IN_NORMALIZED="$(basename ${FILE_IN%.*})-normalizado.uri"   #Fichero de salida
COUNT_URIS="$(basename ${FILE_IN%.*})-repetidas.uri"

#basic
cat "${FILE_IN}" | awk '{ turi[$1]++ } END { for ( uri in turi) { print turi[uri] "\t" uri } }' | awk -F'	' '$1 > 1 { print $1 "\t" $2 }' > 

#extended
#cat "${FILE_IN}" | awk -F'	' '{ tfruit[$2]++ } END { for ( fr in tfruit) { print tfruit[fr] "\t" fr } }' | awk -F'	' '$1 > 1 { print $1 "\t" $2 }'
#cat "${FILE_IN}" | awk -F'	' '{ turi[$2]++ } END { for ( uri in turi) { print turi[uri] "\t" uri } }' | awk -F'	' '$1 > 1 { print $1 "\t" $2 }'

#eliminamos duplicidades de fichero de entrada 
awk '!($0 in a) {a[$0];print}' "${FILE_IN}" > "${FILE_IN_NORMALIZED}"
