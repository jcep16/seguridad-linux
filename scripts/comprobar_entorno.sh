#!/usr/bin/env bash

set -uo pipefail

errores=0

# Cargar requisitos comunes
CONFIGURACION="configuracion/dependencias.conf"

if [[ ! -f "$CONFIGURACION" ]]; then
    echo "[ERROR] No existe $CONFIGURACION"
    exit 1
fi

# El archivo debe contener únicamente variables y arrays de configuración.
# shellcheck source=/dev/null
source "$CONFIGURACION"

echo "======================================"
echo " Comprobación del entorno Seguridad 1"
echo "======================================"
echo

# 1. Sistema operativo
echo "=== Sistema operativo ==="

if [[ -r /etc/os-release ]]; then
    ID_SISTEMA=""
    VERSION_SISTEMA=""
    NOMBRE_SISTEMA="desconocido"

    while IFS='=' read -r clave valor; do
        case "$clave" in
            ID) ID_SISTEMA="${valor//\"/}" ;;
            VERSION_ID) VERSION_SISTEMA="${valor//\"/}" ;;
            PRETTY_NAME) NOMBRE_SISTEMA="${valor//\"/}" ;;
        esac
    done < /etc/os-release

    echo "Sistema detectado: $NOMBRE_SISTEMA"

    if [[ "$ID_SISTEMA" == "$SISTEMA_ID" ]]; then
        echo "[OK] Distribución: $SISTEMA_ID"
    else
        echo "[ERROR] Se esperaba $SISTEMA_ID"
        errores=$((errores + 1))
    fi

    if [[ "${1:-}" == "--ci" ]]; then
        echo "[INFO] Modo CI: se acepta cualquier versión de Ubuntu"
    else
        if [[ "$VERSION_SISTEMA" == "$SISTEMA_VERSION" ]]; then
            echo "[OK] Versión: $SISTEMA_VERSION"
        else
            echo "[ERROR] Se esperaba la versión $SISTEMA_VERSION"
            errores=$((errores + 1))
        fi
    fi
else
    echo "[ERROR] No se encuentra /etc/os-release"
    errores=$((errores + 1))
fi

# 2. Arquitectura
echo
echo "=== Arquitectura ==="

arquitectura=$(dpkg --print-architecture)

# shellcheck disable=SC2153
if [[ "$arquitectura" == "$ARQUITECTURA" ]]; then
    echo "[OK] Arquitectura: $arquitectura"
else
    echo "[ERROR] Se esperaba $ARQUITECTURA; detectada: $arquitectura"
    errores=$((errores + 1))
fi

# 3. Herramientas base
echo
echo "=== Herramientas base ==="

for herramienta in "${HERRAMIENTAS_BASE[@]}"; do
    if command -v "$herramienta" >/dev/null 2>&1; then
        echo "[OK] $herramienta está disponible"
    else
        echo "[ERROR] Falta la herramienta: $herramienta"
        errores=$((errores + 1))
    fi
done

# 4. Componentes de seguridad: solo inventario, no instalación
echo
echo "=== Estado de paquetes de seguridad ==="

for paquete in "${COMPONENTES_SEGURIDAD[@]}"; do
    if dpkg-query -W -f='${Status}' "$paquete" 2>/dev/null |
        grep -q "install ok installed"; then
        echo "[INSTALADO] $paquete"
    else
        echo "[PENDIENTE] $paquete"
    fi
done

# 5. Recursos disponibles
echo
echo "=== Recursos ==="
free -h
echo
df -h /

# 6. Resultado
echo
echo "======================================"

if (( errores == 0 )); then
    echo "RESULTADO: comprobaciones correctas"
    exit 0
else
    echo "RESULTADO: $errores comprobación(es) fallida(s)"
    exit 1
fi
