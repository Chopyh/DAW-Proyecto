FROM ubuntu:22.04

# Evitar preguntas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar Postfix, Dovecot y utilidades de red (dnsutils es vital)
RUN apt-get update && apt-get install -y \
    postfix \
    dovecot-imapd \
    dovecot-pop3d \
    iputils-ping \
    dnsutils \
    netcat \
    nano \
    && rm -rf /var/lib/apt/lists/*

# 2. Copiar configuraciones
COPY main.cf /etc/postfix/main.cf
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY entrypoint.sh /entrypoint.sh

# 3. Dar permisos de ejecución al script
RUN chmod +x /entrypoint.sh

# 4. Crear usuarios de prueba
RUN useradd -m -s /bin/bash alumno && echo "alumno:1234" | chpasswd
RUN useradd -m -s /bin/bash profe && echo "profe:1234" | chpasswd

# --- SOLUCIÓN PERMANENTE PARTE 1 ---
# Desactivar la jaula chroot en la configuración de Postfix
RUN postconf -F '*/*/chroot = n'
# -----------------------------------

# 5. Puertos
EXPOSE 25 110 143

# 6. Comando de inicio
CMD ["/entrypoint.sh"]