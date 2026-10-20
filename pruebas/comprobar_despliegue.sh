#!/usr/bin/env bash

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/scripts/aplicar_configuracion.sh"

if [[ ! -f "$SCRIPT" ]]; then
    echo "[ERROR] No existe el instalador."
    exit 1
fi

TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

TEST_ROOT="$TEMP/proyecto"
mkdir -p "$TEST_ROOT/scripts" "$TEST_ROOT/despliegue/modulos"
cp "$SCRIPT" "$TEST_ROOT/scripts/aplicar_configuracion.sh"

fallos=0

probar() {
    local descripcion="$1"
    local codigo_esperado="$2"
    local texto_esperado="$3"
    shift 3

    local salida
    local codigo

    if salida="$(bash "$TEST_ROOT/scripts/aplicar_configuracion.sh" "$@" 2>&1)"; then
        codigo=0
    else
        codigo=$?
    fi

    if [[ "$codigo" -ne "$codigo_esperado" ]]; then
        echo "[ERROR] $descripcion: código $codigo; esperado $codigo_esperado"
        echo "$salida"
        fallos=$((fallos + 1))
        return
    fi

    if [[ "$salida" != *"$texto_esperado"* ]]; then
        echo "[ERROR] $descripcion: no se encontró el mensaje esperado."
        echo "$salida"
        fallos=$((fallos + 1))
        return
    fi

    if [[ "$salida" == *"NO_DEBE_APLICARSE_EN_LA_PRUEBA"* ]]; then
        echo "[ERROR] Se detectó una aplicación inesperada."
        fallos=$((fallos + 1))
        return
    fi

    echo "[OK] $descripcion"
}

echo "=== Pruebas del mecanismo de despliegue ==="

probar "Check sin módulos" 0 \
    "Todavía no hay módulos de configuración." --check

probar "Dry-run sin módulos" 0 \
    "No se modificó el sistema." --dry-run

probar "Apply sin módulos" 1 \
    "No hay configuraciones que aplicar." --apply

probar "Opción desconocida" 2 \
    "Opción desconocida" --opcion-invalida

cat > "$TEST_ROOT/despliegue/modulos/01_modulo_prueba.sh" <<'MODULE'
#!/usr/bin/env bash

set -euo pipefail

case "${1:-}" in
    --check)
        echo "PRUEBA_CHECK_OK"
        ;;
    --dry-run)
        echo "PRUEBA_DRY_RUN_OK"
        ;;
    --apply)
        echo "NO_DEBE_APLICARSE_EN_LA_PRUEBA"
        exit 99
        ;;
    *)
        echo "Opción no admitida" >&2
        exit 2
        ;;
esac
MODULE

probar "Check con módulo ficticio" 0 \
    "PRUEBA_CHECK_OK" --check

probar "Dry-run con módulo ficticio" 0 \
    "PRUEBA_DRY_RUN_OK" --dry-run

if (( fallos > 0 )); then
    echo "[ERROR] Fallaron $fallos pruebas."
    exit 1
fi

echo "[OK] Todas las pruebas del mecanismo pasaron."
