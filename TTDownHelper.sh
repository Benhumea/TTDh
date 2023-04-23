#!/bin/bash

# Definimos una función que escucha los enlaces del portapapeles y los guarda en un archivo
function listen_links {
    # Pedimos al usuario que ingrese el nombre del archivo de salida
    read -p "Ingresa el nombre del archivo de salida: " output_file

    # Creamos el archivo de salida y escribimos la primera línea
    echo "Historial del clipboard:" >> "$output_file"

    # Creamos una lista para almacenar los enlaces ya vistos
    seen_links=()

    # Creamos un bucle que se ejecuta hasta que se use Ctrl + C
    while true; do
        # Escribimos el contenido actual del clipboard en el archivo de salida
        clipboard=$(xclip -selection clipboard -o)
        if [[ "$clipboard" =~ ^(http|https)://.* ]]; then
            if [[ " ${seen_links[@]} " =~ " ${clipboard} " ]]; then
                echo "Enlace repetido: $clipboard"
            else
                echo "$clipboard" >> "$output_file"
                seen_links+=("$clipboard")
                echo "Enlace guardado: $clipboard"
            fi
            # Limpiamos el portapapeles cada 5 segundos
            sleep 5
            echo -n | xclip -selection clipboard
        fi
    done
}

# Definimos una función que descarga los videos de una lista de enlaces
function download_videos {
    # Pedimos al usuario que ingrese el nombre del archivo de entrada
    read -p "Ingresa el nombre del archivo de enlaces: " input_file

    # Pedimos al usuario que ingrese el directorio de salida para los videos descargados
    read -p "Ingresa el directorio de salida para los videos descargados: " output_dir

    # Descargamos los videos con la mejor calidad disponible
    echo "Descargando videos con calidad media..."
    
# Download the video in the selected format
yt-dlp -a "$input_file" -f best -o "$output_dir/%(autonumber)s.%(ext)s"

}

# Definimos una función que muestra el menú de opciones y ejecuta la opción seleccionada por el usuario
function show_menu {
    while true; do
        echo ""
        echo "Selecciona una opción:"
        echo "1. Escuchar enlaces del portapapeles y guardarlos en un archivo"
        echo "2. Descargar videos de una lista de enlaces"
        echo "3. Salir del script"
        read -p "Opción: " option

        case $option in
            1)
                listen_links
                ;;
            2)
                download_videos
                ;;
            3)
                exit 0
                ;;
            *)
                echo "Opción inválida"
                ;;
        esac
    done
}

# Ejecutamos la función para mostrar el menú de opciones
show_menu
