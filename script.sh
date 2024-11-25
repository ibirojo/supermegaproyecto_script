#!/bin/bash
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

            # Obtener la salida de hashid
            hashid=$(echo "$hash" | hashid)
            hash_jtr=$(echo "$hash" | hashid -j )

            # Procesar la salida y formatearla en una tabla
            echo -e "Tipo de Hash\tVersión de JtR"
            echo "$hashid" | grep "[+]" | awk -F '[+] ' '{print $1}'


            read -s -p "Presiona cualquier tecla para volver al menu."
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

            #EXTRA----> QUE SE PUEDAN LANZAR SCRIPTS !!!!!!
            
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
            echo "Salir..."
            break
            ;;
        *)
            echo "Opción no válida. Por favor, elige una opción del 1 al 6."
            ;;
    esac
done
