# Guía de colaboración — Seguridad Linux

## 1. Repositorio

Repositorio oficial: https://github.com/jcep16/seguridad-linux

La rama `main` contiene la versión estable e integrada del proyecto.

## 2. Requisitos

- Git instalado.
- Acceso autorizado al repositorio.
- Conexión a Internet.
- Ubuntu Server como entorno de referencia para las actividades prácticas.

## 3. Clonar el repositorio

Cada integrante debe clonar el proyecto una sola vez:

```bash
git clone https://github.com/jcep16/seguridad-linux.git
cd seguridad-linux
```

## 4. Actualizar la copia local

Antes de comenzar a trabajar:

```bash
git switch main
git pull origin main
```

## 5. Crear una rama de trabajo

Cada tarea debe desarrollarse en una rama independiente. Ejemplo:

```bash
git switch -c feature/nombre-tarea
```

Se debe utilizar un nombre descriptivo para identificar el trabajo.

## 6. Guardar y subir cambios

Después de modificar o crear archivos:

```bash
git status
git add ruta/del/archivo
git commit -m "Descripción del cambio"
git push -u origin feature/nombre-tarea
```

Se deben agregar únicamente los archivos relacionados con la tarea.

## 7. Crear un Pull Request

1. Abrir el repositorio en GitHub.
2. Seleccionar la opción para crear un Pull Request.
3. Elegir la rama de trabajo como origen y `main` como destino.
4. Describir los cambios realizados.
5. Verificar que las validaciones automáticas finalicen correctamente.
6. Revisar e integrar los cambios cuando estén aprobados.

No se deben incorporar directamente cambios experimentales a `main`.

## 8. Mantener el trabajo actualizado

Antes de iniciar otra tarea, actualizar `main`:

```bash
git switch main
git pull origin main
```

Después, crear una nueva rama para el siguiente cambio.

## 9. Organización de archivos

- `usuarios-sudo/`: actividades relacionadas con usuarios y permisos sudo.
- `jail/`: documentación y archivos relacionados con el entorno restringido.
- `apparmor/`: documentación y perfiles de AppArmor.
- `ataques/`: documentación de las pruebas de ataque autorizadas.
- `fail2ban/`: configuración y documentación de Fail2ban.
- `clamav/`: documentación y pruebas de ClamAV.
- `logwatch/`: documentación y configuración de Logwatch.
- `pruebas/`: comprobaciones auxiliares.
- `scripts/`: scripts generales del proyecto.
- `configuracion/`: configuración general del proyecto.
- `documentacion/`: manuales y documentación técnica.

## 10. Seguridad y buenas prácticas

- No subir contraseñas, tokens, claves privadas ni credenciales.
- No subir máquinas virtuales completas ni archivos `.qcow2`.
- No subir registros que contengan información sensible.
- Revisar los cambios antes de confirmarlos.
- Utilizar Pull Requests para integrar el trabajo.
- Ejecutar las validaciones automáticas antes de integrar cambios.

## 11. Validación automática

GitHub Actions ejecuta las siguientes comprobaciones en los cambios
dirigidos a la rama `main` mediante los eventos configurados:

- Comprueba la sintaxis de los scripts Bash.
- Valida la sintaxis de `configuracion/proyecto.conf`.
- Comprueba que existan los directorios esenciales del proyecto.
- Analiza los scripts Bash con ShellCheck.

La rama `main` está protegida: los cambios deben integrarse mediante
Pull Requests y la comprobación obligatoria `validar-bash` debe pasar.

Una validación correcta no sustituye las pruebas prácticas de seguridad
ni demuestra por sí sola que una configuración sea segura.
