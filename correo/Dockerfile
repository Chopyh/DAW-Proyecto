# --- correo/Dockerfile ---
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar paquetes (AÑADIDOS DRIVERS LDAP)
RUN apt-get update && apt-get install -y \
    postfix \
    postfix-ldap \
    dovecot-imapd \
    dovecot-pop3d \
    dovecot-ldap \
    rsyslog \
    iputils-ping \
    dnsutils \
    netcat \
    nano \
    && rm -rf /var/lib/apt/lists/*

# 2. Config y Scripts
COPY main.cf /etc/postfix/main.cf
COPY ldap-users.cf /etc/postfix/ldap-users.cf
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && sed -i 's/\r$//' /entrypoint.sh

# 3. USUARIO VIRTUAL (El dueño de los buzones)
# UID 5000 es el estándar para usuario de correo virtual
RUN groupadd -g 5000 vmail
RUN useradd -u 5000 -g vmail -s /usr/sbin/nologin -d /var/mail/vhosts -m vmail

# 4. FIXES (Logs y Chroot igual que antes)
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
RUN postconf -F '*/*/chroot = n'
RUN touch /etc/aliases && newaliases

EXPOSE 25 110 143 465 587 993 995
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]