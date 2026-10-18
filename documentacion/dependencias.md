# Inventario de dependencias

Este documento registra las herramientas previstas para el proyecto.
No implica que deban instalarse en esta fase.

| Componente | Paquete previsto | Finalidad |
|---|---|---|
| Administración | sudo | Delegación de privilegios |
| Acceso remoto | openssh-server | Conexiones SSH y SFTP |
| Control de aplicaciones | apparmor | Aplicación de perfiles de seguridad |
| Auditoría de credenciales | hydra | Simulaciones controladas |
| Protección de accesos | fail2ban | Detección y bloqueo de intentos fallidos |
| Antivirus | clamav | Detección de archivos maliciosos |
| Reportes | logwatch | Análisis de registros |

## Procedimiento futuro

Antes de instalar cada componente:
1. Consultar la versión de Ubuntu.
2. Comprobar si el paquete está disponible.
3. Revisar sus dependencias.
4. Registrar la versión instalada.
5. Documentar los comandos utilizados.

Las versiones concretas se determinarán al preparar
el entorno de pruebas.
