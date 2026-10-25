#!/usr/bin/env bash
set -Eeuo pipefail

USUARIO="usuario_normal_lab"

case "${1:-}" in
    --check)
        command -v useradd >/dev/null
        command -v usermod >/dev/null
        command -v id >/dev/null
        echo "[OK] Herramientas disponibles."

        if id "$USUARIO" >/dev/null 2>&1; then
            echo "[OK] El usuario $USUARIO ya existe."
        else
            echo "[INFO] Se crearía el usuario $USUARIO al aplicar."
        fi
        ;;

    --dry-run)
        echo "[SIMULACIÓN] Se crearía $USUARIO si no existe."
        echo "[SIMULACIÓN] Se comprobaría que no pertenezca al grupo sudo."
        echo "[SIMULACIÓN] No se modificarán los permisos de /etc/shadow."
        echo "No se modificará el sistema."
        ;;

    --apply)
        if [[ $EUID -ne 0 ]]; then
            echo "[ERROR] Ejecuta el despliegue con sudo."
            exit 1
        fi

        if ! id "$USUARIO" >/dev/null 2>&1; then
            useradd --create-home --shell /bin/bash "$USUARIO"
            passwd --lock "$USUARIO"
            echo "[OK] Usuario $USUARIO creado y contraseña bloqueada."
        fi

        if getent group sudo | grep -qw "$USUARIO"; then
            gpasswd -d "$USUARIO" sudo
            echo "[OK] Usuario eliminado del grupo sudo."
        else
            echo "[OK] El usuario no pertenece al grupo sudo."
        fi

        if sudo -l -U "$USUARIO" >/dev/null 2>&1; then
            echo "[ERROR] El usuario todavía tiene permisos sudo."
            exit 1
        fi

        echo "[OK] El usuario no está autorizado para utilizar sudo."
        echo "[OK] Perfil de usuario normal aplicado."
        ;;

    *)
        echo "Uso: $0 {--check|--dry-run|--apply}" >&2
        exit 2
        ;;
esac
