# Servidor de Correo (Postfix + Dovecot)

Servicio integrado de correo electrónico que utiliza LDAP para la autenticación y gestión de usuarios.

## Componentes

- **Postfix (SMTP)**: Agente de Transferencia de Correo (MTA). Escucha en puerto 25.
- **Dovecot (IMAP/POP3)**: Agente de Entrega de Correo (MDA/LDA) y servidor IMAP/POP3. Puertos 143/110.

## Integración LDAP

Este contenedor no gestiona usuarios locales de Linux para el correo. En su lugar, consulta el directorio activo (contenedor `ldap`) para validar usuarios y contraseñas.

- **Configuración Postfix**: `main.cf` y `ldap-users.cf` definen cómo buscar buzones en LDAP.
- **Configuración Dovecot**: `dovecot-ldap.conf.ext` define la autenticación contra LDAP.
- **Dominio Virtual**: `javier.local`.

## Almacenamiento

Los correos se almacenan en formato **Maildir** en `/var/mail/vhosts`, mapeado internamente en el contenedor.

## Dockerfile

El `Dockerfile` personalizado:
1. Instala `postfix-ldap` y `dovecot-ldap`.
2. Crea un usuario `vmail` (UID 5000) propietario de los buzones.
3. Copia los scripts de configuración y ejecución (`entrypoint.sh`).
