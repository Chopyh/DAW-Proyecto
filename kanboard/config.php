<?php

// Habilitar autenticación LDAP
define('LDAP_AUTH', true);

// Servidor LDAP
define('LDAP_SERVER', 'ldap://172.20.0.16');
define('LDAP_PORT', 389);

// SSL/TLS
define('LDAP_SSL_VERIFY', false);
define('LDAP_START_TLS', false);

// Bind DN para búsquedas (cuenta admin)
define('LDAP_BIND_TYPE', 'proxy');
define('LDAP_USERNAME', 'cn=admin,dc=javier,dc=local');
define('LDAP_PASSWORD', 'admin');

// Base DN donde buscar usuarios
define('LDAP_ACCOUNT_BASE', 'ou=Usuarios,dc=javier,dc=local');

// Filtro para encontrar usuarios (busca por uid o mail)
define('LDAP_USER_FILTER', '(&(objectClass=inetOrgPerson)(|(uid=%s)(mail=%s)))');

// Mapeo de atributos LDAP a Kanboard
define('LDAP_ACCOUNT_ID', 'uid');
define('LDAP_ACCOUNT_FULLNAME', 'cn');
define('LDAP_ACCOUNT_EMAIL', 'mail');

// Crear usuario automáticamente en Kanboard si existe en LDAP
define('LDAP_ACCOUNT_CREATION', true);

// Configuración de grupos LDAP
define('LDAP_GROUP_ADMIN_DN', 'cn=administradores,ou=Groups,dc=javier,dc=local');
define('LDAP_GROUP_MANAGER_DN', 'cn=profesores,ou=Groups,dc=javier,dc=local');

// Base DN de grupos
define('LDAP_GROUP_BASE_DN', 'ou=Groups,dc=javier,dc=local');
define('LDAP_GROUP_FILTER', '(objectClass=posixGroup)');
define('LDAP_GROUP_ATTRIBUTE_NAME', 'cn');

// Habilitar sincronización de grupos
define('LDAP_GROUP_SYNC', true);
