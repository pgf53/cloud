#!/usr/bin/python

import sys
import urllib

# URL decode

def deshacer_percent(cadena):
    """Recibe una cedana y la imprime deshaciendo el Percent Encoding"""

    print urllib.unquote_plus(cadena)



deshacer_percent(sys.argv[1])

