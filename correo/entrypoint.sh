#!/bin/bash
# --- correo/entrypoint.sh ---

# 1. Configurar entorno de red para Postfix
mkdir -p /var/spool/postfix/etc
cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp /etc/hosts /var/spool/postfix/etc/hosts
cp /etc/services /var/spool/postfix/etc/services
chmod 644 /var/spool/postfix/etc/*

# 2. Preparar el archivo de log (Truco para evitar errores)
# Lo creamos vacío y le damos permisos totales para que rsyslog no falle al escribir
touch /var/log/mail.log
chmod 666 /var/log/mail.log
chown syslog:adm /var/log/mail.log

# 3. Iniciar Syslog
echo "Iniciando rsyslog..."
service rsyslog start

# 4. Iniciar Servicios de Correo
echo "Iniciando Postfix..."
service postfix start

echo "Iniciando Dovecot..."
service dovecot start

# 5. Loop final mostrando el log
echo "Servidor listo. Usuarios: javier / chopy. Logs:"
tail -f /var/log/mail.log