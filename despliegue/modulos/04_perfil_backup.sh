#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
USUARIO="backup_lab"
REGLA="/etc/sudoers.d/backup_lab"
SCRIPT="/usr/local/sbin/backup_web_lab"
TEMP="$(mktemp)"
trap 'rm -f "$TEMP"' EXIT

crear_regla() {
    printf '%s\n' \
        'backup_lab ALL=(root) NOPASSWD: /usr/local/sbin/backup_web_lab' \
        > "$TEMP"

    chown root:root "$TEMP"
    chmod 0440 "$TEMP"
    visudo -c -f "$TEMP"
}

case "${1:-}" in
    --check)
        command -v visudo >/dev/null
        command -v tar >/dev/null
        test -f "$ROOT/usuarios-sudo/backup_web_lab.sh"
        bash -n "$ROOT/usuarios-sudo/backup_web_lab.sh"
        echo "[OK] Herramientas y script disponibles."

        if id "$USUARIO" >/dev/null 2>&1; then
            echo "[OK] El usuario $USUARIO ya existe."
        else
            echo "[INFO] Se crearía el usuario $USUARIO al aplicar."
        fi
        ;;

    --dry-run)
        echo "[SIMULACIÓN] Se crearía $USUARIO si no existe."
        echo "[SIMULACIÓN] Se prepararían /var/www y /var/backups/web_lab."
        echo "[SIMULACIÓN] Se instalaría $SCRIPT."
        echo "[SIMULACIÓN] Se configuraría $REGLA."
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

        install -d -o root -g root -m 0755 /var/www
        install -d -o root -g root -m 0755 /var/backups/web_lab
        install -o root -g root -m 0755 \
            "$ROOT/usuarios-sudo/backup_web_lab.sh" "$SCRIPT"

        crear_regla
        install -o root -g root -m 0440 "$TEMP" "$REGLA"

        visudo -c
        echo "[OK] Perfil de copias de seguridad instalado."
        echo "[INFO] El usuario solo puede ejecutar el script autorizado mediante sudo."
        ;;

    *)
        echo "Uso: $0 {--check|--dry-run|--apply}" >&2
        exit 2
        ;;
esac
