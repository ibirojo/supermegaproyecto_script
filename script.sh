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
        "1")
            toilet -S "Hola!! :)" -f pagga -w 75
            ;;
        "2")
            echo "Has elegido la Opción 2"
            # Añadir aquí el código para la Opción 3
            ;;
        "3")
            echo "Introduce el hash:"
            read hash

            # Obtener la salida de hashid
            hashid=$(echo "$hash" | hashid)
            hash_jtr=$(echo "$hash" | hashid -j )

            # Procesar la salida y formatearla en una tabla
            echo -e "Tipo de Hash\tVersión de JtR"
            echo "$hashid" | grep "[+]" | awk -F '[+] ' '{print $1}'
            sleep 3
            ;;
        "4")
            echo "Has elegido la Opción 4"

            ;;
        "5")
            echo "Has elegido la Opción 5"

            ;;
        "6")
            echo "Has elegido la Opción 6"

            ;;
        "7")
            echo "Has elegido la Opción 7"

            ;;
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

        "9")
            echo "Salir..."
            break
            ;;
        *)
            echo "Opción no válida. Por favor, elige una opción del 1 al 6."
            ;;
    esac
done
