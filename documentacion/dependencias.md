# Inventario de dependencias

## 1. Objetivo

Registrar los paquetes necesarios para el proyecto Seguridad 1, su finalidad y su estado inicial. Este inventario no implica que deban instalarse durante la fase de preparación.

## 2. Estado inicial

| Componente | Paquete previsto | Estado inicial | Finalidad |
|---|---|---|---|
| Administración | `sudo` | Instalado | Delegación de privilegios |
| Acceso remoto | `openssh-server` | Instalado | Conexiones SSH y SFTP |
| Control de aplicaciones | `apparmor` | Instalado | Aplicación de perfiles de seguridad |
| Auditoría de credenciales | `hydra` | No instalado | Simulaciones controladas y autorizadas |
| Protección de accesos | `fail2ban` | No instalado | Detección y bloqueo de intentos fallidos |
| Antivirus | `clamav` | No instalado | Detección de archivos maliciosos |
| Reportes | `logwatch` | No instalado | Análisis de registros |

Los estados corresponden al inventario inicial realizado en la máquina de desarrollo. Deben actualizarse si se instalan o eliminan paquetes.

## 3. Herramientas de desarrollo

| Herramienta | Versión observada | Finalidad |
|---|---|---|
| Git | 2.53.0 | Control de versiones |
| Bash | 5.3.9 | Ejecución de scripts |
| Python | 3.14.4 | Herramienta auxiliar disponible |

## 4. Procedimiento para futuras instalaciones

Antes de instalar un componente:

1. Consultar la versión del sistema operativo.
2. Comprobar la disponibilidad del paquete en los repositorios.
3. Revisar las dependencias y los requisitos.
4. Registrar la versión instalada.
5. Comprobar el estado del servicio, cuando corresponda.
6. Documentar los comandos utilizados y los resultados.
7. Probar la configuración en un entorno de pruebas antes de aplicarla al entorno principal.

## 5. Criterios de seguridad

- No almacenar credenciales, tokens ni claves privadas en el repositorio.
- No instalar componentes hasta que se haya planificado su actividad práctica.
- No considerar un paquete instalado como prueba de una configuración segura.
- Realizar las simulaciones de ataque únicamente en sistemas propios o con autorización explícita.

## 6. Estado de preparación

El inventario inicial está documentado. Las versiones y configuraciones definitivas de los componentes pendientes se determinarán al preparar el entorno de pruebas.
