FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar paquetes (ASEGÚRATE DE QUE ESTÁ 'rsyslog' AQUÍ)
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

# 3. Permisos y Usuarios
RUN chmod +x /entrypoint.sh
RUN useradd -m -s /bin/bash javier && echo "javier:root" | chpasswd
RUN useradd -m -s /bin/bash chopy && echo "chopy:example" | chpasswd

# 4. FIX: Postfix sin jaula
RUN postconf -F '*/*/chroot = n'

EXPOSE 25 110 143

CMD ["/entrypoint.sh"]