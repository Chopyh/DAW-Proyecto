#!/bin/bash

# 1. Configurar entorno de red para Postfix
mkdir -p /var/spool/postfix/etc
cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp /etc/hosts /var/spool/postfix/etc/hosts
cp /etc/services /var/spool/postfix/etc/services
chmod 644 /var/spool/postfix/etc/*

# 2. Iniciar Syslog (Con protección de fallo)
# El "|| true" hace que si rsyslog falla, el script continúe y no se apague el contenedor
echo "Iniciando rsyslog..."
service rsyslog start || echo "ADVERTENCIA: rsyslog no arrancó, pero continuamos."

# 3. Iniciar Servicios de Correo
echo "Iniciando Postfix..."
service postfix start

echo "Iniciando Dovecot..."
service dovecot start

# 4. CRÍTICO: Crear el archivo de log ANTES de leerlo
# Si no existe, lo creamos vacío para que 'tail' no se queje
touch /var/log/mail.log
chmod 666 /var/log/mail.log

echo "Servidor Correo Listo. Mostrando logs..."
tail -f /var/log/mail.log