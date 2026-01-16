#!/bin/bash

# 1. COPIA DE SEGURIDAD DE RED
# Aunque desactivamos chroot, copiamos esto por si alguna librería lo busca
mkdir -p /var/spool/postfix/etc
cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp /etc/hosts /var/spool/postfix/etc/hosts
cp /etc/services /var/spool/postfix/etc/services
chmod 644 /var/spool/postfix/etc/*

# 2. PREPARAR LOGS (Vital para que no falle el tail)
touch /var/log/mail.log
chmod 666 /var/log/mail.log
chown syslog:adm /var/log/mail.log

# 3. ARRANCAR SERVICIOS
echo "Iniciando rsyslog..."
service rsyslog start

echo "Iniciando Postfix..."
service postfix start

echo "Iniciando Dovecot..."
service dovecot start

# 4. BUCLE FINAL
echo "Servidor de Correo (v.Final) Listo."
echo "Usuarios: javier / chopy"
tail -f /var/log/mail.log