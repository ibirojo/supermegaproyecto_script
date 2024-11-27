#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Por favor, ejecuta este script como root."
  exit
fi

while true; do
    toilet -S supermegaincreible  script molon de ibai -f pagga -w 75
    echo "==========================================================================" 
    echo "------ Menú ------"
    echo "1. Saludar"
    echo "2. Ánalisis de Logs"
    echo "3. Ataque de diccionario"
    echo "4. Fingerprinting"
    echo "5. Footprinting"
    echo "6. Fuzzing"
    echo "7. Ataque con metasploit"
    echo "8. Ayuda"
    echo "9. Salir"
    echo "------------------"
    echo "Elige una opción:"
    read opcion

    case $opcion in
# -----------------------SALUDO----------------------------------- X
        "1")
            toilet -S "Hola!! :)" -f pagga -w 75
            ;;
# -----------------------LOGS-----------------------------------  X
        "2")
            echo "Comenzando análisis de logs..."
            read -p "Indica el lugar el fichero de logs (direccion completa):" log
            echo "Analizando logs..."
            
            resultado_log=informe_logs.txt

            echo "Análisis de logs de Nginx: $(date)" > $resultado_log
            echo "=================================" >> $resultado_log

            # Direcciones IP con solicitudes en horas poco habituales (por ejemplo, de 00:00 a 06:00)
            echo "Direcciones IP con solicitudes en horas poco habituales (00:00 - 06:00):" >> $resultado_log
            awk 'substr($4, 14, 8) ~ /0[0-6]:[0-5][0-9]:[0-5][0-9]/ {print $1, substr($4, 14, 8), $7}' $log | sort | uniq -c | sort -nr >> $resultado_log

            echo >> $resultado_log

            # Direcciones IP con intentos de acceso repetido a recursos inexistentes (código 404)
            echo "Direcciones IP con intentos de acceso repetido a recursos inexistentes (404):" >> $resultado_log
            awk '$9 == 404 {print $1, substr($4, 14, 8), $7}' $log | sort | uniq -c | sort -nr >> $resultado_log

            echo >> $resultado_log

            # Direcciones IP con número elevado de solicitudes en un corto periodo
            echo "Direcciones IP con número elevado de solicitudes en un corto periodo:" >> $resultado_log
            awk '{print $1}' $log | sort | uniq -c | sort -nr | awk '$1 > 10' >> $resultado_log

            echo >> $resultado_log

            # Direcciones IP con intentos de acceso a directorios restringidos o sensibles
            echo "Direcciones IP con intentos de acceso a directorios restringidos o sensibles:" >> $resultado_log
            awk '$7 ~ /\/etc\/passwd|\/var\/|\/proc\/|\/password\/|\/secure\/|\/contraseñas\/|\/users\/|\/private/ {print $1, substr($4, 14, 8), $7}' $log | sort | uniq -c | sort -nr >> $resultado_log

            echo >> $resultado_log


            echo "Análisis completado. Informe guardado en $resultado_log"

            read -s -p "Presiona cualquier tecla para volver al menu."
            clear
            ;;
# -----------------------DICCIONARIO----------------------------------- X
        "3")
            echo "Introduce el hash:"
            read hash

            echo $hash > hash.txt

            echo -e "--- Tipos de Hash encontrados ---"
            while read -r tipo; do
                tipos+=("$tipo")
            done < <(hashid $hash | grep "[+]" | awk '{print $2}')

            while read -r tipo; do
                tipos_j+=("$tipo")
            done < <(hashid -j $hash | grep "[+]" | awk -F'[][]' '{print $4}' | awk '{print $3}')

            for i in "${!tipos[@]}"; do
                eval "TIPO_HASH_$((i+1))='${tipos[i]}'"
                eval "echo $((i+1)). \$TIPO_HASH_$((i+1))"
            done

            for i in "${!tipos_j[@]}"; do
                eval "TIPO_HASH_J_$((i+1))='${tipos_j[i]}'"
            done

            read -p "Con que tipo de Hash quiere probar? (escribe el número): " hash_id

            eval "hash_type=\$TIPO_HASH_J_$hash_id"

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
            echo "Comenzando crackeo..."

            john hash.txt --wordlist=/usr/share/wordlists/rockyou/rockyou.txt --format=$hash_type --fork=16 --verbosity=1

            john --show hash.txt --format=$hash_type >> hash.txt 

            echo "---------CONTRASEÑA------------"
            cat hash.txt | grep "?" | awk -F ':' '{print $2}'
            echo "-------------------------------"

            read -s -p "Presiona cualquier tecla para volver al menu."

            rm hash.txt
            clear
            ;;
# -----------------------FINGERPRINTING----------------------------------- 
        "4") 
            clear
            echo "Comenzando fingerprinting..."
            sleep 1
            read -p "Introduce la red: " red

            ips=()

            while read -r ip; do
                ips+=("$ip")
            done < <(fping -a -4 -g $red 2>/dev/null)


            for i in "${!ips[@]}"; do
                eval "IP_$((i+1))=${ips[i]}"
            done

            for i in "${!ips[@]}"; do
                eval "echo IP_$((i+1))=\$IP_$((i+1))"
            done

            read -p "Qué ip quieres escanear? (escribe el número): " target_id

            eval "target=\$IP_$target_id"

            echo "Iniciando Nmap contra $target..."
            
            nmap $target | grep -A 20 "PORT" | grep -B 20 "Service info:" >> $target.txt 

            echo "Nmap terminado, puedes encontrar lo resultados en $target.txt"
            read -s -p "Presiona cualquier tecla para volver al menu."

            #EXTRA----> QUE SE PUEDAN LANZAR SCRIPTS!!!!!!
            clear
            ;;
# -----------------------FOOTPRINTING----------------------------------- X
        "5")
            echo "Has elegido la Opción 5"

            ;;
# -----------------------FUZZING----------------------------------- X
        "6")
            echo "Has elegido la Opción 6"

            ;;
# -----------------------METASPLOIT----------------------------------- X
        "7")
            echo "Has elegido la Opción 7"

            ;;
# -----------------------HELP----------------------------------- X
        "8")
            printf "%-25s | %-30s\n" "Opción " "Descripción"
            echo "----------------------------------------------"
            printf "%-25s | %-30s\n" "Saludar" "Descripción"
            echo "----------------------------------------------"
            printf "%-25s | %-30s\n" "Analisis de Logs" "Descripción"
            echo "----------------------------------------------"
            printf "%-25s | %-30s\n" "Ataque de diccionario" "Descripción"
            echo "----------------------------------------------"
            printf "%-25s | %-30s\n" "Fingerprinting" "Descripción"
            echo "----------------------------------------------"
            printf "%-25s | %-30s\n" "Footprinting" "Descripción"
            echo "----------------------------------------------"
            printf "%-25s | %-30s\n" "Fuzzing" "Descripción"
            echo "----------------------------------------------"
            printf "%-25s | %-30s\n" "Ataque con metasploit" "Descripción"
            echo "----------------------------------------------"
            ;;
# -----------------------SALIR-----------------------------------
        "9")
            echo "Saliendo..."
            break
            ;;
        *)
            echo "Opción no válida. Por favor, elige una opción del 1 al 6."
            ;;
    esac
done
