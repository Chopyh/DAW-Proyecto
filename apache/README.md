# Apache HTTP Server 2.4

Este directorio contiene la configuración y datos del servidor web principal de la infraestructura, que actúa tanto como servidor de contenido estático como proxy inverso para Tomcat.

## Estructura

- **Dockerfile**: Imagen personalizada basada en `httpd:2.4` (aunque en docker-compose se usa `build: ./apache` o imagen directa, aquí parece configurarse localmente).
- **conf/**: Archivos de configuración.
  - `httpd.conf`: Configuración global (Módulos, LogLevel, etc.).
  - `extra/edutech.conf`: Punto de entrada para la configuración personalizada.
  - `extra/vhosts/*.conf`: Definiciones individuales de Virtual Hosts.
  - `ssl/`: Certificados autofirmados (`server.crt`, `server.key`).
- **www/**: Directorio raíz para sitios estáticos (`produccion`, `pruebas`).
- **logs/**: Directorio mapeado para logs de acceso y error.

## Configuración y Virtual Hosts

La configuración se ha modularizado para facilitar el mantenimiento. `edutech.conf` incluye todos los archivos `.conf` dentro de `extra/vhosts/`.

### Sitios Habilitados

1.  **Redirección (`00-redirect.conf`)**:
    - Puerto: 80
    - Acción: Redirige todo el tráfico HTTP a HTTPS (`pruebas.javier.local`).

2.  **Producción (`10-produccion.conf`)**:
    - URL: `https://produccion.javier.local`
    - Ruta: `/usr/local/apache2/htdocs/produccion`
    - Características: `.htaccess` habilitado.

3.  **Pruebas (`20-pruebas.conf`)**:
    - URL: `https://pruebas.javier.local`
    - Ruta: `/usr/local/apache2/htdocs/pruebas`
    - Características: `.htaccess` deshabilitado (más restrictivo).

4.  **Tomcat Proxy (`30-tomcat.conf`)**:
    - URL: `https://tomcat.javier.local`
    - Acción: Proxy inverso hacia el contenedor `tomcat` en el puerto 8080.
    - Preserva el Host original en las cabeceras.

## Módulos Clave
- `mod_ssl`: Para soporte HTTPS.
- `mod_proxy` & `mod_proxy_http`: Para conectar con Tomcat.
- `mod_rewrite`: Para redirecciones avanzadas si fueran necesarias.
