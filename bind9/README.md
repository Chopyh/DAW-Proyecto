# BIND9 Servidor DNS Maestro

Este servicio proporciona la resolución de nombres autoritativa para el dominio `javier.local` dentro de la red privada del proyecto.

## Configuración

- **Tipo**: Master (Maestro).
- **Archivo Principal**: `conf/named.conf`.
- **Directorio de Trabajo**: `/var/lib/bind`.

## Zonas Definidas

### Zona Directa (`javier.local`)
- **Archivo**: `zones/db.javier.local`
- **Función**: Traduce nombres de dominio a direcciones IP (ej. `tomcat.javier.local` -> `172.20.0.14`).

### Zona Inversa (`172.20.0.0/16`)
- **Archivo**: `zones/db.172.20.0`
- **Función**: Traduce direcciones IP a nombres (PTR records). Utilizado para validaciones de red y diagnóstico.

## Reenvío (Forwarders)
El servidor está configurado para reenviar consultas externas (internet) a los DNS de Google (`8.8.8.8`, `8.8.4.4`), permitiendo que los contenedores tengan resolución completa de internet.
