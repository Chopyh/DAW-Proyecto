# DAW-Proyecto: Infraestructura EduTech Solutions

## Descripción General

Este proyecto implementa una infraestructura completa de servicios de red utilizando **Docker** y **Docker Compose**. Proporciona una solución educativa integrada llamada **EduTech Solutions** con múltiples servidores interconectados que funcionan de manera coordinada.

La infraestructura está diseñada para demostrar conceptos clave de administración de sistemas, redes y servicios web en un entorno containerizado.

---

## Arquitectura del Proyecto

La solución está compuesta por 4 servicios principales que se comunican a través de una red personalizada:

```
┌─────────────────────────────────────────────────────────────┐
│                    Red DAW (172.20.0.0/16)                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   DNS/BIND9  │  │   Apache     │  │   Tomcat     │       │
│  │ 172.20.0.13  │  │ 172.20.0.15  │  │ 172.20.0.14  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                           │                                 │
│                    ┌──────────────┐                         │
│                    │  OpenLDAP    │                         │
│                    │ 172.20.0.16  │                         │
│                    └──────────────┘                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Servicios Implementados

#### 1. **DNS/BIND9** (172.20.0.13)
- **Imagen:** `ubuntu/bind9`
- **Contenedor:** `dns_javier`
- **Puertos:** 
  - 53/TCP (DNS)
  - 53/UDP (DNS)
- **Función:** Servidor de nombres autoritario para la zona `javier.local`
- **Características:**
  - Gestión de registros A, CNAME y PTR
  - Resolución inversa (reverse lookup) para la red 172.20.0.0/24
  - Forwarders configurados hacia Google DNS (8.8.8.8 y 8.8.4.4)
  - Permite consultas recursivas desde cualquier cliente

#### 2. **Apache HTTP Server** (172.20.0.15)
- **Imagen:** Custom (construida desde `httpd:2.4`)
- **Contenedor:** `apache_javier`
- **Puertos:**
  - 80/TCP (HTTP - redirige a HTTPS)
  - 443/TCP (HTTPS)
- **Función:** Servidor web principal con soporte SSL/TLS
- **Características:**
  - Certificados SSL autofirmados
  - Configuración de múltiples virtual hosts
  - Proxy inverso hacia Tomcat

#### 3. **Apache Tomcat** (172.20.0.14)
- **Imagen:** `tomcat:9.0`
- **Contenedor:** `tomcat_javier`
- **Puertos:** 8080 (interno, accesible a través de Apache)
- **Función:** Servidor de aplicaciones Java
- **Características:**
  - Soporte para JSP y aplicaciones Java
  - Página de bienvenida personalizada con información del servidor

#### 4. **OpenLDAP** (172.20.0.16)
- **Imagen:** `osixia/openldap:latest`
- **Contenedor:** `ldap_javier`
- **Puertos:**
  - 389/TCP (LDAP sin encriptación)
  - 636/TCP (LDAPS - LDAP seguro)
- **Función:** Servicio de directorio LDAP para autenticación centralizada
- **Configuración:**
  - Organización: "EduTech Solutions"
  - Dominio: "javier.local"
  - Contraseña admin: "admin"

---

## Estructura de Directorios

```
DAW-Proyecto/
├── docker-compose.yml          # Configuración de servicios Docker
├── README.md                   # Este archivo
│
├── apache/                     # Servidor web Apache
│   ├── Dockerfile              # Construcción de imagen personalizada
│   ├── conf/                   # Configuraciones de Apache
│   │   ├── httpd.conf          # Configuración principal
│   │   ├── server.crt          # Certificado SSL (autofirmado)
│   │   ├── server.key          # Clave privada SSL
│   │   └── extra/
│   │       ├── edutech.conf    # Incluye los virtual hosts
│   │       └── vhosts/         # Un virtual host por archivo
│   │           ├── 00-redirect.conf
│   │           ├── 10-produccion.conf
│   │           ├── 20-pruebas.conf
│   │           └── 30-tomcat.conf
│   ├── logs/                   # Registros de acceso y errores
│   └── www/                    # Contenido web
│       ├── produccion/         # Sitio de producción
│       │   └── index.html
│       └── pruebas/            # Sitio de pruebas
│           └── index.html
│
├── bind9/                      # Servidor DNS
│   ├── conf/
│   │   └── named.conf          # Configuración de BIND9
│   └── zones/                  # Archivos de zona DNS
│       ├── db.javier.local     # Zona forward
│       └── db.172.20.0         # Zona reverse
│
└── tomcat/                     # Servidor de aplicaciones
    └── webapps/
        └── ROOT/
            └── index.jsp       # Página de inicio (JSP)
```

---

## Configuraciones Detalladas

### DNS (BIND9)

#### Archivo de zona forward: `bind9/zones/db.javier.local`

Define los registros A y CNAME para la zona:
- **ns1.javier.local** → 172.20.0.13 (DNS server)
- **tomcat.javier.local** → 172.20.0.14 (Tomcat)
- **www.javier.local** → 172.20.0.15 (Apache)
- **produccion.javier.local** → CNAME a www.javier.local
- **pruebas.javier.local** → CNAME a www.javier.local
- **ldap.javier.local** → 172.20.0.16 (LDAP server)

#### Archivo de zona reverse: `bind9/zones/db.172.20.0`

Configuración de resolución inversa (PTR records) para la red 172.20.0.0/24.

### Apache HTTP Server

#### Configuración principal: `apache/conf/httpd.conf`

Incluye módulos clave:
- MPM Event (multi-procesamiento)
- Autenticación y autorización
- SSL/TLS
- Módulos de proxy

#### Virtual Hosts: `apache/conf/extra/vhosts/*.conf` (incluidos desde `apache/conf/extra/edutech.conf`)

Cada archivo contiene un único VirtualHost:

- `00-redirect.conf` → Redirección HTTP a `https://pruebas.javier.local/`
- `10-produccion.conf` → `produccion.javier.local`, SSL, AllowOverride All, logs dedicados
- `20-pruebas.conf` → `pruebas.javier.local`, SSL, AllowOverride None, logs dedicados
- `30-tomcat.conf` → Proxy inverso hacia Tomcat en `http://tomcat:8080/`
- Logs: `tomcat_error.log` y `tomcat_access.log`

### Tomcat

El servidor Tomcat aloja una página JSP personalizada en `tomcat/webapps/ROOT/index.jsp` que muestra:
- Nombre del servidor
- Puerto de conexión
- Versión de Tomcat
- Información del servidor

### OpenLDAP

Configurado con:
- Organización: EduTech Solutions
- Dominio LDAP: javier.local
- Puertos estándar LDAP (389) y LDAPS (636)

---

## Cómo Ejecutar el Proyecto

### Requisitos Previos

- **Docker** instalado y funcionando
- **Docker Compose** instalado
- Al menos 2GB de RAM disponible
- Puertos 53, 80, 389, 443, 636 y 53/UDP disponibles

### Pasos para Iniciar

1. **Clonar o descargar el repositorio:**
   ```bash
   cd DAW-Proyecto
   ```

2. **Iniciar los servicios:**
   ```bash
   docker-compose up -d
   ```
   
   El parámetro `-d` ejecuta los contenedores en segundo plano.

3. **Verificar que todos los servicios estén corriendo:**
   ```bash
   docker-compose ps
   ```

### Comandos Útiles

**Ver logs de un servicio específico:**
```bash
docker-compose logs -f [dns|apache|tomcat|ldap]
```

**Acceder a una terminal dentro de un contenedor:**
```bash
docker-compose exec [servicio] /bin/bash
```

**Detener todos los servicios:**
```bash
docker-compose down
```

**Detener y eliminar volúmenes (¡cuidado, elimina datos!):**
```bash
docker-compose down -v
```

**Reconstruir la imagen de Apache:**
```bash
docker-compose build apache
```

---

## Acceso a Servicios

### Desde el Equipo Host

Asume que has configurado las entradas DNS locales o usas las direcciones IP directamente.

**Configuración de hosts recomendada** (archivo `C:\Windows\System32\drivers\etc\hosts` en Windows o `/etc/hosts` en Linux/Mac):
```
127.0.0.1       localhost
172.20.0.13     ns1.javier.local
172.20.0.14     tomcat.javier.local
172.20.0.15     www.javier.local produccion.javier.local pruebas.javier.local
172.20.0.16     ldap.javier.local
```

### Servicios Disponibles

| Servicio        | URL                             | Descripción                              |
| --------------- | ------------------------------- | ---------------------------------------- |
| Producción      | https://produccion.javier.local | Sitio en producción (AllowOverride: All) |
| Pruebas         | https://pruebas.javier.local    | Sitio de pruebas (AllowOverride: None)   |
| Tomcat          | https://tomcat.javier.local     | Aplicación Tomcat via proxy              |
| HTTP (redirige) | http://javier.local             | Se redirige a pruebas.javier.local       |
| LDAP            | ldap://ldap.javier.local:389    | Servidor de directorio                   |
| DNS             | 172.20.0.13:53                  | Servidor de nombres                      |

**Nota:** Los certificados SSL son autofirmados, por lo que el navegador mostrará advertencias de seguridad.

---

## Flujo de Comunicación

1. **Resolución DNS:**
   - Las consultas a `*.javier.local` se resuelven mediante el servidor BIND9
   - El servidor DNS retorna las IPs correspondientes

2. **Acceso a sitios web:**
   - Las solicitudes HTTP (puerto 80) se redirigen a HTTPS
   - Apache escucha en HTTPS (puerto 443)
   - Según el host solicitado:
     - **produccion.javier.local** → Sirve contenido de `www/produccion/`
     - **pruebas.javier.local** → Sirve contenido de `www/pruebas/`
     - **tomcat.javier.local** → Proxea a Tomcat en `http://tomcat:8080/`

3. **Autenticación LDAP:**
   - OpenLDAP proporciona servicios de directorio
   - Puede ser integrado con Apache para autenticación de usuarios

---

## Certificados SSL

Los certificados SSL incluidos son **autofirmados** y generados para propósitos educativos/de desarrollo.

**Ubicación:**
- Certificado: `apache/conf/server.crt`
- Clave privada: `apache/conf/server.key`

Para generar nuevos certificados (si es necesario):
```bash
openssl req -x509 -newkey rsa:4096 -keyout server.key -out server.crt -days 365 -nodes
```

---

## Troubleshooting

### Los servicios no inician
- Verifica que los puertos no estén en uso: `netstat -an`
- Revisa los logs: `docker-compose logs`

### No puedo resolver `javier.local`
- Asegúrate de que el DNS está usando 172.20.0.13
- Verifica la configuración en tu archivo `hosts`
- Desde dentro de la red Docker, los contenedores pueden usar directamente el nombre del servicio

### El certificado SSL muestra error
- Es normal con certificados autofirmados
- Acepta la excepción en el navegador o usa `curl -k`

### Tomcat no es accesible vía proxy
- Verifica que Apache está corriendo: `docker-compose ps`
- Comprueba que Tomcat está escuchando: `docker-compose exec tomcat curl http://localhost:8080/`
- Revisa los logs de Apache: `docker-compose logs apache`

---

## Notas de Desarrollo

### Añadir nuevos contenidos web
- Coloca archivos HTML en `apache/www/produccion/` o `apache/www/pruebas/`
- Los cambios son inmediatos (el volumen está montado)

### Modificar configuraciones de Apache
- Edita `apache/conf/httpd.conf` o los ficheros en `apache/conf/extra/vhosts/` (se cargan desde `apache/conf/extra/edutech.conf`)
- Recarga Apache sin reiniciar: `docker-compose exec apache apachectl graceful`

### Agregar nuevos usuarios LDAP
- Accede al contenedor LDAP: `docker-compose exec ldap /bin/bash`
- Usa herramientas LDAP como `ldapadd` para agregar entradas

### Cambiar registros DNS
- Edita los archivos en `bind9/zones/`
- Incrementa el número de serie en el registro SOA
- Recarga BIND: `docker-compose exec dns rndc reload`

---

## Información Técnica

### Versiones de Servicios
- **Apache HTTP Server:** 2.4
- **Apache Tomcat:** 9.0
- **BIND9:** Última versión (ubuntu/bind9)
- **OpenLDAP:** Última versión disponible

### Recursos de Red
- **Subred:** 172.20.0.0/16
- **Driver de red:** bridge
- **DNS interno:** 172.20.0.13 (automático para todos los contenedores)

### Montajes de Volúmenes
Todos los archivos de configuración están montados como volúmenes, permitiendo:
- Edición directa en el host
- Cambios inmediatos sin reconstruir imágenes
- Persistencia de datos de configuración

---

## Licencia y Créditos

Este proyecto fue desarrollado como parte del módulo **DAW (Desarrollo de Aplicaciones Web)**.

Está diseñado con fines educativos para enseñar conceptos de:
- Infraestructura de servicios
- Configuración de DNS
- Servidores web y de aplicaciones
- Directorios LDAP
- Docker y containerización
- Redes y comunicación entre contenedores

---

## Soporte y Contacto

Para reportar problemas o sugerencias, consulta la documentación oficial de:
- [Apache HTTP Server](https://httpd.apache.org/)
- [BIND9 DNS](https://www.isc.org/bind/)
- [Apache Tomcat](https://tomcat.apache.org/)
- [OpenLDAP](https://www.openldap.org/)
- [Docker Documentation](https://docs.docker.com/)

---

**Última actualización:** 13 de enero de 2026
