#!/usr/bin/env bash

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/scripts/aplicar_configuracion.sh"

fallos=0

probar() {
    local descripcion="$1"
    local codigo_esperado="$2"
    shift 2

    local salida
    local codigo

    salida="$(bash "$SCRIPT" "$@" 2>&1)"
    codigo=$?

    if [[ "$codigo" -eq "$codigo_esperado" ]]; then
        echo "[OK] $descripcion"
    else
        echo "[ERROR] $descripcion"
        echo "$salida"
        echo "Código esperado: $codigo_esperado; obtenido: $codigo"
        fallos=$((fallos + 1))
    fi
}

echo "=== Pruebas del mecanismo de despliegue ==="

if [[ ! -d "$ROOT/despliegue/modulos" ]]; then
    echo "[ERROR] No existe despliegue/modulos."
    exit 1
fi

shopt -s nullglob
modulos=("$ROOT/despliegue/modulos"/*.sh)

if (( ${#modulos[@]} == 0 )); then
    probar "Modo --check sin módulos" 0 --check
    probar "Modo --dry-run sin módulos" 0 --dry-run
    probar "Modo --apply sin módulos" 1 --apply
else
    echo "[INFO] Hay módulos implementados."
    echo "Las pruebas de ausencia de módulos se omiten."
    probar "Modo --check" 0 --check
    probar "Modo --dry-run" 0 --dry-run
fi

if (( fallos > 0 )); then
    echo "[ERROR] Fallaron $fallos pruebas."
    exit 1
fi

echo "[OK] Pruebas del despliegue finalizadas."
