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
# -----------------------SALUDO-----------------------------------
        "1")
            toilet -S "Hola!! :)" -f pagga -w 75
            ;;
# -----------------------LOGS-----------------------------------
        "2")
            echo "Has elegido la Opción 2"
            # Añadir aquí el código para la Opción 3
            ;;
# -----------------------DICCIONARIO-----------------------------------
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
            ;;
# -----------------------FINGERPRINTING-----------------------------------
        "4") 
            clear
            echo "Comenzando fingerprinting..."
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

            read -p "Qué ip quieres escanear? (escribe el número)" target_id

            eval "target=\$IP_$target_id"

            echo "Iniciando Nmap contra $target..."
            
            nmap -sV $target > $target.txt

            echo "Nmap terminado, puedes encontrar lo resultados en $target.txt"
            read -s -p "Presiona cualquier tecla para volver al menu."
            ;;
# -----------------------FOOTPRINTING-----------------------------------
        "5")
            echo "Has elegido la Opción 5"

            ;;
# -----------------------FUZZING-----------------------------------
        "6")
            echo "Has elegido la Opción 6"

            ;;
# -----------------------METASPLOIT-----------------------------------
        "7")
            echo "Has elegido la Opción 7"

            ;;
# -----------------------HELP-----------------------------------
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
