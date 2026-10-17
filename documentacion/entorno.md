# Entorno de trabajo

## Sistema de referencia

- Sistema operativo: Ubuntu 26.04 LTS
- Kernel: 7.0.0-38-generic
- Arquitectura: amd64
- Git: 2.53.0
- Conectividad con GitHub: verificada

## Componentes previstos

- Usuarios y sudo
- OpenSSH y usuario restringido (jail)
- AppArmor
- Hydra
- Fail2ban
- ClamAV
- Logwatch

## Criterios de trabajo

- Verificar las versiones antes de instalar dependencias.
- Documentar los requisitos de cada componente.
- Probar las configuraciones en un entorno de pruebas.
- Revisar los cambios antes de aplicarlos.
- No almacenar contraseñas, tokens ni claves privadas en GitHub.

## Estado actual

Preparación inicial del entorno completada.
Las herramientas de seguridad todavía no se han configurado.
