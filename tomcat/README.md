# Apache Tomcat 9

Servidor de aplicaciones Java utilizado en el proyecto para servir contenido dinámico (JSP/Servlets).

## Despliegue

- **Webapps**: El directorio `./webapps` local se monta en `/usr/local/tomcat/webapps` dentro del contenedor.
- **ROOT App**: Contiene una aplicación JSP simple (`index.jsp`) que muestra información del servidor (IP, versión).

## Acceso

Aunque Tomcat escucha en el puerto 8080, en este entorno de producción simulado no se expone directamente al host ni a usuarios finales.
**El acceso debe realizarse a través del Proxy Inverso Apache** (`https://tomcat.javier.local`), lo que añade una capa de seguridad SSL y gestión centralizada de logs.
