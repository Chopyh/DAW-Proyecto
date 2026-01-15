#!/bin/bash

# ... (parte de arriba con las copias de resolv.conf y hosts igual que antes) ...

# 1. Configurar entorno y permisos
mkdir -p /var/spool/postfix/etc
cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp /etc/hosts /var/spool/postfix/etc/hosts
cp /etc/services /var/spool/postfix/etc/services
chmod 644 /var/spool/postfix/etc/*

# 2. Iniciar Syslog
service rsyslog start

# 3. Iniciar Servicios
echo "Iniciando Postfix..."
service postfix start

echo "Iniciando Dovecot..."
service dovecot start

# 4. TRUCO PARA QUE NO FALLE: Crear el archivo si no existe
touch /var/log/mail.log
chmod 666 /var/log/mail.log

echo "Servidor Correo Listo. Mostrando logs..."
# Ahora sí, leemos el archivo que acabamos de crear
tail -f /var/log/mail.log