# NetPhantom

![Network Scanner](https://img.shields.io/badge/Network%20Scanner-Nmap-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Descripción

**NetPhantom** es un script avanzado para escanear dispositivos y puertos en una red local. Utiliza `arp-scan` para detectar dispositivos conectados y `nmap` para escanear puertos abiertos y detectar el sistema operativo de los dispositivos encontrados. Ideal para pruebas de penetración en entornos controlados.

### Funcionalidades

- **Detección de Dispositivos en la Red Local:** Utiliza `arp-scan` para detectar todos los dispositivos conectados en la red local.
- **Escaneo de Puertos Abiertos:** Utiliza `nmap` para escanear todos los puertos abiertos en cada dispositivo encontrado.
- **Identificación del Sistema Operativo:** Utiliza `nmap` para identificar el sistema operativo y la versión de los dispositivos escaneados.

### Parámetros de Entrada

El script toma un parámetro de entrada:

- `<interfaz>`: La interfaz de red a utilizar para el escaneo.

### Uso

```bash
./net_phantom.sh <interfaz>
