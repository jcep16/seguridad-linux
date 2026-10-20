#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MODULOS="$ROOT/despliegue/modulos"

uso() {
    echo "Uso: $0 [--check|--dry-run|--apply]"
}

if [[ "$#" -ne 1 ]]; then
    uso
    exit 2
fi

case "$1" in
    --check) MODO="check" ;;
    --dry-run) MODO="dry-run" ;;
    --apply) MODO="apply" ;;
    *)
        echo "[ERROR] Opción desconocida: $1"
        uso
        exit 2
        ;;
esac

echo "=== Despliegue de Seguridad 1 ==="
echo "Repositorio: $ROOT"
echo

if [[ ! -d "$MODULOS" ]]; then
    echo "[ERROR] No existe el directorio de módulos: $MODULOS"
    exit 1
fi

shopt -s nullglob
scripts=("$MODULOS"/*.sh)

if (( ${#scripts[@]} == 0 )); then
    if [[ "$MODO" == "apply" ]]; then
        echo "[ERROR] No hay configuraciones que aplicar."
        exit 1
    fi

    echo "[INFO] Todavía no hay módulos de configuración."
    echo "No se modificó el sistema."
    exit 0
fi

echo "=== Validación de sintaxis ==="

for script in "${scripts[@]}"; do
    echo "Validando: ${script##*/}"

    if ! bash -n "$script"; then
        echo "[ERROR] Sintaxis inválida: ${script##*/}"
        exit 1
    fi
done

case "$MODO" in
    check)
        echo
        echo "=== Comprobación de módulos ==="

        for script in "${scripts[@]}"; do
            echo "--- ${script##*/} ---"

            if ! bash "$script" --check; then
                echo "[ERROR] Falló la comprobación de ${script##*/}"
                exit 1
            fi
        done

        echo "[OK] Comprobaciones finalizadas."
        ;;

    dry-run)
        echo
        echo "=== Simulación de módulos ==="

        for script in "${scripts[@]}"; do
            echo "--- ${script##*/} ---"

            if ! bash "$script" --dry-run; then
                echo "[ERROR] Falló la simulación de ${script##*/}"
                exit 1
            fi
        done

        echo "[OK] Simulación finalizada."
        ;;

    apply)
        if [[ "$EUID" -ne 0 ]]; then
            echo "[ERROR] Ejecuta con privilegios administrativos:"
            echo "sudo $0 --apply"
            exit 1
        fi

        echo
        echo "=== Comprobaciones previas ==="

        for script in "${scripts[@]}"; do
            echo "--- ${script##*/} ---"

            if ! bash "$script" --check; then
                echo "[ERROR] Se cancela la aplicación."
                echo "Falló la comprobación de ${script##*/}"
                exit 1
            fi
        done

        echo
        echo "Se aplicarán las configuraciones de los módulos."
        read -r -p "Para continuar, escribe APLICAR: " respuesta

        if [[ "$respuesta" != "APLICAR" ]]; then
            echo "Operación cancelada."
            exit 0
        fi

        for script in "${scripts[@]}"; do
            echo
            echo "=== Aplicando ${script##*/} ==="

            if ! bash "$script" --apply; then
                echo "[ERROR] Falló ${script##*/}."
                echo "Puede haber cambios previos aplicados."
                echo "Revisa el estado del sistema antes de reintentar."
                exit 1
            fi
        done

        echo
        echo "[OK] Despliegue finalizado."
        ;;
esac
