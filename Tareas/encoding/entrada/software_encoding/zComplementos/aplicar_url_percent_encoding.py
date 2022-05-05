#!/usr/bin/python

import sys
import urllib

# URL encode

def aplicar_url_percent(cadena):
    """Recibe una cedana y la imprime deshaciendo el Percent Encoding"""

    print urllib.quote(cadena)


aplicar_url_percent(sys.argv[1])

