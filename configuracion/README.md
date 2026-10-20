# Configuración general

Esta carpeta contiene los archivos de configuración de referencia del proyecto Seguridad 1.

## Archivos

- `proyecto.conf`: identifica el proyecto, sus componentes y los directorios generales.
- `dependencias.conf`: define el sistema operativo de referencia, la arquitectura, las herramientas base y los paquetes previstos para las prácticas.

## Criterios de uso

- Los archivos de configuración deben mantenerse sincronizados con la documentación.
- Los scripts deben consultar estos archivos cuando necesiten los parámetros definidos en ellos.
- Los paquetes previstos para las prácticas no se instalarán automáticamente durante la comprobación inicial del entorno.
- No almacenar contraseñas, tokens, claves privadas ni otras credenciales en esta carpeta.

La configuración describe el entorno esperado; no demuestra por sí sola que las prácticas de seguridad estén implementadas o correctamente configuradas.
