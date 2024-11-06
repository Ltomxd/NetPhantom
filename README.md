Escáner de Dispositivos en Red
Este script permite realizar un escaneo detallado de dispositivos conectados a una red local. Utiliza herramientas como arp-scan, nmap y nbtscan para identificar dispositivos, mostrar su información de red (como IP y dirección MAC), detectar puertos abiertos, e intentar identificar el tipo de dispositivo y su sistema operativo. Es compatible con diversos dispositivos, incluidos móviles, tablets, PCs, laptops, y routers, proporcionando una detección precisa de una amplia variedad de equipos de red.

Características
Detección de Dispositivos en la Red: Utiliza arp-scan para identificar rápidamente todos los dispositivos activos en la red local. Esto permite conocer la IP y la dirección MAC de cada dispositivo conectado.
Identificación de Nombres de Dispositivos: Emplea múltiples métodos para obtener el nombre del dispositivo:
Resolución de DNS directa e inversa.
Escaneo NetBIOS (nbtscan) para dispositivos en redes Windows.
Identificación de dispositivos mediante UPnP y DNS-SD usando nmap, comúnmente utilizados en dispositivos IoT y otros dispositivos de red.
Detección del Fabricante de Dispositivos: A través del prefijo de la dirección MAC, el script identifica el fabricante del dispositivo (por ejemplo, Apple, Samsung, Huawei, Dell, HP, Lenovo). Esto es útil para distinguir entre dispositivos móviles, tablets, PCs, y otros equipos de red.
Detección del Sistema Operativo y Tipo de Dispositivo: Utiliza nmap -O para intentar identificar el sistema operativo. Con esto, se puede deducir si el dispositivo es un PC, una laptop, o algún otro equipo basado en el sistema operativo detectado (Windows, Linux, macOS).
Escaneo de Puertos Abiertos y Servicios: Escanea los puertos abiertos en cada dispositivo y utiliza nmap para identificar los servicios activos en cada puerto. Esto es útil para obtener detalles adicionales sobre dispositivos específicos, como routers o servidores.
Barra de Progreso: Muestra el progreso del escaneo de dispositivos en tiempo real.
Exportación de Resultados: Todos los resultados del escaneo se guardan en un archivo de salida con marca de tiempo en un directorio escaneos_historial para un análisis posterior.
Requisitos
El script requiere las siguientes herramientas:

arp-scan: Para detectar dispositivos en la red local.
nmap: Para escanear puertos abiertos y obtener información de sistema operativo y servicios.
nbtscan (opcional): Para detectar nombres NetBIOS en redes Windows.
Si alguna de estas herramientas no está instalada, el script intentará instalar nbtscan automáticamente.



./nombre_del_script.sh <interfaz> [opciones]



Escanear una Interfaz Específica:


Esto escanea todos los dispositivos conectados a la interfaz ens33, detectando sus direcciones IP y MAC, nombres de dispositivo, y realiza un escaneo de puertos abiertos y servicios.


./nombre_del_script.sh ens33 --fast


Escaneo Rápido de Puertos Comunes:


./nombre_del_script.sh ens33 --fast

Realiza un escaneo rápido de los puertos comunes en los dispositivos conectados.

Escaneo en Todas las Interfaces:
./nombre_del_script.sh all

Escanea todas las interfaces de red en el dispositivo, útil para entornos donde hay múltiples redes locales activas.

Mejoras y Cambios Recientes
Mejora en la Detección de Nombres de Dispositivos: Ahora el script usa dig para consultas de DNS inversas, nbtscan para nombres NetBIOS, y scripts de nmap (DNS-SD y UPnP) para detectar dispositivos IoT y otros dispositivos de red.
Identificación de Dispositivos Basada en MAC: Se ha agregado una base de datos de fabricantes mediante el prefijo MAC para mejorar la detección de dispositivos específicos, como Apple, Samsung, Dell, HP y Lenovo.
Detección de Sistema Operativo con nmap -O: Esto permite identificar el sistema operativo en uso (Windows, Linux, macOS), ayudando a distinguir entre PCs, laptops y otros dispositivos.
Escaneo de Servicios y Protocolos Específicos: Con nmap, el script detecta servicios adicionales en dispositivos compatibles, útil para identificar routers, impresoras y dispositivos IoT.
Archivo de Resultados: Los resultados se guardan en un archivo con marca de tiempo, permitiendo consultar escaneos previos en el directorio escaneos_historial.
Barra de Progreso en Tiempo Real: Muestra el progreso del escaneo de dispositivos en tiempo real para facilitar la visualización del avance.
Notas
Permisos de Superusuario: Algunas herramientas utilizadas en el script requieren permisos de superusuario (por ejemplo, arp-scan y nmap), por lo que es posible que debas ejecutar el script con sudo.
Dependencias Opcionales: Si bien nbtscan es opcional, mejora la detección de dispositivos en redes Windows. El script intentará instalarlo automáticamente si no está disponible.
Ejemplo de Salida
La salida generada por el script incluye:

Dirección IP: Dirección IP de cada dispositivo en la red.
Dirección MAC: Dirección MAC de cada dispositivo.
Nombre del Dispositivo: Nombre obtenido a partir de varias técnicas (DNS, NetBIOS, DNS-SD, UPnP, etc.).
Tipo de Dispositivo y Fabricante: Basado en la MAC y, si es posible, en el sistema operativo detectado.
Puertos Abiertos: Lista de puertos abiertos en cada dispositivo y los servicios asociados.
Sistema Operativo: Sistema operativo detectado, si es posible.


