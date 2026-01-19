# BIND9 Servidor DNS Esclavo

Este servicio actúa como respaldo (redundancia) para la resolución de nombres DNS.

## Configuración

- **Tipo**: Slave (Esclavo).
- **Archivo Principal**: `conf/named.conf`.

## Funcionamiento

El servidor esclavo no mantiene sus propios archivos de zona editables manualmente. En su lugar, está configurado para transferir las zonas automáticamente desde el servidor maestro.

- **Master IP**: `172.20.0.13` (Contenedor `dns`).
- **Zonas Sincronizadas**:
  - `javier.local`
  - `0.20.172.in-addr.arpa` (Inversa)

Esto asegura que si el servidor maestro cae, el esclavo puede seguir respondiendo peticiones DNS si los clientes están configurados para usarlo como secundario.
