# Guía de colaboración y despliegue

## 1. Obtener el repositorio

Clonar por primera vez:

    git clone https://github.com/jcep16/seguridad-linux.git
    cd seguridad-linux

Actualizar una copia existente:

    git switch main
    git pull origin main

## 2. Empezar una tarea

Actualizar main antes de crear una rama:

    git switch main
    git pull origin main
    git switch -c feature/nombre-de-la-tarea

Cada integrante trabaja en su propia copia del repositorio.
No se deben compartir carpetas .git ni sobrescribir el directorio de
trabajo de otra persona.

## 3. Validar los cambios

Desde la raíz del repositorio:

    bash -n scripts/aplicar_configuracion.sh
    bash pruebas/comprobar_estructura.sh
    bash pruebas/comprobar_preparacion.sh
    bash pruebas/comprobar_despliegue.sh
    git diff --check

Los scripts nuevos también deben pasar las comprobaciones de
GitHub Actions y ShellCheck.

## 4. Publicar una tarea

Revisar los archivos modificados:

    git status --short
    git diff

Añadir los archivos de la tarea, crear el commit y publicar la rama:

    git add <archivos>
    git diff --cached --check
    git commit -m "tipo: descripción del cambio"
    git push -u origin feature/nombre-de-la-tarea

Después, abrir un pull request desde la rama de trabajo hacia main.
No integrar cambios con comprobaciones fallidas.

## 5. Recuperar trabajo de otra persona

Una vez que el pull request se integre en main:

    git switch main
    git pull origin main

Esto descarga los archivos; por sí solo no modifica la configuración
del sistema operativo.

## 6. Mecanismo de despliegue

El instalador está en:

    scripts/aplicar_configuracion.sh

Los módulos futuros se guardarán en:

    despliegue/modulos/

Cada módulo deberá admitir:

    --check
    --dry-run
    --apply

Contrato de los módulos:
- --check comprueba requisitos sin cambiar el sistema.
- --dry-run muestra las acciones previstas sin cambiar el sistema.
- --apply aplica los cambios.
- Los módulos deben ser idempotentes siempre que sea posible.
- Las reglas de sudoers deben validarse con visudo antes de instalarlas.
- Los errores deben detener el despliegue y documentar posibles cambios
  parciales y cómo recuperarse.

Cuando existan módulos revisados y aprobados:

    bash scripts/aplicar_configuracion.sh --check
    bash scripts/aplicar_configuracion.sh --dry-run
    sudo ./scripts/aplicar_configuracion.sh --apply

No ejecutar --apply mientras no existan módulos revisados y probados.

## 7. Seguridad

- No subir contraseñas, tokens, claves privadas ni otros secretos.
- No guardar copias de archivos sensibles del sistema en el repositorio.
- Los cambios se revisan mediante pull request.
- No asumir que una prueba de sintaxis demuestra que una configuración
  funciona en Ubuntu; hay que probarla en una VM.
