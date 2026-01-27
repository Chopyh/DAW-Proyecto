FROM ubuntu/bind9

# Copiar el script de inicio
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Asegurar que es ejecutable y normalizar finales de línea
RUN chmod +x /usr/local/bin/entrypoint.sh && sed -i 's/\r$//' /usr/local/bin/entrypoint.sh

# Ejecutar script al iniciar
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
