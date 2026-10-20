
#!/usr/bin/env bash

set -uo pipefail

DIRECTORIO_PROYECTO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$DIRECTORIO_PROYECTO/scripts/preparar_entorno.sh"

if [[ ! -f "$SCRIPT" ]]; then
    echo "[ERROR] No existe $SCRIPT"
    exit 1
fi

echo "=== Prueba de preparación del entorno ==="

# Caso 1: herramientas reales disponibles.
if bash "$SCRIPT" --check-only; then
    echo "[OK] El entorno actual pasa la comprobación"
else
    echo "[ERROR] El entorno actual no pasa la comprobación"
    exit 1
fi

echo
echo "=== Simulación de herramienta ausente ==="

# Caso 2: simular una herramienta que no existe.
# La configuración original no se modifica y no se instalan paquetes.
if HERRAMIENTAS_BASE_PRUEBA="herramienta_inexistente_para_pruebas" \
    bash "$SCRIPT" --ci --check-only; then
    echo "[ERROR] Se esperaba un fallo por herramienta ausente"
    exit 1
else
    resultado=$?
    if [[ "$resultado" -ne 1 ]]; then
        echo "[ERROR] Código de salida inesperado: $resultado"
        exit 1
    fi
    echo "[OK] Se detectó la herramienta ausente sin instalarla"
fi

echo
echo "Todas las pruebas de preparación pasaron."
