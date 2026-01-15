# --- correo/Dockerfile ---
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar paquetes necesarios (incluyendo herramientas de red y librerias)
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

# 3. Permisos
RUN chmod +x /entrypoint.sh

# 4. Usuarios
RUN useradd -m -s /bin/bash alumno && echo "alumno:1234" | chpasswd
RUN useradd -m -s /bin/bash profe && echo "profe:1234" | chpasswd

# 5. FIX CRÍTICO: Desactivar CHROOT permanentemente en la imagen
RUN postconf -F '*/*/chroot = n'

EXPOSE 25 110 143

CMD ["/entrypoint.sh"]