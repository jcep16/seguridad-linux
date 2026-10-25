#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
ORIGEN="$ROOT/usuarios-sudo/gestionar_paquetes_lab.sh"
DESTINO="/usr/local/sbin/gestionar_paquetes_lab"
REGLA="/etc/sudoers.d/admin_lab"
MODO="${1:-}"

case "$MODO" in
    --check|--dry-run|--apply) ;;
    *)
        echo "Uso: $0 {--check|--dry-run|--apply}" >&2
        exit 2
        ;;
esac

if [[ ! -f "$ORIGEN" ]]; then
    echo "[ERROR] No existe el script de gestión de paquetes: $ORIGEN"
    exit 1
fi

bash -n "$ORIGEN"

case "$MODO" in
    --check)
        command -v visudo >/dev/null
        command -v useradd >/dev/null
        command -v passwd >/dev/null
        echo "[OK] Script y herramientas disponibles."

        if id admin_lab >/dev/null 2>&1; then
            echo "[OK] El usuario admin_lab ya existe."
        else
            echo "[INFO] Se crearía admin_lab al aplicar."
        fi

        if [[ -f "$DESTINO" && -f "$REGLA" ]]; then
            echo "[INFO] Ya hay una instalación previa del perfil."
        else
            echo "[INFO] Falta instalar parte o todo el perfil."
        fi
        ;;

    --dry-run)
        echo "[SIMULACIÓN] Se crearía admin_lab si no existe."
        echo "[SIMULACIÓN] Se solicitaría definir una contraseña para la cuenta nueva."
        echo "[SIMULACIÓN] Se instalaría $DESTINO."
        echo "[SIMULACIÓN] Se configuraría $REGLA."
        echo "[SIMULACIÓN] No se modificará el sistema."
        ;;

    --apply)
        if [[ $EUID -ne 0 ]]; then
            echo "[ERROR] Ejecuta el despliegue con sudo." >&2
            exit 1
        fi

        if ! id admin_lab >/dev/null 2>&1; then
            useradd --create-home --shell /bin/bash admin_lab
            echo "[INFO] Define la contraseña de admin_lab."
            passwd admin_lab
        fi

        TEMP="$(mktemp)"
        trap 'rm -f "$TEMP"' EXIT

        printf '%s\n' \
            'admin_lab ALL=(root) /usr/local/sbin/gestionar_paquetes_lab' \
            > "$TEMP"

        chown root:root "$TEMP"
        chmod 0440 "$TEMP"

        visudo -c -f "$TEMP"

        install -o root -g root -m 0755 "$ORIGEN" "$DESTINO"
        install -o root -g root -m 0440 "$TEMP" "$REGLA"

        visudo -c
        echo "[OK] Perfil admin_lab instalado."
        ;;
esac
