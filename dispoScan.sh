#!/bin/bash
# Autor: Ltomxd

# Verificar si se proporcionó un argumento para la interfaz de red
if [ $# -ne 1 ]; then
    echo "Uso: $0 <interfaz>"
    echo "Ejemplo: $0 ens33"
    exit 1
fi

# Obtener la interfaz de red del primer argumento
interface=$1

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

# Escanear la red local utilizando arp-scan
echo -e "\n\nDispositivos encontrados en la interfaz $interface:\n"
echo "IP            MAC               Nombre del Dispositivo"
echo "------------------------------------------------------"

devices=$(sudo arp-scan -I $interface --localnet --ignoredups | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}\s+([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})')
total_devices=$(echo "$devices" | wc -l)
current_device=1
progress=0

for device in $devices; do
    ip=$(echo $device | awk '{print $1}')
    mac=$(echo $device | awk '{print $2}')
    name=$(getent hosts $ip | awk '{print $2}')
    echo "$ip      $mac      $name"    
    
    # Actualizar el progreso de la barra de carga
    progress=$((100 * current_device / total_devices))
    current_device=$((current_device + 1))
done

show_loading $progress
echo -e "\n~ Escaneo de dispositivos completo mi Dogor🐕‍🦺!\n"

# Escanear los puertos abiertos en los dispositivos encontrados
echo -e "\n\nEscaneando puertos abiertos en los dispositivos...\n"
echo "IP            Puertos Abiertos                  Sistema Operativo y Versión"
echo "-------------------------------------------------------------------------"

for ip in $(echo "$devices" | awk '{print $1}'); do
    open_ports=$(sudo nmap -p- --open $ip | grep ^[0-9] | awk '{print $1}')
    if [ -z "$open_ports" ]; then
        open_ports="Ninguno"
    else
        open_ports=$(echo "$open_ports" | tr '\n' ' ')
    fi
    
    os=$(sudo nmap -O -sV $ip | grep 'Running:' | awk '{print $2 " " $3 " " $4}')
    echo "$ip      $open_ports      $os"
done

echo -e "\n~ Escaneo de puertos completo mi Dogor!"
