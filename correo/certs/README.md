# Certificados para correo

Coloca aquí el certificado y clave **solo para mail**.

Rutas en el contenedor:
- Certificado: /etc/ssl/mail/mail.crt
- Clave: /etc/ssl/mail/mail.key

Ejemplo de autofirmado (1 año) para mail.javier.local:
```
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
  -keyout correo/certs/mail.key \
  -out correo/certs/mail.crt \
  -subj "/CN=mail.javier.local" \
  -addext "subjectAltName=DNS:mail.javier.local"
```
Luego:
1) Ajusta permisos si quieres validar: `chmod 600 correo/certs/mail.key && chmod 644 correo/certs/mail.crt`
2) Reinicia el servicio: `docker-compose up -d --build mail`
