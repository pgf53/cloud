#########PRUEBA DE ESTADO DE LOS EQUIPOS#############

Prueba consistente en comprobar la correcta detección del estado de los equipos del laboratorio.

Para esta prueba hemos añadido como equipos a evaluar los equipos del 1 al 28.

Consideraciones a tener en cuenta:

-Hemos accedido a los equipos haciendo uso del usuario 'root' y contraseña (cuando no hacemos 
uso de certificado) 'root'.

-Los SO soportados son 'Linux' y las etiquetas permitidas 'linux1'.

-Equipo lt07 hace uso de Windows y solo existe el usuario 'dit'.

-Se ha fijado una memoria umbral de 10 GB que equipo lt28 no cumple. No obstante se ha establecido que se continúe.

-Equipo lt03 sin certificado. Accesible mediante clave 'root'

-Equipo lt04 es el servidor (no se tiene en cuenta).

-Equipo lt05 sin certificado y con contraseña diferente a la fijada en la configuracion interna.

-Equipo lt06 puerto SSH fijado en config interna cerrado.

-Equipos 29 y 30 no existen en la red del laboratorio.

-Equipos 02 09-20 y 22-28 accesibles y cumplen condiciones de configuración interna.

Nota: el equipo lt07 aparece como inaccesible puesto que se intenta acceder con usuario 'root' y no dispone de este usuario.
