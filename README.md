## MENÚ Y GENERALES
```bash
#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo -e "${R}Por favor, ejecuta este script como root.${NOCOLOR}"
	exit
fi

R='\033[0;31m' # Rojo
G='\033[0;32m' # Verde
B='\033[0;34m' # Azul
NOCOLOR='\033[0m'

while true; do
	toilet -S supermegaincreible script molon de ibai -f pagga -w 75
	echo -e "${B}==========================================================================${NOCOLOR}"
	echo -e "${B}------ Menú ------${NOCOLOR}"
	echo -e "${B}1. Saludar${NOCOLOR}"
	echo -e "${B}2. Ánalisis de Logs${NOCOLOR}"
	echo -e "${B}3. Ataque de diccionario${NOCOLOR}"
	echo -e "${B}4. Fingerprinting${NOCOLOR}"
	echo -e "${B}5. Footprinting${NOCOLOR}"
	echo -e "${B}6. Fuzzing${NOCOLOR}"
	echo -e "${B}7. Ataque con metasploit${NOCOLOR}"
	echo -e "${B}8. Instalar dependencias (apt)${NOCOLOR}"
	echo -e "${B}9. Salir${NOCOLOR}"
	echo -e "${B}------------------${NOCOLOR}"
	echo -e "${R}Atencion, este script utiliza programas o listas de palabras que pueden no estar instalados por defecto en KaliLinux u otro SO, instala las dependencias.${NOCOLOR}"
	echo -e "${B}Elige una opción:${NOCOLOR}"
	read opcion
```

El script debe ejecutarse en modo root para habilitar la instalación de dependencias y evitar posibles problemas de acceso a wordlists personalizadas.
Además todos los echo del script están coloreados, Azul `${B}` para mensajes de elección, Verde`${G}` para mensajes informativos y Rojo `${R}`  para errores y advertencias. El resto sin color `${NOCOLOR}`. La tabla de colores la he puesto al principio para evitar tener que escribir el codigo de color todo el rato.
He evitado usar `read -p “texto”` porque no se puede colorear, así que todos los `read` tienen un `echo` antes.
## SALUDO
```bash
case $opcion in
	"1")
    	clear
    	toilet -S "Hola!! :)" -f pagga -w 75
    	sleep 3
    	clear
    	;;
```

No hay que explicar nada aqui… He usado toilet con una fuente que me gusta sinmas.
## ANÁLISIS DE LOGS
```bash
echo -e "${G}Comenzando análisis de logs...${NOCOLOR}"

regex_log="^/([^/\0]+/)*[^/\0]+\.(txt|log)$"

while true; do
	echo -e "${B}Indica el lugar el fichero de logs (direccion completa):${NOCOLOR}"
	read log
	if [[ $log =~ $regex_log ]]; then
    	if [[ -e $log ]]; then
        	echo -e "${G}Comenzando analisis de logs...${NOCOLOR}"
        	break
    	else
        	echo -e "${R}El archivo $log no existe. Inténtalo de nuevo.${NOCOLOR}"
    	fi
	else
    	echo -e "${R}Archivo no válido. Escribe la ruta completa de un fichero .txt o .log.${NOCOLOR}"
	fi
done

resultado_log=informe_logs.txt

echo "Análisis de logs de Nginx: $(date)" >$resultado_log
echo "=================================" >>$resultado_log

# Direcciones IP con solicitudes en horas poco habituales (por ejemplo, de 00:00 a 06:00)
echo "Direcciones IP con solicitudes en horas poco habituales (00:00 - 06:00):" >>$resultado_log
awk 'substr($4, 14, 8) ~ /0[0-6]:[0-5][0-9]:[0-5][0-9]/ {print $1, substr($4, 14, 8), $7}' $log | sort | uniq -c | sort -nr >>$resultado_log

echo >>$resultado_log

# Direcciones IP con intentos de acceso repetido a recursos inexistentes (código 404)
echo "Direcciones IP con intentos de acceso repetido a recursos inexistentes (404):" >>$resultado_log
awk '$9 == 404 {print $1, substr($4, 14, 8), $7}' $log | sort | uniq -c | sort -nr >>$resultado_log

echo >>$resultado_log

# Direcciones IP con número elevado de solicitudes en un corto periodo
echo "Direcciones IP con número elevado de solicitudes en un corto periodo:" >>$resultado_log
awk '{print $1}' $log | sort | uniq -c | sort -nr | awk '$1 > 10' >>$resultado_log

echo >>$resultado_log

# Direcciones IP con intentos de acceso a directorios restringidos o sensibles
echo "Direcciones IP con intentos de acceso a directorios restringidos o sensibles:" >>$resultado_log
awk '$7 ~ /\/etc\/passwd|\/var\/|\/proc\/|\/password\/|\/secure\/|\/contraseñas\/|\/users\/|\/private/ {print $1, substr($4, 14, 8), $7}' $log | sort | uniq -c | sort -nr >>$resultado_log

echo >>$resultado_log

echo "${G}Análisis completado. Informe guardado en $resultado_log${NOCOLOR}"
echo "${G}Presiona cualquier tecla para volver al menu.${NOCOLOR}"
read -s
clear
;;

```
Para los logs he usado awk sort y uniq para la mayoria de casos, aunque las IP con muchos accesos en un corto periodo de tiempo se me han resistido y lo he dejado en IP que tengan muchos accesos sinmas, el resto es hacer un buen uso de las regex.
Ademas hay comprobaciones de si el archivo de logs existe o no, estas comprobaciones estan por todo el script (donde me he acordado de ponerlo vaya)
ATAQUE DE DICCIONARIO
El ataque de diccionario lo he hecho tanto con JohnTheRIpper como con Hashcat.
Lo mas interesante a destacar el que no he hecho comprobaciones de si el tipo de hash esta bien escrito, si no que meto todos lo tipos de hash encontrados en una variable y los listo ($TIPO_HASH_X), despues cuando el usuario elige que tipo quiere con un numero ese numero se encaja en la variable (si queremos el 3 seria $TIPO_HASH_$NUMERO) y el resultado lo meto en una variable nueva ara trabajar mejor: 
```bash
# LEER TODOS LOS TIPOS DE HASH Y METERLOS EN UN ARRAY
while read -r tipo; do
	tipos+=("$tipo")
done < <(hashid $hash | grep "[+]" | awk '{print $2}')

# POR CADA TIPO DE HASH CREO UNA VARIABLE Y LA IMPRIMO POR PANTALLA
for i in "${!tipos[@]}"; do
	eval "TIPO_HASH_$((i + 1))='${tipos[i]}'"
	eval "echo $((i + 1)). \$TIPO_HASH_$((i + 1))"
done

# EN BASE AL NUMERO ELEGIDO ($hash_id) METO EL CONTENIDO EN UNA NUEVA VARIABLE
eval "hash_type=\$TIPO_HASH_$hash_id"
```

Esto se repite 3 veces, la primera para el tipo de hash legible, y las otras para el tipo de hash para JohnTR y para Hashcat, ya que usan formatos personalizados.
El resto del código consiste en elegir qué herramienta y que diccionario elegir, y ejecutarlo.

## FINGERPRINTING
En el fingerprinting primero se comprueba que la red es valida con un regex, y luego se listan todas las ips de la misma manera que hemos hecho antes para no tener que escribirla, si no elegir el numero.
```bash 
regex_ip="^([0-9]{1,3}\.){3}[0-9]{1,3}\/([0-9]|[1-2][0-9]|3[0-2])$"

while true; do
	echo -e "${B}Introduce la red: ${NOCOLOR}"
	read red
	if [[ $red =~ $regex_ip ]]; then
    	echo -e "${G}Escaneando la red $red...${NOCOLOR}"
    	break
	else
    	echo -e "${R}Red no válida. Introduce una red con máscara. E.j 192.168.1.0/24${NOCOLOR}"
	fi
done

while read -r ip; do
	ips+=("$ip")
done < <(fping -a -4 -g $red 2>/dev/null)

for i in "${!ips[@]}"; do
	eval "IP_$((i + 1))=${ips[i]}"
done
echo -e "${G}-----IPs ENCONTRADAS-----${NOCOLOR}"
for i in "${!ips[@]}"; do
	eval "echo $((i + 1)). \$IP_$((i + 1))"
done
echo -e "${G}-------------------------${NOCOLOR}"
```

Despues se hace el nmap correspondiente a la IP elegida y finalmente se pregunta si queremos ejecutar scripts de NSE, en el caso de que queramos, se listan unos cuantoes scripts aleatorios en base a los servicios que ha detectado nmap, pero se escribe el que queramos ejecutar( comprobando que existe claro):

```bash
while true; do
	echo -e "${B}Deseas lanzar un script contra $target? (s/n)${NOCOLOR}"
	read -s lanzar_script
	case $lanzar_script in
	"s")
    	echo -e "${G}En base a los servicios detectados anteriormente puede que estos scripts sean de utilidad:${NOCOLOR}"

    	servicios=()

    	while read -r servicio; do
        	if [[ -n "$servicio" ]]; then
            	servicios+=("$servicio")
        	fi
    	done < <(awk '{print $3}' $target.target | sed '/^$/d')

    	for i in "${servicios[@]}"; do
        	resultados=$(ls /usr/share/nmap/scripts | grep "$i" | tail -n 3)
        	if [[ -n "$resultados" ]]; then
            	echo "$resultados"
        	fi
    	done
    	while true; do
        	echo -e "${G}Escribe el nombre del script que quieras usar:${NOCOLOR} "
        	read seleccion

        	if [ -e "/usr/share/nmap/scripts/$seleccion.nse" ]; then
            	echo -e "${G}Lanzando $seleccion contra $target...${NOCOLOR}"
            	nmap --script=$seleccion $target
            	break
        	else
            	echo -e "${R}Error: El script $seleccion no existe.${NOCOLOR}"
        	fi
    	done
    	;;
	*)
    	echo -e "${G}Volviendo al menú...${NOCOLOR}"
    	sleep 1
    	break
    	;;
	esac

done  
```

## FOOTPRINTING
El footprinting lo he hecho relativamente simple, un menu basico de que queremos hacer y una ultima opcion para editar los metadatos que, como llevo haciendo todo el script, lista los metadatos editables y se elige mediante numero cual se quiere editar. Tambien comprueba si el fisher a editar existe.

```bash 
while true; do
	echo -e "${B}Escribe la ruta completa del fichero:${NOCOLOR}"
	read fichero_editar
	if [ -e "$fichero_editar" ]; then
    	echo -e "${B}Listando metadatos editables disponibles...${NOCOLOR}"
    	while read -r t_metadato; do
        	t_metadatos+=("$t_metadato")
    	done < <(exiftool "$fichero_editar" | awk -F ":" '{print $1}' | tr -d ' ')

    	for i in "${!t_metadatos[@]}"; do
        	eval "tipo_metadato_$((i + 1))='${t_metadatos[i]}'"
        	eval "echo $((i + 1)). \$tipo_metadato_$((i + 1))"
    	done
    	echo -e "${B}Escribe el número del metadato a editar (de la lista anterior):${NOCOLOR}"
    	read n_metadato
    	eval "metadata_type=\$tipo_metadato_$n_metadato"
    	echo -e "${B}Escribe el nuevo valor del metadato:${NOCOLOR}"
    	read valor

    	exiftool -"$metadata_type"="$valor" "$fichero_editar"
    	echo -e "${G}Metadato editado correctamente.${NOCOLOR}"

    	break
	else
    	echo -e "${R}Error: El fichero no existe.${NOCOLOR}"
	fi
done
```

## FUZZING
Al fuzzing le podría haber metido más ganas…Es el menú simple para escanear directorios en base a qué tipo de lista de palabras se quiere usar o una personalizada. Pero he decidido darle más tiempo a otras partes del script antes que a esta.

```bash 
while true; do
	echo -e "${B}Que quieres probar?${NOCOLOR}"
	echo -e "1. Directorios comunes"
	echo -e "2. Directorios en español"
	echo -e "3. Directorios de administración"
	echo -e "4. Lista bestial (lenta)"
	echo -e "5. Lista personalizada"
	read directorios
	case $directorios in
	"1")
    	lista_directorios="/usr/share/wordlists/wfuzz/general/common.txt"
    	break
    	;;
	"2")
    	lista_directorios="/usr/share/wordlists/wfuzz/general/spanish.txt"
    	break
    	;;
	"3")
    	lista_directorios="/usr/share/wordlists/wfuzz/general/admin-panels.txt"
    	break
    	;;
	"4")
    	lista_directorios="/usr/share/wordlists/wfuzz/general/megabeast.txt"
    	break
    	;;
	"5")
    	read -p "Indica la lista: " lista_directorios
    	break
    	;;
	*)
    	clear
    	echo -e "${R}Elige 1, 2, 3, 4 o 5.${NOCOLOR}"
    	;;
	esac
done
wfuzz -f wfuzz.txt -w $lista_directorios $url | awk '$2 ~ /^20[0-9]$/ || $2 ~ /^30[0-9]$/'
```

## METASPLOIT
El metasploit es un poco complicado porque requiere de abrir su propia terminal y interactuar con el, por suerte tiene un modo para ejecutar comandos directamente en bash asi que me he apoyado en eso. Tambien permite hacer un archivo de recursos donde meer todos los comando que queramos y ejecutar el framework directamente de dicho archivo, pero no me servia para mi situacion especifica.
Primero pide la ip a atacar y comprueba si ya se a hecho fingerprinting contra ella, despues puerto y servicio, en base a lo que se le pasa lista exploit para ese servicio y en base al exploit lista los payloads.
```bash 
echo -e "${G}Comenzando Metasploit...${NOCOLOR}"
echo -e "${B}Indica la IP del equipo a atacar: ${NOCOLOR}"
read mfs_ip
if [[ ! -e $mfs_ip.target ]]; then
	echo -e "${R}Todavia no has hecho fingerprinting contra $mfs_ip. Es recomendable generar un archivo con posibles puertos abiertos.${NOCOLOR}"
	sleep 2
else
	regex_port="^[0-9]{1,6}$"
	while true; do
    	cat $mfs_ip.target
    	echo -e "${B}Que puerto quieres atacar?${NOCOLOR}"
    	read mfs_port
    	if [[ $mfs_port =~ $regex_port ]]; then
        	break
    	else
        	echo -e "${R}Puerto no válido.${NOCOLOR}"
    	fi
	done
	echo -e "${B}Que servicio quieres atacar?${NOCOLOR}"
	read msf_service
	echo -e "${G}Buscando exploits para el servicio $msf_service...${NOCOLOR}"
	exploits=$(msfconsole -q -x "search $msf_service; exit" | grep -oE 'exploit/[^ ]+')

	if [ -z "$exploits" ]; then
    	echo -e "${R}No se encontraron exploits para el servicio ${service}.${NOCOLOR}"
    	exit 1
	fi

	echo -e "${G}Exploits encontrados:${NOCOLOR}"
	i=1
	for exploit in $exploits; do
    	echo "$i. $exploit"
    	((i++))
	done

	echo -e "${B}Elige un exploit del listado (escribe el número correspondiente):${NOCOLOR}"
	read exploit_num
	exploit=$(echo "$exploits" | sed -n "${exploit_num}p")
	if [ -z "$exploit" ]; then
    	echo -e "${R}El exploit elegido no es válido.${NOCOLOR}"
    	exit 1
	fi

	echo -e "${G}Usando el exploit: $exploit${NOCOLOR}"

	echo -e "${G}Buscando payloads compatibles...${NOCOLOR}"
	payloads=$(msfconsole -q -x "use ${exploit}; show payloads; exit" | grep -oE 'payload/[^ ]+')

	if [ -z "$payloads" ]; then
    	echo -e "${R}No se encontraron payloads compatibles.${NOCOLOR}"
    	exit 1
	fi

	echo -e "${G}Payloads compatibles encontrados:${NOCOLOR}"
	i=1
	for payload in $payloads; do
    	echo "$i. $payload"
    	((i++))
	done

	echo -e "${B}Elige un payload del listado (escribe el número correspondiente):${NOCOLOR}"
	read payload_num
	payload=$(echo "$payloads" | sed -n "${payload_num}p")

	echo -e "${G}Usando el payload: $payload${NOCOLOR}"

	echo -e "${G}Ejecutando exploit...${NOCOLOR}"
	msfconsole -q -x "use $exploit; set RHOSTS $mfs_ip; set RPORT $mfs_port; set PAYLOAD $payload; exploit; exit"

	echo -e "${G}Terminado.${NOCOLOR}"
fi
```

## DEPENDENCIAS
Unos simples comandos para instalar todos los programas que se usan en el script y descargar el rockyou, aqui se podrian añadir mas wordlists en el caso de necesitarlas.

```bash
echo -e "${G}Instalando dependencias....${NOCOLOR}"
apt update
apt-get install nmap john hashid hashcat fping wfuzz libimage-exiftool-perl toilet -y
git clone https://github.com/zacheller/rockyou.git
tar -xzvf rockyou/rockyou.txt.tar.gz -C "/usr/share/wordlists"
rm -rf rockyou
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb >msfinstall && chmod 755 msfinstall && ./msfinstall
echo -e "${G}Listo!${NOCOLOR}"
sleep 2
;;
```


