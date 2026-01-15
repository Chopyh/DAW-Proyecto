#!/bin/bash

# --- SOLUCIÓN PERMANENTE PARTE 2 ---
# Asegurar que Postfix tiene acceso a los archivos de red del contenedor
# Esto debe hacerse al arrancar, porque Docker cambia la IP/DNS en cada inicio.

# 1. Crear directorio dentro de la jaula (por si acaso Postfix decide usarla)
mkdir -p /var/spool/postfix/etc

# 2. Copiar los archivos vitales del sistema actual
cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp /etc/services /var/spool/postfix/etc/services
cp /etc/hosts /var/spool/postfix/etc/hosts

# 3. Arrancar servicios
echo "Arrancando Postfix..."
service postfix start

echo "Arrancando Dovecot..."
service dovecot start

# 4. Mantener el contenedor vivo
echo "Servidor de correo listo. Mostrando logs..."
touch /var/log/mail.log
tail -f /var/log/mail.log