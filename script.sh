#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31mPor favor, ejecuta este script como root.\033[0m"
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
    echo -e "${B}8. Instalar dependecias (apt)${NOCOLOR}"
    echo -e "${B}9. Salir${NOCOLOR}"
    echo -e "${B}------------------${NOCOLOR}"
    echo -e "${R}Atencion, este script utiliza programas o listas de palabras que pueden no estar instalados por defecto en KaliLinux u otro SO, instala las dependencias.${NOCOLOR}"
    echo -e "${B}Elige una opción:${NOCOLOR}"
    read opcion

    case $opcion in
    "1")
        clear
        toilet -S "Hola!! :)" -f pagga -w 75
        sleep 3
        clear
        ;;
    "2")
        echo -e "${G}Comenzando análisis de logs...${NOCOLOR}"

        regex_log="^/([^/\0]+/)*[^/\0]+\.(txt|log)$"

        while true; do
            echo "${B}Indica el lugar el fichero de logs (direccion completa):${NOCOLOR}"
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
    "3")
        echo -e "${B}Introduce el hash:${NOCOLOR}"
        read hash

        echo $hash >hash.txt

        echo -e "${G}--- Tipos de Hash encontrados ---${NOCOLOR}"
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

        echo -e "${B}Con que tipo de Hash quieres probar? (escribe el número): ${NOCOLOR}"
        read hash_id

        while true; do
            echo -e "${B}Elije un diccionario:${NOCOLOR}"
            echo -e "1. Diccionario de John The Ripper"
            echo -e "2. Rockyou.txt"
            echo -e "3. Otro"
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
                echo "${B}Escribe la direccion completa del diccionario: ${NOCOLOR}"
                read diccionario
                break
                ;;
            *)
                clear
                echo -e "${R}Elige 1, 2 o 3${NOCOLOR}"
                ;;
            esac
        done
        while true; do
            echo -e "${B}Elije la herramienta${NOCOLOR}"
            echo -e "1. John The Ripper"
            echo -e "2. HashCat"
            read tool
            case $tool in
            "1")
                echo -e "${G}Comenzando JohnTheRipper...${NOCOLOR}"

                eval "hash_type=\$TIPO_HASH_J_$hash_id"

                john hash.txt --wordlist=$diccionario --format=$hash_type --fork=16 --verbosity=1

                john --show hash.txt --format=$hash_type >>hash.txt

                echo -e "${G}---------CONTRASEÑA------------${NOCOLOR}"
                cat hash.txt | grep "?" | awk -F ':' '{print $2}'
                echo -e "${G}-------------------------------${NOCOLOR}"

                echo -e "${B}Presiona cualquier tecla para volver al menu.${NOCOLOR}"
                read -s
                rm hash.txt
                break
                ;;
            "2")
                echo -e "${G}Comenzando HashCat...${NOCOLOR}"

                eval "hash_type=\$TIPO_HASH_M_$hash_id"

                echo -e "${G}---------CONTRASEÑA------------${NOCOLOR}"
                hashcat hash.txt -m $hash_type -w 4 $diccionario --show | awk -F ':' '{print $2}'
                echo -e "${G}-------------------------------${NOCOLOR}"
                echo -e "${B}Presiona cualquier tecla para volver al menu.${NOCOLOR}"
                read -s
                rm hash
                break
                ;;

            *)
                echo -e "${R}Elige 1 o 2${NOCOLOR}"
                ;;
            esac
        done
        clear
        ;;
        # -----------------------FINGERPRINTING-----------------------------------
    "4")
        clear
        echo -e "${G}Comenzando fingerprinting...${NOCOLOR}"
        sleep 1

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
        echo -e "${B}Qué ip quieres escanear? (escribe el número): ${NOCOLOR}"
        read target_id

        eval "target=\$IP_$target_id"

        echo -e "${G}Iniciando Nmap contra $target...${NOCOLOR}"

        nmap -sV $target | grep -A 20 "PORT" | grep -B 20 "Service Info:" >$target.target

        echo -e "${G}Nmap terminado, puedes encontrar lo resultados en $target.target${NOCOLOR}"
        echo -e "-------------------------"

        while true; do
            echo -e "${B}Pulsa S si deseas lanzar scripts o pulsa cualquier otra tecla para volver al menú.${NOCOLOR}"
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

                read -p "${G}Escribe el nombre del script que quieras usar:${NOCOLOR} " seleccion
                echo -e "Lanzando $seleccion contra $target..."
                nmap --script=$seleccion $target
                ;;
            *)
                echo -e "${G}Volviendo al menú...${NOCOLOR}"
                sleep 1
                break
                ;;
            esac

        done
        clear
        ;;
        # -----------------------FOOTPRINTING----------------------------------- ----------------------- FINISH FOOTPRINTING
    "5")
        clear
        while true; do
            echo -e "${G}COMENZANDO EXIFTOOL${NOCOLOR}"
            echo -e "1. Metadatos de la ruta actual"
            echo -e "2. Metadatos de una ruta especifica"
            echo -e "3. Metadatos de un fichero especifico"
            echo -e "4. Volver"
            echo -e "${B}Elige una opción: ${NOCOLOR}"
            read footprinting
            case $footprinting in
            "1")
                clear
                exiftool ./
                echo -e "${B}Presiona culaquier tecla para volver al menú${NOCOLOR}"
                read -s
                ;;
            "2")
                clear
                echo -e "${B}Escribe la ruta completa:${NOCOLOR}"
                read ruta_footprinting
                exiftool $ruta_footprinting
                echo -e "${B}Presiona culaquier tecla para volver al menú${NOCOLOR}"
                read -s
                ;;
            "3")
                clear
                echo -e "${B}Escribe la ruta completa:${NOCOLOR}"
                read ruta_footprinting
                exiftool $fichero_footprinting
                echo -e "${B}Presiona culaquier tecla para volver al menú${NOCOLOR}"
                read -s
                ;;
            "4")
                clear
                break
                ;;
            *)
                echo -e "${R}Elige 1, 2 o 3${NOCOLOR}"
                ;;
            esac

            # EXTRA ----> EDITAR METADATOS!!!
        done
        ;;
        # -----------------------FUZZING-----------------------------------    ------------------------- FINISH FUZZING
    "6")
        clear
        echo -e "${G}FUZZING${G}"
        echo -e "${B}Indica la URL para el Fuzzing:${NOCOLOR}"
        read url              
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

        echo -e "${B}Presiona culaquier tecla para volver al menú${NOCOLOR}"
        read -s
        ;;
        # -----------------------METASPLOIT----------------------------------- ---------------------------- FINISH METASPLOIT
    "7")
        clear
        echo -e "Has elegido la Opción 7"
        read -p "ip" mfs_ip
        if [[ ! -e $mfs_ip.target ]]; then
            echo -e "Todavia no has hecho fingerprinting contra $mfs_ip. Es recomendable generar un archivo con posibles puertos abiertos."
            read -p "Deseas continuar? (s/n)" mfs_continuar
            case $mfs_continuar in
            "s") ;;
            "n") ;;
            esac
        fi
        echo -e "Comenzando Metasploit contra $mfs_ip..."

        ;;
        # -----------------------INSTALL DEPENDENCIES----------------------------------- -------------------- FIX DEPENDENCY INSTALLING
    "8")
        echo -e "${G}Instalando dependecias....${NOCOLOR}"
        apt update
        apt-get install nmap john hashid hashcat fping wfuzz libimage-exiftool-perl toilet -y
        #wget https://github.com/josuamarcelc/common-password-list/blob/ca1abf967b91c9cd2656e4c4d3b8d11109b90ef3/rockyou.txt/rockyou.txt.zip
        #mv rockyou.txt.zip /usr/share/wordlists/
        echo -e "${G}Listo!${NOCOLOR}"
        ;;
        # -----------------------SALIR-----------------------------------
    "9")
        echo -e "${G}Saliendo...${NOCOLOR}"
        break
        ;;
    *)
        clear
        echo -e "${R}Opción no válida. Por favor, elige una opción del 1 al 9.${NOCOLOR}"
        sleep 1
        clear
        ;;
    esac
done
