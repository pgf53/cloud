# cloud

Software que permite el despliegue, ejecución y recogida de datos de una tarea en uno o varios equipos remotos. 

La tarea que haga uso de cloud debe cumplir los siguientes requisitos: 

+Debe poseer una estructura de manera que reciba uno/varios fichero/s de entrada y genere una/varias salida/s en base al análisis-procesado de el/los fichero/s de entrada.

+Cuando la tarea en cuestión finaliza con el análisis de una o más entradas, debe escribir en un fichero de texto vacío con el nombre de el/los ficheros de entrada ya procesados en el directorio 'entradas_finalizadas' creado automáticamente dentro del directorio raíz de la tarea en cuestión.

+Los resultados a recoger tendrán que almacenarse en un directorio que deberá indicarse en el fichero de configuración de la tarea.


Para crear una tarea sitúese en el directorio raíz de cloud y ejecute 'menu_global.sh'. Siga las instruccione del menú para finalizar la creación de la tarea. 

Una vez creada la estructura de la tarea, copie el software de su tarea en el directorio 'Tareas/nombre_tarea/entrada/software_tarea' e introduzca los ficheros de entrada en el directorio 'Tareas/nombre_tarea/entrada/ficheros_entrada/'.

Ejecute 'menu_tarea' desde 'menu_global.sh' o desde el directorio 'Tareas/nombre_tarea/menu_tarea.sh'. Siga las instrucciones proporcionadas por el menú en función de la acción que desee realizar.

IMPORTANTE: no olvide que para que la recogida automática de ficheros funcione, debe cumplir con el segundo de los requisitos especificados.

La herramienta cuenta con dos ficheros de configuración. 

+Scripts_internos/scripts/cloud_config_interna.conf: fichero de configuración interna de cloud donde se establecen las rutas de cloud, y algunos aspectos de su comportamiento.

+Tareas/nombre_tarea/cloud_nombre_tarea.conf: fichero específico para cada tarea con aspectos relativos a solo esa tarea. Ejemplo: equipos en los que desea desplegar la tarea.

