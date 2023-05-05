#!/bin/bash

echo "
 __      __        .__   __   .__ 
/  \    /  \_____  |  | |  | _|__|
\   \/\/   /\__  \ |  | |  |/ /  |
 \        /  / __ \|  |_|    <|  |
  \__/\  /  (____  /____/__|_ \__|
       \/        \/          \/   
Tik Tok downloader v 2.0
"

sleep 1



# Asignamos una variable al folder donde se guardaran los videos descargados
descarga_folder="$(xdg-user-dir VIDEOS)"

# Definimos una función que escucha los enlaces del portapapeles y los guarda en un archivo
function listen_links {
    # Pedimos al usuario que ingrese el nombre del archivo de salida
    read -p "Ingresa el nombre del archivo de salida: " output_file

    # Creamos el archivo de salida y escribimos la primera línea
    echo "Historial del clipboard:" >> "$output_file"

    #limpiando el clipboard antes de comenzar la escucha de enlaces
    echo -n | xclip -selection clipboard

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
            sleep 3
            echo -n | xclip -selection clipboard
        fi
    done
     # LLamamos ala funcion show_menu para regrresar al menú principal
    break
}

# Definimos una función que descarga los videos de una lista de enlaces
function download_videos {
    # Pedimos al usuario que ingrese el nombre del archivo de entrada
    read -p "Ingresa el nombre del archivo de enlaces: " input_file

    # Pedimos al usuario que ingrese el directorio de salida para los videos descargados
    read -p "Ingresa el directorio de salida para los videos descargados: " output_dir

    # Definimos el ultimo numero que se utilizara para nombrar a los archivos
    ultimoNumero=$(find /media/walky/checar/tiktoks /media/walky/checar/TTclasificados /home/walky/Documentos/videos -type f -name "*.mp4" | wc -l)
    ultimoNumero=$((ultimoNumero+1))

    # contamos cuantos videos se descargaran 
    conteoVideosLista=$(wc -l $input_file)


    #informamos al usurio en que el archivo que se usara para descargar los videos ruta se descargaran los archivos y el ultimo numero con el que se nombraran el archivo
    echo "Sus archivos se descargaran en $output_dir" 
    echo "Los videos ha descargar estan definidos por el listado $input_file"
    echo "Se comenzara a nombrar al archivo con el numero $ultimoNumero"
    # Descargamos los videos con la mejor calidad disponible
    echo "Descargando videos $conteoVideosLista en la mejor calidad disponible"
# Download the video in the selected format
yt-dlp -a "$input_file" -f best -o "$output_dir/%(autonumber)s.%(ext)s"  --autonumber-start $ultimoNumero

}

#Definimos una funcion que se encargara dde limpiar codigo html que contiene los enlaces el cual tenemos que obtener desde las herramientas de desarrollador he inspeccionar la grid que se genera copiar el codigo y pegarlo en un archivo

function codeRaw {

    # Pedimos al usuario que ingrese el nombre del archivo de entrada
    read -p "Ingresa el nombre del archivo de enlaces: " input_file
    # Creamos el archivo de salida
    output_file="videos_$(date '+%Y-%m-%d').list"
    touch "./$output_file"

    grep -Eo '<a href="https://www\.tiktok\.com/@[^/]+/video/[^/]+" tabindex="-1">' $input_file|sed 's/tabindex="-1">//g'|sed 's/<a href="//g'|sed 's/"//g'|tee "./$output_file"
    clear
    conteo=$(wc -l $output_file)

    echo "se han obtenido $conteo enlaces, favor de checar cuales son utiles."
    code $4output_file


}
# Manejar la señal SIGINT y regresar al menú principal
trap 'show_menu' SIGINT
# Definimos una función que muestra el menú de opciones y ejecuta la opción seleccionada por el usuario
function show_menu {
    while true; do
        echo ""
        echo "Selecciona una opción:"
        echo "1. Escuchar enlaces del portapapeles y guardarlos en un archivo"
        echo "2. Descargar videos de una lista de enlaces"
        echo "3. Obtener enlaces desde el codigo"
        echo "4. Salir del script"
        read -p "Opción: " option

        case $option in
            1)
                listen_links
                ;;
            2)
                download_videos
                ;;
            3)
                codeRaw
                ;;
            4)
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

