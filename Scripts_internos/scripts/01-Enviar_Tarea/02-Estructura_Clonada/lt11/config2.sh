#Variables a configurar para el lanzamiento y análisis de las uris

DIR_ROOT="/opt/integrador"	#Directorio raíz de la herramienta

#Salidas/Entradas
DIRIN_URI="01-Uri"	#Directorio con los ficheros de uris.
PATH_LOG="02-Log"	#Directorio con los Logs de los ficheros analizados.
DIROUT_INDEX="03-Index"	#Directorio donde se almacena el fichero resumen del procesado del log.
DIROUT_ATTACKS="04A-Attacks"	#Directorio donde se almacenan los ficheros con las uris detectadas como ataque.
DIROUT_CLEAN="04B-Clean"	#Directorio donde se almacenan los ficheros con las uris detectadas como limpias.

#Launcher
URIS_FORMAT="extended"	#Formato de las uris de entrada.	"basic": URI "extended": ID	URI
SERVERURL="http://lt04"	#IP del servidor contra la que se harán los lanzamientos. Necesario para tipo de lanzamiento "online-local"
SERVERURL_LOCAL="http://localhost"	#URL para lanzamiento local (permite especificar "http" o "https"). Usado en tipo de lanzamiento "online-local" y "offline"
LAUNCH_MODE="multiple"	# "1to1": para lanzamiento y análisis 1 a 1 de las uris. "multiple": para lanzamiento y procesado múltiple de las uris.
LAUNCH_TYPE="online-local"	#"online-local": lanza las uris contra detector ubicado en equipo local. "online-remoto": lanza las uris contra detector ubicado en equipo remoto. "offline": lanza las uris contra 							equipo local, no requiere la presencia de un servidor. 
API_SCRIPT="MLAv3_launcher.out"	#Utilizado en tipo "offline". Ruta del script de lanzamiento introducido por el usuario. 
PATH_ACCESS_LOG="/etc/httpd/logs/access_log"	#Requerida en lanzamiento de tipo "online". Ruta del registro de accesos al servidor. 


#Analyzer
ANALYZER_SCRIPT="2-analyzer.sh"	#Script de analizador de Log (introducido por el usuario) que generará el resumen de los ataques (".index") como resultado de procesar el log.
PATH_AUDIT_LOG="/var/log/httpd/modsec_audit.log"	#Ruta del registro de auditoría donde el detector escribe información sobre la uri lanzada si es considerada como ataque. [MLAv2 (online-local)] 
#PATH_AUDIT_LOG="/var/log/modsec_audit.log"	#Ruta del registro de auditoría donde el detector escribe información sobre la uri lanzada si es considerada como ataque [MLAv3 (offline)]

#Classify
OPTIONAL_COLUMNS="3 4"	#Columnas opcionales del fichero de resultados "*-info.attacks". Se generará un nuevo fichero "*-info_hide.attacks" que eliminará estos campos de los resultados.
HIDE_COLUMNS="yes"		#"yes" se ocultan las columnas opcionales. "no" se muestran todas las columnas de fichero "*-info.attacks"

#online-remoto
PASS="root"	#Contraseña de equipo remoto. Necesario si se emplea sshpass.
IP_EQUIPO_LOCAL="172.16.17.1"	#Dirección IP del equipo local
IP_REMOTE="172.16.17.2"	#IP del equipo remoto al que nos conectaremos.
USER_REMOTE="root"	#Usuario con el que accederemos a equipo remoto
DIR_REMOTE="/opt"	#Directorio de trabajo de equipo remoto donde se desplegarán los scripts de monitorización
BYOBU_SESSION="pedro"	#Nombre de la sesión byobu en la que trabajaremos

#Options 
NO_REPEAT="yes" #"yes" elimina las uris repetidas en el fichero de entrada y posteriormente recontruye la salida para obtener el mismo resultado que si se lanzase el fichero de entrada original.
				#Se realiza con el propósito de acelerar el anális omitiendo uris repetidas. "no" envía fichero uri de entrada original (con repeticiones si las hubiere).
NO_REPEAT_SCRIPT="remove_repeats.sh"	#Script usado para eliminar uris repetidas del fichero de entrada. En caso de que el formato de entrada sea "extended" solo se evaluará el campo de "uri"
										#Para catalogar una línea como repetida (se omite el campo ID en la comparación).
REBUILD_OUTPUT="rebuild_output.sh"	#Script de reconstrucción de la salida
FILE_IN_EXTENSION=".uri"	#Extensión del fichero de entrada que contiene las uris.
LOG_EXTENSION=".log"	#Extensión del fichero "log" generado por el detector empleado.
INDEX_EXTENTION=".index"	#Extensión del fichero resumen generado por el "analizador" como resultado de procesar el log.
INFO_ATTACKS_EXTENSION="-info.attacks"	#Extensión del fichero de ataques más detallado, generado como resultado de procesar el "index" y el fichero de entrada con las uris lanzadas.
INFO_ATTACKS_HIDE_EXTENSION="-info_hide.attacks"	#Mismo fichero que "-info.attacks" pero eliminando los campos seleccionados por el usuario.
ATTACKS_EXTENSION=".attacks"	#Fichero con las uris detectadas como ataque. Formato: Packet/ID	URI
CLEAN_EXTENSION=".clean"	#Fichero con las uris detectadas como limpias. Formato: Packet/ID	URI
DIR_TMP="/tmp"	#Fichero de trabajo temporal. Usado en tiempo de ejecución para almacenar temporalmente ciertos resultados.
DIR_TMP_FAST="/dev/shm"	#Igual que DIR_TMP pero usado en el almacenamiento de resultados más pequeños. El almacenarlos en memoria permite una mayor eficiencia en la ejecución.
LOCAL_MONITORIZATION_SCRIPT="monitoriza-local.sh"	#Script utilizado en LAUNCH_TYPE=online_local. Sirve para monitorizar el acceso de las uris al servidor.
REMOTE_SCRIPT="remoto.sh"	#Utilizado en LAUNCH_MODE=1to1. Script desplegado en equipo remoto que iniciará una sesión byobu y ejecutará REMOTE_MONITORIZATION_SCRIPT.
REMOTE_MULTIPLE_SCRIPT="remoto-multiple.sh"	#Utilizado en LAUNCH_MODE=multiple. Script desplegado en equipo remoto que iniciará una sesión byobu y ejecutará SEND_LOG_SCRIPT.
REMOTE_MONITORIZATION_SCRIPT="monitoriza-remoto.sh"	#Script utilizado en LAUNCH_TYPE=online_remoto. Sirve para monitorizar el acceso de las uris a un servidor ubicado en un equipo remoto.
LAUNCHER_SCRIPT="1-Launcher.sh"	#Script que lanzará contra un equipo determinado las uris presentes en el fichero de entrada.
CLASSIFY_SCRIPT="3-classify.py"	#Script que genera resumen final del análisis. Recibe como entrada el fichero de entrada y el fichero ".index" generado por el ANALYZER_SCRIPT.
SEND_LOG_SCRIPT="sendlogs.sh"	#Script utilizado en LAUNCH_MODE=multiple y LAUNCH_TYPE=online_remoto. Envía el log registrado de las uris lanzadas del equipo remoto al equipo local.
SSH_PASS="yes"	#yes: habilita el uso de sshpass. no: deshabilita el uso de sshpass (se usará ssh y scp en las conexiones remotas).
URI_START="Uri ["	#Patrón de inicio para obtener la uri del fichero de "index" generado por ANALYZER_SCRIPT.
URI_END="]"	#Patrón de fin para obtener la uri del fichero de "index" generado por ANALYZER_SCRIPT.
TIME_START="TimeStamp ["	#Patrón de inicio para obtener el TimeStamp del fichero de "index" generado por ANALYZER_SCRIPT.
TIME_END="]"	#Patrón de fin para obtener el TimeStamp del fichero de "index" generado por ANALYZER_SCRIPT.
PACKET="Packet"	#Identificador que precederá al campo "uri" cuando el formato de entrada es "basic". Se usará la posición que ocupa la uri en el fichero de entrada como el "número de paquete".
				#Formato Packet [x]	Uri
ID="ID"	##Identificador que precederá al campo "uri" cuando el formato de entrada es "extended". El id es único para URI. Formato: ID [x]	Uri
