#!/bin/bash
# --- correo/entrypoint.sh ---

# 1. Copiar archivos de red del sistema al entorno de Postfix
# (Aunque chroot sea 'n', esto previene errores si alguna librería lo busca ahí)
mkdir -p /var/spool/postfix/etc
cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp /etc/hosts /var/spool/postfix/etc/hosts
cp /etc/services /var/spool/postfix/etc/services

# Asegurar permisos
chmod 644 /var/spool/postfix/etc/*

# 2. Iniciar Syslog (Para ver errores reales si falla)
service rsyslog start

# 3. Iniciar Servicios
echo "Iniciando Postfix..."
service postfix start

echo "Iniciando Dovecot..."
service dovecot start

# 4. Loop de logs
echo "Servidor Correo (IPv4 + No-Chroot) Listo."
tail -f /var/log/mail.log