FROM ubuntu/bind9

# Copiar el script de inicio
COPY entrypoint.sh /usr/local/bin/

# Asegurar que es ejecutable has
RUN chmod +x /usr/local/bin/entrypoint.sh

# Ejecutar script al iniciar
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
