# Datos LDAP

Este directorio contiene los archivos necesarios para inicializar y persistir la estructura del directorio LDAP.

## Contenido

- **bootstrap.ldif**: Archivo LDIF (LDAP Data Interchange Format) que se carga automáticamente al iniciar el contenedor `ldap` por primera vez si no existen datos previos. Define la estructura inicial de la organización `EduTech Solutions`, unidades organizativas (OU), grupos y usuarios base.

Este volumen es montado en el contenedor `osixia/openldap` en la ruta `/container/service/slapd/assets/config/bootstrap/ldif/custom`.
