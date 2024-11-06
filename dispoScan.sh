#!/bin/bash
# Autor: Ltomxd

# Directorio para guardar el historial de escaneos
history_dir="escaneos_historial"
mkdir -p "$history_dir"
output_file="$history_dir/escaneo_$(date +'%Y%m%d_%H%M%S').txt"

# Mostrar ayuda si se solicita
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Uso: $0 <interfaz> [opciones]"
    echo "Ejemplo: $0 ens33 --fast"
    echo "--fast: Realiza un escaneo rápido de los puertos más comunes"
    echo "--all: Escanea todas las interfaces de red"
    exit 0
fi

# Verificar si se proporcionó un argumento para la interfaz de red
if [ $# -lt 1 ]; then
    echo "Uso: $0 <interfaz> [opciones]"
    echo "Ejemplo: $0 ens33"
    exit 1
fi

# Verificar que las herramientas necesarias estén instaladas
if ! command -v arp-scan &> /dev/null || ! command -v nmap &> /dev/null; then
    echo "Error: Este script requiere 'arp-scan' y 'nmap' instalados."
    exit 1
fi

# Instalar nbtscan si no está disponible (opcional)
if ! command -v nbtscan &> /dev/null; then
    echo "Instalando nbtscan para mejorar la detección de dispositivos..."
    sudo apt-get install nbtscan -y
fi

# Asignar interfaz de red o "all" para escanear todas
interface=$1
# Asignar rango de puertos (fast o completo)
port_range="-p-" # Por defecto, escaneo completo
if [[ "$2" == "--fast" ]]; then
    port_range="-F" # Escaneo rápido de puertos comunes
fi

# Si el usuario usa "all" en lugar de una interfaz específica, el script escanea todas las interfaces
if [ "$interface" = "all" ]; then
    interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo")
else
    interfaces=$interface
fi

# Función para mostrar la barra de carga
show_loading() {
    local progress=$1
    local bar_length=50
    local num_blocks=$((progress * bar_length / 100))
    local loading=""
    for ((i=0; i<num_blocks; i++)); do loading+="#"; done
    for ((i=num_blocks; i<bar_length; i++)); do loading+=" "; done
    printf "\rEscaneando dispositivos en la red local... [%s] %3d%%" "$loading" "$progress"
}

echo "Iniciando escaneo de red. Resultados guardados en $output_file"

# Escaneo en cada interfaz especificada
for iface in $interfaces; do
    echo -e "\n\nDispositivos encontrados en la interfaz $iface:\n" | tee -a "$output_file"
    echo "IP            MAC               Nombre del Dispositivo" | tee -a "$output_file"
    echo "------------------------------------------------------" | tee -a "$output_file"
    
    # Escanear la red local utilizando arp-scan
    devices=$(sudo arp-scan -I "$iface" --localnet --ignoredups | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}\s+([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})')
    total_devices=$(echo "$devices" | wc -l)
    current_device=1

    # Si no se encuentran dispositivos, terminar el escaneo para esa interfaz
    if [ "$total_devices" -eq 0 ]; then
        echo "No se encontraron dispositivos en la interfaz $iface." | tee -a "$output_file"
        continue
    fi

    # Mostrar los dispositivos encontrados y actualizar el progreso
    for device in $devices; do
        ip=$(echo "$device" | awk '{print $1}')
        mac=$(echo "$device" | awk '{print $2}')
        
        # Obtener el nombre de host a través de DNS
        name=$(getent hosts "$ip" | awk '{print $2}')
        
        # Intentar con nbtscan para redes Windows (NetBIOS)
        if [ -z "$name" ]; then
            name=$(nbtscan -r "$ip" | grep -i "name" | awk '{print $1}')
        fi
        
        # Intentar resolución inversa de DNS con dig
        if [ -z "$name" ]; then
            name=$(dig +short -x "$ip" | head -n 1)
        fi

        # Identificar el tipo de dispositivo basado en la dirección MAC
        if [ -z "$name" ]; then
            # Obtener el fabricante a partir del prefijo de la MAC
            manufacturer=$(echo "$mac" | cut -c 1-8 | tr '[:lower:]' '[:upper:]')
            case $manufacturer in
                AC:CF:85) name="Apple Device" ;;       # Ejemplo para Apple
                00:1A:79) name="Samsung Device" ;;     # Ejemplo para Samsung
                8C:3B:AD) name="Huawei Device" ;;      # Ejemplo para Huawei
                00:1A:73) name="Dell PC/Laptop" ;;     # Ejemplo para Dell
                28:16:AD) name="HP Laptop" ;;          # Ejemplo para HP
                3C:07:54) name="Lenovo Laptop" ;;      # Ejemplo para Lenovo
                *) name="Desconocido" ;;               # Si no hay coincidencia, dejar como Desconocido
            esac
        fi

        # Escaneo de sistema operativo y servicios específicos
        if [ "$name" = "Desconocido" ]; then
            os_and_services=$(sudo nmap -O "$ip" | grep 'Running:' | awk '{print $2 " " $3}')
            if [[ "$os_and_services" == *"Windows"* ]]; then
                name="Windows PC/Laptop"
            elif [[ "$os_and_services" == *"Linux"* ]]; then
                name="Linux Device (posiblemente laptop/PC)"
            elif [[ "$os_and_services" == *"Mac OS X"* ]]; then
                name="Mac Device (posiblemente laptop/PC)"
            fi
        fi

        # Imprimir y registrar el resultado final
        echo "$ip      $mac      ${name:-Desconocido}" | tee -a "$output_file"
        
        progress=$((100 * current_device / total_devices))
        show_loading "$progress"
        current_device=$((current_device + 1))
    done

    echo -e "\n~ Escaneo de dispositivos completo mi Dogor🐕‍🦺!\n" | tee -a "$output_file"
done

# Escanear dispositivos adicionales con nmap (DNS-SD y UPnP)
echo -e "\n\nEscaneando dispositivos adicionales con nmap para DNS-SD y UPnP...\n" | tee -a "$output_file"
sudo nmap -sP --script=dns-service-discovery,upnp-info "$iface" | tee -a "$output_file"

# Escanear los puertos abiertos en los dispositivos encontrados
echo -e "\n\nEscaneando puertos abiertos en los dispositivos...\n" | tee -a "$output_file"
echo "IP            Puertos Abiertos                  Sistema Operativo y Versión" | tee -a "$output_file"
echo "-------------------------------------------------------------------------" | tee -a "$output_file"

for ip in $(echo "$devices" | awk '{print $1}'); do
    open_ports=$(sudo nmap $port_range --open "$ip" --min-rate 1000 --max-rate 5000 | grep ^[0-9] | awk '{print $1}')
    if [ -z "$open_ports" ]; then
        open_ports="Ninguno"
    else
        open_ports=$(echo "$open_ports" | tr '\n' ' ')
    fi
    
    os_and_services=$(sudo nmap -sV -O --script=banner "$ip" | grep -E 'Running:|open' | awk '{print $2 " " $3 " " $4}')
    echo "$ip      $open_ports      ${os_and_services:-No detectado}" | tee -a "$output_file"
done

echo -e "\n~ Escaneo de puertos completo mi Dogor🐕‍🦺!\n" | tee -a "$output_file"

# Resumen del escaneo
echo -e "\nResumen del escaneo:" | tee -a "$output_file"
echo "Dispositivos detectados: $total_devices" | tee -a "$output_file"
echo "Sistemas operativos identificados:" | tee -a "$output_file"
grep "Sistema Operativo" "$output_file" | sort | uniq -c | tee -a "$output_file"

# Notificación al usuario
if command -v notify-send &> /dev/null; then
    notify-send "Escaneo completo" "El escaneo de red y puertos ha finalizado"
fi
