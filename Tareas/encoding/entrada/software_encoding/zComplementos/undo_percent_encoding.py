#!/usr/bin/python

import sys
import urllib

# URL decode

def deshacer_percent(cadena):
    """Recibe una cedana y la imprime deshaciendo el Percent Encoding"""

    print "C"+sys.argv[1]
    print urllib.unquote(cadena)



deshacer_percent(sys.argv[1])

