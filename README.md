# 🏢 Proyecto de Infraestructura DAW: EduTech Solutions

Infraestructura de red empresarial completa desplegada con Docker Compose. Incluye DNS (maestro/esclavo), servidor web Apache con SSL, servidor de aplicaciones Tomcat, correo seguro (Postfix + Dovecot), directorio LDAP centralizado y gestión de proyectos con Kanboard.

---

## 📋 Índice

1. [Arquitectura General](#-arquitectura-general)
2. [Requisitos Previos](#-requisitos-previos)
3. [Inicio Rápido](#-inicio-rápido)
4. [Servicios Desplegados](#-servicios-desplegados)
5. [Configuración DNS](#-configuración-dns)
6. [Servidor Web Apache](#-servidor-web-apache)
7. [Servidor de Aplicaciones Tomcat](#-servidor-de-aplicaciones-tomcat)
8. [Gestión de Proyectos - Kanboard](#-gestión-de-proyectos---kanboard)
9. [Directorio LDAP](#-directorio-ldap)
10. [Servidor de Correo](#-servidor-de-correo)
11. [Certificados SSL/TLS](#-certificados-ssltls)
12. [Comandos de Prueba](#-comandos-de-prueba)
13. [Resolución de Problemas](#-resolución-de-problemas)
14. [Estructura del Proyecto](#-estructura-del-proyecto)

---

## 🏗 Arquitectura General

### Diagrama de Red

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Red Docker: red_daw                               │
│                           Subnet: 172.20.0.0/16                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │  DNS Master  │    │  DNS Slave   │    │    Apache    │                  │
│  │ 172.20.0.13  │───▶│ 172.20.0.17  │    │ 172.20.0.15  │                  │
│  │   :53/tcp    │    │  :5454/tcp   │    │  :80, :443   │                  │
│  └──────────────┘    └──────────────┘    └──────┬───────┘                  │
│         │                                       │                           │
│         │              ┌────────────────────────┼────────────────┐          │
│         │              │                        │                │          │
│         ▼              ▼                        ▼                ▼          │
│  ┌──────────────┐ ┌──────────────┐    ┌──────────────┐  ┌──────────────┐   │
│  │    Tomcat    │ │   Kanboard   │    │     LDAP     │  │     Mail     │   │
│  │ 172.20.0.14  │ │ 172.20.0.19  │    │ 172.20.0.16  │  │ 172.20.0.18  │   │
│  │    :8080     │ │     :80      │    │ :389, :636   │  │ :25,:587,:993│   │
│  └──────────────┘ └──────────────┘    └──────────────┘  └──────────────┘   │
│                                              │                              │
│                                              ▼                              │
│                                       ┌──────────────┐                      │
│                                       │ phpLDAPadmin │                      │
│                                       │    :8080     │                      │
│                                       └──────────────┘                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Tabla de Servicios

| Servicio         | Contenedor            | IP          | Puertos Host               | Imagen                |
| ---------------- | --------------------- | ----------- | -------------------------- | --------------------- |
| **DNS Master**   | `dns_javier`          | 172.20.0.13 | 53/tcp, 53/udp             | `ubuntu/bind9`        |
| **DNS Slave**    | `dns_slave_javier`    | 172.20.0.17 | 5454/tcp, 5454/udp         | `ubuntu/bind9`        |
| **Apache**       | `apache_javier`       | 172.20.0.15 | 80, 443                    | `httpd:2.4` (custom)  |
| **Tomcat**       | `tomcat_javier`       | 172.20.0.14 | - (vía Apache)             | `tomcat:9.0`          |
| **Kanboard**     | `kanboard_javier`     | 172.20.0.19 | - (vía Apache)             | `kanboard/kanboard`   |
| **LDAP**         | `ldap_javier`         | 172.20.0.16 | 389, 636                   | `osixia/openldap`     |
| **phpLDAPadmin** | `phpldapadmin_javier` | Dinámica    | 8080                       | `osixia/phpldapadmin` |
| **Mail**         | `mail_javier`         | 172.20.0.18 | 25,110,143,465,587,993,995 | Ubuntu 22.04 (custom) |

---

## ⚙ Requisitos Previos

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **OpenSSL** (para generar certificados)
- Sistema operativo: Linux, Windows (WSL2) o macOS

---

## 🚀 Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone <url-repositorio>
cd DAW-Proyecto
```

### 2. Generar certificados SSL

**Para Apache (web):**
```bash
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
  -keyout apache/conf/server.key \
  -out apache/conf/server.crt \
  -subj "/CN=*.javier.local" \
  -addext "subjectAltName=DNS:*.javier.local,DNS:javier.local"
```

**Para Mail (correo):**
```bash
docker run --rm -v "${PWD}/correo/certs:/out" ubuntu:22.04 sh -c "\
  apt-get update >/dev/null && apt-get install -y openssl >/dev/null && \
  openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -keyout /out/mail.key \
    -out /out/mail.crt \
    -subj '/CN=mail.javier.local' \
    -addext 'subjectAltName=DNS:mail.javier.local' && \
  chmod 600 /out/mail.key && chmod 644 /out/mail.crt"
```

### 3. Levantar todos los servicios

```bash
docker-compose up -d --build
```

### 4. Verificar estado

```bash
docker-compose ps
```

### 5. Configurar hosts del cliente

Añadir al archivo hosts (`C:\Windows\System32\drivers\etc\hosts` en Windows, `/etc/hosts` en Linux/Mac):

```text
127.0.0.1   produccion.javier.local
127.0.0.1   pruebas.javier.local
127.0.0.1   tomcat.javier.local
127.0.0.1   proyectos.javier.local
127.0.0.1   mail.javier.local
```

---

## 🌐 Configuración DNS

### Servidor Maestro (172.20.0.13)

**Archivo de configuración:** `bind9/conf/named.conf`

```
options {
    directory "/var/cache/bind";
    allow-query { any; };
    recursion yes;
    forwarders { 8.8.8.8; 8.8.4.4; };
    dnssec-validation no;
};

zone "javier.local" { type master; file "/var/lib/bind/db.javier.local"; };
zone "0.20.172.in-addr.arpa" { type master; file "/var/lib/bind/db.172.20.0"; };
```

### Zona Directa: `javier.local`

**Archivo:** `bind9/zones/db.javier.local`

| Registro     | Tipo  | Valor             | Descripción        |
| ------------ | ----- | ----------------- | ------------------ |
| `ns1`        | A     | 172.20.0.13       | DNS Master         |
| `ns2`        | A     | 172.20.0.17       | DNS Slave          |
| `tomcat`     | A     | 172.20.0.14       | Servidor Tomcat    |
| `www`        | A     | 172.20.0.15       | Servidor Apache    |
| `ldap`       | A     | 172.20.0.16       | Servidor LDAP      |
| `mail`       | A     | 172.20.0.18       | Servidor Correo    |
| `proyectos`  | A     | 172.20.0.19       | Kanboard           |
| `produccion` | CNAME | www               | Alias producción   |
| `pruebas`    | CNAME | www               | Alias pruebas      |
| `@`          | MX 10 | mail.javier.local | Registro de correo |

### Zona Inversa: `0.20.172.in-addr.arpa`

**Archivo:** `bind9/zones/db.172.20.0`

| IP          | PTR                                   |
| ----------- | ------------------------------------- |
| 172.20.0.13 | ns1.javier.local                      |
| 172.20.0.14 | tomcat-server.javier.local            |
| 172.20.0.15 | apache.javier.local, www.javier.local |
| 172.20.0.16 | ldap-server.javier.local              |
| 172.20.0.17 | ns2.javier.local                      |
| 172.20.0.18 | mail.javier.local                     |
| 172.20.0.19 | proyectos.javier.local                |

### Servidor Esclavo (172.20.0.17)

Replica automáticamente las zonas del maestro mediante transferencia de zona (AXFR).

---

## 🌍 Servidor Web Apache

### Configuración General

- **Imagen base:** `httpd:2.4`
- **Dockerfile:** `apache/Dockerfile`
- **SSL/TLS:** Habilitado en todos los VirtualHosts
- **Módulos activos:** `mod_ssl`, `mod_proxy`, `mod_proxy_http`, `mod_rewrite`

### VirtualHosts Configurados

#### 1. Redirección HTTP → HTTPS
**Archivo:** `apache/conf/extra/vhosts/00-redirect.conf`
- Todo el tráfico HTTP (puerto 80) se redirige a HTTPS

#### 2. Producción
**Archivo:** `apache/conf/extra/vhosts/10-produccion.conf`
- **URL:** https://produccion.javier.local
- **DocumentRoot:** `/usr/local/apache2/htdocs/produccion`
- **Características:** AllowOverride All, Indexes, FollowSymLinks
- **Logs:** `produccion_error.log`, `produccion_access.log`

#### 3. Pruebas
**Archivo:** `apache/conf/extra/vhosts/20-pruebas.conf`
- **URL:** https://pruebas.javier.local
- **DocumentRoot:** `/usr/local/apache2/htdocs/pruebas`
- **Características:** AllowOverride None, Indexes, FollowSymLinks
- **Logs:** `pruebas_error.log`, `pruebas_access.log`

#### 4. Tomcat (Proxy Inverso)
**Archivo:** `apache/conf/extra/vhosts/30-tomcat.conf`
- **URL:** https://tomcat.javier.local
- **Backend:** `http://tomcat:8080/`
- **Tipo:** Proxy inverso con terminación SSL
- **Logs:** `tomcat_error.log`, `tomcat_access.log`

#### 5. Kanboard (Proxy Inverso)
**Archivo:** `apache/conf/extra/vhosts/40-kanboard.conf`
- **URL:** https://proyectos.javier.local
- **Backend:** `http://kanboard:80/`
- **Tipo:** Proxy inverso con terminación SSL
- **Logs:** `proyectos_error.log`, `proyectos_access.log`

### Estructura de Directorios

```
apache/
├── conf/
│   ├── httpd.conf              # Configuración principal
│   ├── server.crt              # Certificado SSL
│   ├── server.key              # Clave privada SSL
│   └── extra/
│       ├── edutech.conf        # Include de vhosts
│       └── vhosts/
│           ├── 00-redirect.conf
│           ├── 10-produccion.conf
│           ├── 20-pruebas.conf
│           ├── 30-tomcat.conf
│           └── 40-kanboard.conf
├── www/
│   ├── produccion/
│   │   └── index.html
│   ├── pruebas/
│   │   └── index.html
│   └── proyectos/
└── logs/
```

---

## ☕ Servidor de Aplicaciones Tomcat

- **Imagen:** `tomcat:9.0`
- **IP interna:** 172.20.0.14
- **Puerto interno:** 8080
- **Acceso:** Solo vía proxy Apache en https://tomcat.javier.local
- **Aplicaciones:** Montadas en `tomcat/webapps/`

### Desplegar aplicaciones

Coloca archivos `.war` o directorios de aplicación en `tomcat/webapps/`:

```bash
cp mi-aplicacion.war tomcat/webapps/
docker-compose restart tomcat
```

---

## 📊 Gestión de Proyectos - Kanboard

- **Imagen:** `kanboard/kanboard:latest`
- **IP interna:** 172.20.0.19
- **Acceso:** https://proyectos.javier.local
- **Credenciales por defecto:** `admin` / `admin`

### Persistencia

```
kanboard/
├── data/       # Base de datos SQLite y archivos
└── plugins/    # Plugins adicionales
```

---

## 📁 Directorio LDAP

### Configuración del Servidor

- **Imagen:** `osixia/openldap:latest`
- **IP:** 172.20.0.16
- **Puertos:** 389 (LDAP), 636 (LDAPS)
- **Dominio base:** `dc=javier,dc=local`
- **Organización:** EduTech Solutions
- **Admin DN:** `cn=admin,dc=javier,dc=local`
- **Admin Password:** `admin`

### Estructura del Directorio

```
dc=javier,dc=local
├── ou=Usuarios          # Unidad organizativa de usuarios
│   ├── cn=Javier Lopez
│   ├── cn=Chopy Martinez
│   ├── cn=Ana Garcia
│   ├── cn=Pedro Sanchez
│   └── cn=Admin Sistema
└── ou=Groups            # Unidad organizativa de grupos
    ├── cn=administradores (GID 5001)
    ├── cn=profesores (GID 5002)
    └── cn=alumnos (GID 5003)
```

### Grupos

| Grupo             | GID  | Descripción                 |
| ----------------- | ---- | --------------------------- |
| `administradores` | 5001 | Administradores del sistema |
| `profesores`      | 5002 | Personal docente            |
| `alumnos`         | 5003 | Estudiantes                 |

### Usuarios

| Usuario  | UID   | Grupo           | Email               | Contraseña |
| -------- | ----- | --------------- | ------------------- | ---------- |
| `javier` | 10000 | profesores      | javier@javier.local | root       |
| `chopy`  | 10001 | alumnos         | chopy@javier.local  | example    |
| `ana`    | 10002 | profesores      | ana@javier.local    | prof123    |
| `pedro`  | 10003 | alumnos         | pedro@javier.local  | alumno123  |
| `admin`  | 10004 | administradores | admin@javier.local  | admin123   |

### phpLDAPadmin

- **URL:** http://localhost:8080
- **Login DN:** `cn=admin,dc=javier,dc=local`
- **Password:** `admin`

### Reinicializar LDAP

Para recargar el `bootstrap.ldif` con cambios:

```bash
docker-compose down
docker volume rm daw-proyecto_ldap-data 2>/dev/null || true
docker-compose up -d ldap
docker-compose up -d
```

---

## 📧 Servidor de Correo

### Componentes

- **MTA (SMTP):** Postfix
- **MDA/IMAP/POP3:** Dovecot
- **Autenticación:** LDAP (ou=Usuarios)
- **Almacenamiento:** Maildir en `/var/mail/vhosts`

### Puertos

| Puerto | Servicio   | Seguridad                   |
| ------ | ---------- | --------------------------- |
| 25     | SMTP       | STARTTLS                    |
| 465    | SMTPS      | TLS implícito               |
| 587    | Submission | STARTTLS obligatorio + AUTH |
| 110    | POP3       | STARTTLS                    |
| 143    | IMAP       | STARTTLS                    |
| 993    | IMAPS      | TLS implícito               |
| 995    | POP3S      | TLS implícito               |

### Seguridad Implementada

**Postfix (`correo/main.cf`):**
- TLS habilitado con certificado propio
- SASL autenticación vía Dovecot
- Solo usuarios autenticados pueden hacer relay
- Protocolos SSLv2/SSLv3 deshabilitados

**Dovecot (`correo/dovecot.conf`):**
- SSL requerido (`ssl = required`)
- TLS mínimo v1.2
- Plaintext auth deshabilitado
- Socket auth para Postfix SASL

### Archivos de Configuración

```
correo/
├── Dockerfile              # Imagen personalizada Ubuntu 22.04
├── main.cf                 # Configuración Postfix
├── dovecot.conf            # Configuración Dovecot
├── dovecot-ldap.conf.ext   # Autenticación LDAP Dovecot
├── ldap-users.cf           # Búsqueda LDAP Postfix
├── entrypoint.sh           # Script de inicio
└── certs/
    ├── mail.crt            # Certificado TLS
    ├── mail.key            # Clave privada TLS
    └── README.md
```

### Usuarios de Correo

Los usuarios de correo son los mismos del LDAP:
- `javier@javier.local`
- `chopy@javier.local`
- `ana@javier.local`
- `pedro@javier.local`
- `admin@javier.local`

### Configurar Cliente de Correo

**Servidor entrante (IMAP):**
- Servidor: `mail.javier.local`
- Puerto: 993 (IMAPS) o 143 (IMAP+STARTTLS)
- Seguridad: SSL/TLS
- Autenticación: Contraseña normal

**Servidor saliente (SMTP):**
- Servidor: `mail.javier.local`
- Puerto: 587 (Submission) o 465 (SMTPS)
- Seguridad: STARTTLS (587) o SSL/TLS (465)
- Autenticación: Contraseña normal

---

## 🔐 Certificados SSL/TLS

### Apache (Web)

- **Ubicación:** `apache/conf/server.crt`, `apache/conf/server.key`
- **CN:** `*.javier.local`
- **Uso:** produccion, pruebas, tomcat, proyectos

**Regenerar:**
```bash
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
  -keyout apache/conf/server.key \
  -out apache/conf/server.crt \
  -subj "/CN=*.javier.local" \
  -addext "subjectAltName=DNS:*.javier.local,DNS:javier.local"
```

### Correo (Mail)

- **Ubicación:** `correo/certs/mail.crt`, `correo/certs/mail.key`
- **CN:** `mail.javier.local`
- **Uso:** Postfix SMTP, Dovecot IMAP/POP3

**Regenerar:**
```bash
docker run --rm -v "${PWD}/correo/certs:/out" ubuntu:22.04 sh -c "\
  apt-get update >/dev/null && apt-get install -y openssl >/dev/null && \
  openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -keyout /out/mail.key -out /out/mail.crt \
    -subj '/CN=mail.javier.local' \
    -addext 'subjectAltName=DNS:mail.javier.local' && \
  chmod 600 /out/mail.key && chmod 644 /out/mail.crt"
```

---

## 🧪 Comandos de Prueba

### Verificar DNS

**Resolución directa:**
```bash
# Desde el host
dig @127.0.0.1 proyectos.javier.local +short
dig @127.0.0.1 mail.javier.local +short
dig @127.0.0.1 -t MX javier.local +short

# Desde contenedor
docker-compose exec dns dig @localhost proyectos.javier.local +short
```

**Resolución inversa:**
```bash
# Probar todas las IPs
for ip in 13 14 15 16 17 18 19; do
  echo "=== 172.20.0.$ip ==="
  dig @127.0.0.1 -x 172.20.0.$ip +short
done
```

### Verificar Apache

```bash
# Probar HTTPS
curl -k https://produccion.javier.local
curl -k https://pruebas.javier.local
curl -k https://tomcat.javier.local
curl -k https://proyectos.javier.local

# Verificar certificado
openssl s_client -connect 127.0.0.1:443 -servername produccion.javier.local </dev/null
```

### Verificar Correo

```bash
# SMTP con STARTTLS
openssl s_client -starttls smtp -connect mail.javier.local:587

# SMTPS directo
openssl s_client -connect mail.javier.local:465

# IMAPS
openssl s_client -connect mail.javier.local:993

# POP3S
openssl s_client -connect mail.javier.local:995
```

### Verificar LDAP

```bash
# Buscar usuarios
docker-compose exec ldap ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=javier,dc=local" -w admin \
  -b "ou=Usuarios,dc=javier,dc=local" "(objectClass=inetOrgPerson)"

# Buscar grupos
docker-compose exec ldap ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=javier,dc=local" -w admin \
  -b "ou=Groups,dc=javier,dc=local" "(objectClass=posixGroup)"
```

---

## 🔧 Resolución de Problemas

### DNS no resuelve después de cambios

```bash
# Incrementar serial en archivos de zona y reiniciar
docker-compose restart dns dns-slave

# O forzar recarga
docker-compose exec dns rndc reload
```

### LDAP no carga usuarios nuevos

```bash
# Eliminar volumen y recrear
docker-compose down
docker volume rm daw-proyecto_ldap-data
docker-compose up -d ldap
```

### Certificados no válidos

```bash
# Verificar fechas
openssl x509 -in apache/conf/server.crt -noout -dates
openssl x509 -in correo/certs/mail.crt -noout -dates

# Regenerar si expirados (ver sección Certificados)
```

### Correo no autentica

```bash
# Ver logs de correo
docker-compose logs mail | tail -50

# Verificar conexión LDAP desde correo
docker-compose exec mail ldapsearch -x -H ldap://172.20.0.16 \
  -D "cn=admin,dc=javier,dc=local" -w admin \
  -b "ou=Usuarios,dc=javier,dc=local" "(uid=javier)"
```

### Apache muestra errores 502/503

```bash
# Verificar que el backend esté corriendo
docker-compose ps tomcat kanboard

# Ver logs de Apache
docker-compose logs apache | tail -20

# Verificar conectividad interna
docker-compose exec apache ping -c 2 tomcat
docker-compose exec apache ping -c 2 kanboard
```

---

## 📂 Estructura del Proyecto

```
DAW-Proyecto/
├── docker-compose.yml          # Orquestación de servicios
├── README.md                   # Esta documentación
│
├── apache/                     # Servidor web
│   ├── Dockerfile
│   ├── conf/
│   │   ├── httpd.conf
│   │   ├── server.crt
│   │   ├── server.key
│   │   └── extra/
│   │       ├── edutech.conf
│   │       └── vhosts/
│   │           ├── 00-redirect.conf
│   │           ├── 10-produccion.conf
│   │           ├── 20-pruebas.conf
│   │           ├── 30-tomcat.conf
│   │           └── 40-kanboard.conf
│   ├── www/
│   │   ├── produccion/
│   │   ├── pruebas/
│   │   └── proyectos/
│   └── logs/
│
├── bind9/                      # DNS Master
│   ├── conf/
│   │   └── named.conf
│   └── zones/
│       ├── db.javier.local
│       └── db.172.20.0
│
├── bind9-slave/                # DNS Slave
│   ├── conf/
│   │   └── named.conf
│   └── zones/
│
├── correo/                     # Servidor de correo
│   ├── Dockerfile
│   ├── main.cf
│   ├── dovecot.conf
│   ├── dovecot-ldap.conf.ext
│   ├── ldap-users.cf
│   ├── entrypoint.sh
│   └── certs/
│       ├── mail.crt
│       ├── mail.key
│       └── README.md
│
├── kanboard/                   # Gestión de proyectos
│   ├── data/
│   └── plugins/
│
├── ldap_data/                  # Datos LDAP
│   └── bootstrap.ldif
│
├── tomcat/                     # Servidor de aplicaciones
│   └── webapps/
│       └── ROOT/
│           └── index.jsp
│
└── res/                        # Recursos (diagramas, etc.)
```

---

## 📄 Licencia

Proyecto educativo para el módulo de Despliegue de Aplicaciones Web (DAW).

---

## 👥 Autores

- **Javier** - Desarrollo e infraestructura

---

*Última actualización: 26 de enero de 2026*
