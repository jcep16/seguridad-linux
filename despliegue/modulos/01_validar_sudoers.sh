#!/usr/bin/env bash

set -Eeuo pipefail

MODO="${1:-}"

case "$MODO" in
    --check|--dry-run|--apply)
        ;;
    *)
        echo "Uso: $0 [--check|--dry-run|--apply]"
        exit 2
        ;;
esac

if ! command -v visudo >/dev/null 2>&1; then
    echo "[ERROR] No se encuentra visudo."
    exit 1
fi

case "$MODO" in
    --check)
        echo "=== Validación de sudoers ==="
        if visudo -c; then
            echo "[OK] La sintaxis de sudoers es válida."
        else
            echo "[ERROR] Se detectaron errores en sudoers."
            exit 1
        fi
        ;;

    --dry-run)
        echo "[SIMULACIÓN] Se ejecutaría visudo -c."
        echo "No se modificará la configuración."
        ;;

    --apply)
        echo "=== Validación final de sudoers ==="
        if visudo -c; then
            echo "[OK] La configuración es válida."
            echo "Este ejercicio no modifica archivos de sudoers."
        else
            echo "[ERROR] Se detectaron errores en sudoers."
            exit 1
        fi
        ;;
esac
