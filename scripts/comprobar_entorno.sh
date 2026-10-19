#!/usr/bin/env bash

set -uo pipefail

errores=0

comprobar() {
    if "$@"; then
        return 0
    else
        errores=$((errores + 1))
        return 0
    fi
}

echo "======================================"
echo " Comprobación del entorno Seguridad 1"
echo "======================================"
echo

# 1. Sistema operativo
echo "=== Sistema operativo ==="

if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    echo "Sistema: ${PRETTY_NAME:-desconocido}"

    if [[ "${ID:-}" == "ubuntu" ]]; then
        echo "[OK] Sistema basado en Ubuntu"
    else
        echo "[ERROR] Se requiere Ubuntu"
        errores=$((errores + 1))
    fi
else
    echo "[ERROR] No se encuentra /etc/os-release"
    errores=$((errores + 1))
fi
# 2. Arquitectura
echo
echo "=== Arquitectura ==="

arquitectura=$(dpkg --print-architecture)

if [[ "$arquitectura" == "amd64" ]]; then
    echo "[OK] Arquitectura: $arquitectura"
else
    echo "[ERROR] Se requiere amd64; detectada: $arquitectura"
    errores=$((errores + 1))
fi

# 3. Herramientas básicas
echo
echo "=== Herramientas ==="

for herramienta in bash git python3; do
    if command -v "$herramienta" >/dev/null 2>&1; then
        echo "[OK] $herramienta está disponible"
    else
        echo "[ERROR] Falta la herramienta: $herramienta"
        errores=$((errores + 1))
    fi
done

# 4. Recursos disponibles
echo
echo "=== Recursos ==="
echo "Memoria disponible:"
free -h

echo
echo "Espacio disponible en la raíz:"
df -h /

# 5. Resultado
echo
echo "======================================"

if (( errores == 0 )); then
    echo "RESULTADO: comprobaciones correctas"
    exit 0
else
    echo "RESULTADO: $errores comprobación(es) fallida(s)"
    exit 1
fi
