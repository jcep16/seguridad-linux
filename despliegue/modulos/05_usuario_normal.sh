#!/usr/bin/env bash
set -Eeuo pipefail

USUARIO="usuario_normal_lab"

case "${1:-}" in
    --check|--dry-run|--apply) ;;
    *)
        echo "Uso: $0 {--check|--dry-run|--apply}" >&2
        exit 2
        ;;
esac

case "$1" in
    --check)
        command -v useradd >/dev/null
        command -v gpasswd >/dev/null
        command -v getent >/dev/null
        command -v visudo >/dev/null
        echo "[OK] Herramientas disponibles."

        if id "$USUARIO" >/dev/null 2>&1; then
            echo "[OK] El usuario $USUARIO ya existe."
        else
            echo "[INFO] Se crearía $USUARIO al aplicar."
        fi
        ;;

    --dry-run)
        echo "[SIMULACIÓN] Se crearía $USUARIO si no existe."
        echo "[SIMULACIÓN] Se comprobaría su pertenencia al grupo sudo."
        echo "[SIMULACIÓN] No se modificarán los permisos de /etc/shadow."
        echo "No se modificará el sistema."
        ;;

    --apply)
        if [[ $EUID -ne 0 ]]; then
            echo "[ERROR] Ejecuta el despliegue con sudo." >&2
            exit 1
        fi

        if ! id "$USUARIO" >/dev/null 2>&1; then
            useradd --create-home --shell /bin/bash "$USUARIO"
            passwd --lock "$USUARIO"
            echo "[OK] Usuario $USUARIO creado y contraseña bloqueada."
        fi

        if getent group sudo | grep -qw "$USUARIO"; then
            gpasswd -d "$USUARIO" sudo
        fi

        if getent group sudo | grep -qw "$USUARIO"; then
            echo "[ERROR] El usuario sigue perteneciendo al grupo sudo." >&2
            exit 1
        fi

        visudo -c

        echo "[OK] $USUARIO no pertenece al grupo sudo."
        echo "[INFO] Esta comprobación no descarta reglas sudoers adicionales asignadas directamente al usuario."
        echo "[OK] Perfil de usuario normal aplicado."
        ;;
esac
