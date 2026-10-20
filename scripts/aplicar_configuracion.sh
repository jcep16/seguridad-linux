#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MODULOS="$ROOT/despliegue/modulos"

MODO=""

for argumento in "$@"; do
    case "$argumento" in
        --check) MODO="check" ;;
        --dry-run) MODO="dry-run" ;;
        --apply) MODO="apply" ;;
        *)
            echo "[ERROR] Opción desconocida: $argumento"
            echo "Uso: $0 [--check|--dry-run|--apply]"
            exit 2
            ;;
    esac
done

if [[ -z "$MODO" ]]; then
    echo "Uso: $0 [--check|--dry-run|--apply]"
    exit 2
fi

echo "=== Despliegue de Seguridad 1 ==="
echo "Repositorio: $ROOT"
echo

if [[ ! -d "$MODULOS" ]]; then
    echo "[ERROR] No existe el directorio de módulos."
    exit 1
fi

shopt -s nullglob
scripts=("$MODULOS"/*.sh)

if (( ${#scripts[@]} == 0 )); then
    if [[ "$MODO" == "apply" ]]; then
        echo "[ERROR] No hay módulos de configuración que aplicar."
        exit 1
    fi

    echo "[INFO] No hay módulos de configuración implementados."
    echo "No se modificó el sistema."
    exit 0
fi

echo "=== Validación de módulos ==="

for script in "${scripts[@]}"; do
    echo "Validando: ${script##*/}"
    bash -n "$script"
done

echo
echo "Módulos encontrados: ${#scripts[@]}"

if [[ "$MODO" == "check" ]]; then
    echo "[OK] Los módulos tienen sintaxis Bash válida."
    echo "No se modificó el sistema."
    exit 0
fi

if [[ "$MODO" == "dry-run" ]]; then
    echo "[INFO] Simulación: se ejecutarían estos módulos:"
    printf ' - %s\n' "${scripts[@]##*/}"
    echo "No se modificó el sistema."
    exit 0
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "[ERROR] Ejecuta con sudo: sudo $0 --apply"
    exit 1
fi

echo
echo "ATENCIÓN: se aplicarán cambios al sistema operativo."
read -r -p "¿Continuar? Escribe APLICAR: " respuesta

if [[ "$respuesta" != "APLICAR" ]]; then
    echo "Operación cancelada."
    exit 0
fi

for script in "${scripts[@]}"; do
    echo
    echo "=== Aplicando ${script##*/} ==="
    bash "$script"
    echo "[OK] Finalizado: ${script##*/}"
done

echo
echo "Despliegue finalizado."
echo "Ejecuta las comprobaciones correspondientes a cada módulo."
