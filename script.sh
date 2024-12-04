#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script como root."
    exit
fi

R='\033[0;31m' #'0;31' is Red's ANSI color code
G='\033[0;32m' #'0;32' is Green's ANSI color code
Y='\033[1;32m' #'1;32' is Yellow's ANSI color code
B='\033[0;34m' #'0;34' is Blue's ANSI color code
NOCOLOR='\033[0m'
while true; do
    toilet -S supermegaincreible script molon de ibai -f pagga -w 75
    echo -e "\033[0;34m=========================================================================="
    echo "------ Menú ------"
    echo "1. Saludar"
    echo "2. Ánalisis de Logs"
    echo "3. Ataque de diccionario"
    echo "4. Fingerprinting"
    echo "5. Footprinting"
    echo "6. Fuzzing"
    echo "7. Ataque con metasploit"
    echo "8. Instalar dependecias (apt)"
    echo "9. Salir"
    echo "------------------"
    echo -e "\033[0;31mAtencion, este script utiliza programas o listas de palabras que pueden no estar instalados por defecto en KaliLinux u otro SO, instala las dependencias. \033[0m"
    echo "Elige una opción:"
    read opcion

    case $opcion in
    # -----------------------SALUDO----------------------------------- X
    "1")
        clear
        toilet -S "Hola!! :)" -f pagga -w 75
        sleep 3
        clear
        ;;
        # -----------------------LOGS-----------------------------------
    "2")
        echo "Comenzando análisis de logs..."

        regex_log="^/([^/\0]+/)*[^/\0]+\.(txt|log)$"

        while true; do
            read -p "Indica el lugar el fichero de logs (direccion completa):" log
            if [[ $log =~ $regex_log ]]; then
                if [[ -e $log ]]; then 
                    echo "Comenzando analisis de logs..." 
                    break 
                else 
                echo "El archivo $log no existe. Inténtalo de nuevo."
                fi
            else
                echo "Archivo no válido. Escribe la ruta completa de un fichero .txt o .log"
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

        echo "Análisis completado. Informe guardado en $resultado_log"

        read -s -p "Presiona cualquier tecla para volver al menu."
        clear
        ;;
        # -----------------------DICCIONARIO----------------------------------- X
    "3")
        echo "Introduce el hash:"
        read hash

        echo $hash >hash.txt

        echo -e "--- Tipos de Hash encontrados ---"
        while read -r tipo; do
            tipos+=("$tipo")
        done < <(hashid $hash | grep "[+]" | awk '{print $2}')

        while read -r tipo; do
            tipos_j+=("$tipo")
        done < <(hashid -j $hash | grep "[+]" | awk -F'[][]' '{print $4}' | awk '{print $3}')

        while read -r tipo; do
            tipos_m+=("$tipo")
        done < <(hashid -m $hash | grep "[+]" | awk -F'[][]' '{print $4}' | awk '{print $3}')

        for i in "${!tipos[@]}"; do
            eval "TIPO_HASH_$((i + 1))='${tipos[i]}'"
            eval "echo $((i + 1)). \$TIPO_HASH_$((i + 1))"
        done

        for i in "${!tipos_j[@]}"; do
            eval "TIPO_HASH_J_$((i + 1))='${tipos_j[i]}'"
        done

        for i in "${!tipos_m[@]}"; do
            eval "TIPO_HASH_M_$((i + 1))='${tipos_m[i]}'"
        done

        read -p "Con que tipo de Hash quiere probar? (escribe el número): " hash_id

        while true; do
            echo "Elije un diccionario:"
            echo "1. Diccionario de John The Ripper"
            echo "2. Rockyou.txt"
            echo "3. Otro"
            read dic
            case $dic in
            "1")
                diccionario="/usr/share/john/password.lst"
                break
                ;;
            "2")
                diccionario="/usr/share/wordlists/rockyou.txt"
                break
                ;;
            "3")
                read -p "Escribe la direccion completa del diccionario: " diccionario
                break
                ;;
            *)
                echo "Elige 1, 2 o 3"
                ;;
            esac
        done
        while true; do
            echo "Elije la herramienta"
            echo "1. John The Ripper"
            echo "2. HashCat"
            read tool
            case $tool in
                "1")
                    echo "Comenzando JohnTheRipper..."

                    eval "hash_type=\$TIPO_HASH_J_$hash_id"

                    john hash.txt --wordlist=$diccionario --format=$hash_type --fork=16 --verbosity=1

                    john --show hash.txt --format=$hash_type >>hash.txt

                    echo "---------CONTRASEÑA------------"
                    cat hash.txt | grep "?" | awk -F ':' '{print $2}'
                    echo "-------------------------------"

                    read -s -p "Presiona cualquier tecla para volver al menu."
                    rm hash.txt
                    break        
                    ;;
                "2")
                    echo "Comenzando HashCat..."

                    eval "hash_type=\$TIPO_HASH_M_$hash_id"

                    echo "---------CONTRASEÑA------------"
                    hashcat hash.txt -m $hash_type -w 4 $diccionario --show | awk -F ':' '{print $2}'
                    echo "-------------------------------"
                    read -s -p "Presiona cualquier tecla para volver al menu."
                    rm hash.txt
                    break
                    ;;

                *)
                    echo "Elige 1 o 2"
                    ;;
            esac
        done
        clear
        ;;
        # -----------------------FINGERPRINTING-----------------------------------
    "4")
        clear
        echo "Comenzando fingerprinting..."
        sleep 1

        regex_ip="^([0-9]{1,3}\.){3}[0-9]{1,3}\/([0-9]|[1-2][0-9]|3[0-2])$"

        while true; do
            read -p "Introduce la red: " red
            if [[ $red =~ $regex_ip ]]; then
                echo "Escaneando la red $red..."
                break
            else
                echo "Red no válida. Introduce una red con máscara. E.j 192.168.1.0/24"
            fi
        done

        while read -r ip; do
            ips+=("$ip")
        done < <(fping -a -4 -g $red 2>/dev/null)

        for i in "${!ips[@]}"; do
            eval "IP_$((i + 1))=${ips[i]}"
        done
        echo "-----IPs ENCONTRADAS-----"
        for i in "${!ips[@]}"; do
            eval "echo $((i + 1)). \$IP_$((i + 1))"
        done
        echo "-------------------------"
        read -p "Qué ip quieres escanear? (escribe el número): " target_id

        eval "target=\$IP_$target_id"

        echo "Iniciando Nmap contra $target..."

        nmap -sV $target | grep -A 20 "PORT" | grep -B 20 "Service Info:" >$target.txt

        echo "Nmap terminado, puedes encontrar lo resultados en $target.txt"
        echo "-------------------------"

        while true; do
            echo "Pulsa S si deseas lanzar scripts o pulsa cualquier otra tecla para volver al menú."
            read -s lanzar_script
            case $lanzar_script in
                "s")
                    echo "En base a los servicios detectados anteriormente puede que estos scripts sean de utilidad:"
                    
                    # Inicializar array vacío
                    servicios=()
                    
                    # Leer los servicios desde el archivo, filtrando los vacíos
                    while read -r servicio; do
                        if [[ -n "$servicio" ]]; then
                            servicios+=("$servicio")
                        fi
                    done < <(awk '{print $3}' $target.txt | sed '/^$/d')
                    
                    # Buscar scripts para cada servicio
                    for i in "${servicios[@]}"; do
                        resultados=$(ls /usr/share/nmap/scripts | grep "$i" | tail -n 3)
                        if [[ -n "$resultados" ]]; then
                            echo "$resultados"
                        fi
                    done
                    
                    read -p "Escribe el nombre del script que quieras usar: " seleccion
                    echo "Lanzando $seleccion contra $target..."
                    nmap --script=$seleccion $target
                    ;;
                *)
                    echo "Volviendo al menú..."
                    sleep 1
                    break
                    ;;
            esac

        done
        clear
        ;;
        # -----------------------FOOTPRINTING----------------------------------- X
    "5")
        clear
        while true; do
            echo "COMENZANDO EXIFTOOL"
            echo "1. Metadatos de la ruta actual"
            echo "2. Metadatos de una ruta especifica"
            echo "3. Metadatos de un fichero especifico"
            echo "4. Volver"
            echo "Elige una opción: "
            read footprinting
            case $footprinting in
            "1")
                clear
                exiftool ./
                read -s -p "Presiona cualquier tecla para volver al menu."
                ;;
            "2")
                clear
                read -p "Escribe la ruta completa:" ruta_footprinting
                exiftool $ruta_footprinting
                read -s -p "Presiona cualquier tecla para volver al menu."
                ;;
            "3")
                clear
                read -p "Escribe la ruta completa:" fichero_footprinting
                exiftool $fichero_footprinting
                read -s -p "Presiona cualquier tecla para volver al menu."
                ;;
            "4")
                clear
                break
                ;;
            *)
                echo "Elige 1, 2 o 3"
                ;;
            esac

            # EXTRA ----> EDITAR METADATOS!!!
        done
        ;;
        # -----------------------FUZZING----------------------------------- X
    "6")
        clear
        echo "FUZZING"
        read -p "Indica la URL para el Fuzz: " url
        echo "Que quieres probar?"
        echo "1. Directorios comunes"
        echo "2. Directorios en español"
        echo "3. Directorios de administración"
        echo "4. Lista bestial (lenta)"
        echo "5. Lista personalizada"
        read directorios
        case $directorios in
            "1")
            lista_directorios="/usr/share/wordlists/wfuzz/general/common.txt"
            ;;
            "2")
            lista_directorios="/usr/share/wordlists/wfuzz/general/spanish.txt"
            ;;
            "3")
            lista_directorios="/usr/share/wordlists/wfuzz/general/admin-panels.txt"
            ;;
            "4")
            lista_directorios="/usr/share/wordlists/wfuzz/general/megabeast.txt"
            ;;
            "5")
            read -p "Indica la lista: " lista_directorios
            ;;
            *)
            ;;
        esac

        wfuzz -f wfuzz.txt -w $lista_directorios $url | awk '$2 ~ /^20[0-9]$/ || $2 ~ /^30[0-9]$/'

        read -s -p "Presiona cualquier tecla para volver al menu."
        ;;
        # -----------------------METASPLOIT----------------------------------- X
    "7")
        echo "Has elegido la Opción 7"

        ;;
        # -----------------------INSTALL DEPENDENCIES----------------------------------- X
    "8")
        echo "Instalando dependecias...."
        apt update
        apt-get install nmap john hashid hashcat fping wfuzz libimage-exiftool-perl toilet -y
        #wget https://github.com/josuamarcelc/common-password-list/blob/ca1abf967b91c9cd2656e4c4d3b8d11109b90ef3/rockyou.txt/rockyou.txt.zip
        #mv rockyou.txt.zip /usr/share/wordlists/
        ;;
        # -----------------------SALIR-----------------------------------
    "9")
        echo "Saliendo..."
        break
        ;;
    *)
        clear
        echo "Opción no válida. Por favor, elige una opción del 1 al 9."
        sleep 1
        clear
        ;;
    esac
done
