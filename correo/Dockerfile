FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar paquetes (Asegurando rsyslog)
RUN apt-get update && apt-get install -y \
    postfix \
    dovecot-imapd \
    dovecot-pop3d \
    iputils-ping \
    dnsutils \
    netcat \
    nano \
    rsyslog \
    && rm -rf /var/lib/apt/lists/*

# 2. Copiar configuraciones
COPY main.cf /etc/postfix/main.cf
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY entrypoint.sh /entrypoint.sh

# 3. Permisos script
RUN chmod +x /entrypoint.sh

# 4. USUARIOS NUEVOS (Javier y Chopy)
RUN useradd -m -s /bin/bash javier && echo "javier:root" | chpasswd
RUN useradd -m -s /bin/bash chopy && echo "chopy:example" | chpasswd

# 5. FIX LOGS: Desactivar lectura del kernel (imklog) porque falla en Docker
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

# 6. FIX POSTFIX: Desactivar jaula chroot
RUN postconf -F '*/*/chroot = n'

EXPOSE 25 110 143

CMD ["/entrypoint.sh"]