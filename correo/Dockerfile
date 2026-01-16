FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar paquetes (Incluyendo rsyslog y herramientas de red)
RUN apt-get update && apt-get install -y \
    postfix \
    dovecot-imapd \
    dovecot-pop3d \
    rsyslog \
    iputils-ping \
    dnsutils \
    netcat \
    nano \
    && rm -rf /var/lib/apt/lists/*

# 2. Copiar archivos de configuración
COPY main.cf /etc/postfix/main.cf
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY entrypoint.sh /entrypoint.sh

# 3. Permisos y Usuarios
RUN chmod +x /entrypoint.sh

# Crear usuarios (javier:root y chopy:example)
RUN useradd -m -s /bin/bash javier && echo "javier:root" | chpasswd
RUN useradd -m -s /bin/bash chopy && echo "chopy:example" | chpasswd

# --- PARCHES DE ARREGLO (FIXES) ---

# FIX 1: Logs. Desactivar módulo imklog que falla en Docker
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

# FIX 2: Postfix. Desactivar Jaula Chroot para evitar errores de DNS
RUN postconf -F '*/*/chroot = n'

# FIX 3: Alias. Configurar y generar la base de datos de alias (.db)
# Esto evita el error "status=deferred (alias database unavailable)"
RUN touch /etc/aliases
RUN postconf -e 'alias_maps = hash:/etc/aliases'
RUN postconf -e 'alias_database = hash:/etc/aliases'
RUN newaliases

# ----------------------------------

EXPOSE 25 110 143

CMD ["/entrypoint.sh"]