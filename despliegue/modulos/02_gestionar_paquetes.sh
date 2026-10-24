#!/usr/bin/env bash
set -Eeuo pipefail

MODO="${1:-}"

case "$MODO" in
    --check)
        echo "[OK] Se encontró el módulo de gestión de paquetes."
        bash -n "$(dirname "$0")/../../usuarios-sudo/gestionar_paquetes_lab.sh"
        echo "[OK] Sintaxis del gestor válida."
        ;;

    --dry-run)
        echo "[SIMULACIÓN] Se podrían ejecutar las operaciones:"
        echo "  /usr/local/sbin/gestionar_paquetes_lab update"
        echo "  /usr/local/sbin/gestionar_paquetes_lab upgrade"
        echo "No se modificará el sistema."
        ;;

    --apply)
        echo "[INFO] El perfil de paquetes se instala mediante 02_perfil_admin.sh."
        echo "[INFO] Este módulo no ejecuta actualizaciones automáticamente."
        ;;

    *)
        echo "Uso: $0 {--check|--dry-run|--apply}" >&2
        exit 2
        ;;
esac
