FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    postfix \
    dovecot-imapd \
    dovecot-pop3d \
    iputils-ping \
    nano \
    && rm -rf /var/lib/apt/lists/*

COPY main.cf /etc/postfix/main.cf
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN useradd -m -s /bin/bash javier && echo "javier:root" | chpasswd
RUN useradd -m -s /bin/bash chopy && echo "chopy:example" | chpasswd

# 5. Puertos (SMTP, POP3, IMAP)
EXPOSE 25 110 143

# 6. Comando de inicio
CMD ["/entrypoint.sh"]