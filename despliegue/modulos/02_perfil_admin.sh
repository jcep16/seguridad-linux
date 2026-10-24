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
    echo "[ERROR] No existe el script de gestión de paquetes."
    exit 1
fi

if ! bash -n "$ORIGEN"; then
    echo "[ERROR] Sintaxis inválida en el script de paquetes."
    exit 1
fi

if ! id admin_lab >/dev/null 2>&1; then
    echo "[ERROR] Debes crear el usuario admin_lab antes."
    exit 1
fi

case "$MODO" in
    --check)
        echo "[OK] Script válido y usuario admin_lab existente."
        if [[ -f "$DESTINO" && -f "$REGLA" ]]; then
            echo "[INFO] Ya hay una instalación previa."
        else
            echo "[INFO] Falta instalar el perfil."
        fi
        ;;

    --dry-run)
        echo "[SIMULACIÓN] Se instalaría el script en $DESTINO"
        echo "[SIMULACIÓN] Se configuraría $REGLA"
        echo "No se modificó el sistema."
        ;;

    --apply)
        if [[ "$EUID" -ne 0 ]]; then
            echo "[ERROR] Ejecuta el despliegue con sudo."
            exit 1
        fi

        TEMP="$(mktemp)"
        trap 'rm -f "$TEMP"' EXIT

        printf '%s\n' \
            'admin_lab ALL=(root) /usr/local/sbin/gestionar_paquetes_lab' \
            > "$TEMP"

        chown root:root "$TEMP"
        chmod 0440 "$TEMP"

        if ! visudo -c -f "$TEMP"; then
            echo "[ERROR] La regla candidata no es válida."
            exit 1
        fi

        install -o root -g root -m 0755 "$ORIGEN" "$DESTINO"
        install -o root -g root -m 0440 "$TEMP" "$REGLA"

        if ! visudo -c; then
            echo "[ERROR] La configuración global de sudoers no es válida."
            exit 1
        fi

        echo "[OK] Perfil admin_lab instalado."
        ;;
esac
