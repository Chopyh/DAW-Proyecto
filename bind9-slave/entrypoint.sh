#!/bin/bash
set -e

echo "Configurando permisos para Bind9 Slave..."

# Asegurar que el directorio existe y tiene los permisos correctos
if [ -d "/var/lib/bind" ]; then
    # Asignar propietario 'bind' recursivamente
    chown -R bind:bind /var/lib/bind
    # Dar permisos de escritura
    chmod -R 775 /var/lib/bind
    echo "Permisos corregidos en /var/lib/bind"
fi

# Iniciar el servicio DNS (Named) en primer plano (-g) como usuario bind (-u bind)
echo "Iniciando named..."
exec /usr/sbin/named -g -u bind
