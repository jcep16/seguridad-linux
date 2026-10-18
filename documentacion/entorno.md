# Entorno de trabajo

## 1. Sistema de referencia

- Sistema operativo: Ubuntu Server 26.04 LTS
- Nombre en clave: Resolute Raccoon
- Kernel: 7.0.0-38-generic
- Arquitectura: amd64
- Git: 2.53.0
- Bash: 5.3.9
- Python: 3.14.4
- Conectividad con GitHub: verificada

## 2. Recursos disponibles

- Espacio total en la partición raíz: aproximadamente 9,8 GB
- Espacio libre observado: aproximadamente 6,5 GB
- Memoria RAM: aproximadamente 3,3 GiB
- Memoria swap: no configurada

Estos valores corresponden al momento del inventario y pueden cambiar.

## 3. Estado inicial de las dependencias

### Instaladas

- sudo: 1.9.17p2-1ubuntu3.2
- openssh-server: 1:10.2p1-2ubuntu3.8
- apparmor: 5.0.0~beta1-0ubuntu7

### No instaladas en el momento del inventario

- Hydra
- Fail2ban
- ClamAV
- Logwatch

La presencia de un paquete no garantiza que el servicio esté activo ni que su configuración sea correcta.

## 4. Componentes previstos

- Administración de usuarios y privilegios sudo
- OpenSSH y usuario restringido
- AppArmor
- Hydra para simulaciones controladas
- Fail2ban
- ClamAV
- Logwatch

## 5. Criterios de trabajo

- Verificar las versiones antes de instalar dependencias.
- Documentar los requisitos de cada componente.
- Probar las configuraciones en un entorno de pruebas.
- Revisar los cambios antes de aplicarlos.
- No almacenar contraseñas, tokens ni claves privadas en GitHub.
- Mantener los cambios del proyecto bajo control de versiones.
- Usar ramas y Pull Requests para integrar modificaciones.

## 6. Estado de preparación

- Repositorio GitHub: preparado.
- Flujo de ramas y Pull Requests: probado.
- GitHub Actions: validación automática de scripts Bash y análisis con ShellCheck.
- Inventario inicial del sistema: realizado.
- Configuraciones prácticas de seguridad: pendientes.
- Preparación de la segunda máquina virtual: pendiente.

La preparación inicial no implica que los controles de seguridad del proyecto ya estén implementados o verificados.

