#!/bin/bash

# 1. COPIA DE SEGURIDAD DE RED
# Aunque desactivamos chroot, copiamos esto por si alguna librería lo busca
mkdir -p /var/spool/postfix/etc
cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp /etc/hosts /var/spool/postfix/etc/hosts
cp /etc/services /var/spool/postfix/etc/services
chmod 644 /var/spool/postfix/etc/*

# Permisos de certificados TLS
if [ -f /etc/ssl/mail/mail.key ]; then
	chmod 600 /etc/ssl/mail/mail.key
	chown root:root /etc/ssl/mail/mail.key
fi
if [ -f /etc/ssl/mail/mail.crt ]; then
	chmod 644 /etc/ssl/mail/mail.crt
fi

# Habilitar servicios Submission (587) y SMTPS (465) si no existen
if ! grep -q '^submission' /etc/postfix/master.cf; then
cat <<'EOF' >> /etc/postfix/master.cf
submission inet n       -       n       -       -       smtpd
	-o syslog_name=postfix/submission
	-o smtpd_tls_security_level=encrypt
	-o smtpd_sasl_auth_enable=yes
	-o smtpd_client_restrictions=permit_sasl_authenticated,reject
	-o milter_macro_daemon_name=ORIGINATING
smtps     inet n       -       n       -       -       smtpd
	-o syslog_name=postfix/smtps
	-o smtpd_tls_wrappermode=yes
	-o smtpd_sasl_auth_enable=yes
	-o smtpd_client_restrictions=permit_sasl_authenticated,reject
	-o milter_macro_daemon_name=ORIGINATING
EOF
fi

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