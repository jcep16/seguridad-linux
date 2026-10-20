#!/usr/bin/env bash

set -uo pipefail

CONFIGURACION="configuracion/dependencias.conf"

if [[ ! -f "$CONFIGURACION" ]]; then
    echo "[ERROR] No existe $CONFIGURACION"
    exit 1
fi

# Cargar los requisitos definidos para el proyecto.
# shellcheck source=/dev/null
source "$CONFIGURACION"

mostrar_estado_paquete() {
    local paquete="$1"

    if dpkg-query -W -f='${Status}' "$paquete" 2>/dev/null |
        grep -q "install ok installed"; then
        printf '[INSTALADO] %s\n' "$paquete"
    else
        printf '[PENDIENTE] %s\n' "$paquete"
    fi
}

echo "======================================"
echo " Inventario del proyecto Seguridad 1"
echo "======================================"
echo

echo "=== Sistema operativo ==="
if [[ -r /etc/os-release ]]; then
    grep '^PRETTY_NAME=' /etc/os-release |
        cut -d= -f2- |
        tr -d '"'
else
    echo "[ERROR] No se encuentra /etc/os-release"
fi

echo
echo "=== Arquitectura ==="
dpkg --print-architecture

echo
echo "=== Kernel ==="
uname -r

echo
echo "=== Herramientas base ==="
for herramienta in "${HERRAMIENTAS_BASE[@]}"; do
    if command -v "$herramienta" >/dev/null 2>&1; then
        printf '[DISPONIBLE] %s\n' "$herramienta"
    else
        printf '[PENDIENTE] %s\n' "$herramienta"
    fi
done

echo
echo "=== Paquetes de infraestructura ==="
for paquete in "${PAQUETES_INFRAESTRUCTURA[@]}"; do
    mostrar_estado_paquete "$paquete"
done

echo
echo "=== Componentes de las prácticas ==="
for paquete in "${COMPONENTES_PRACTICAS[@]}"; do
    mostrar_estado_paquete "$paquete"
done

echo
echo "=== Recursos ==="
free -h
echo
df -h /

echo
echo "Inventario completado."
echo "Este script solo consulta información."
echo "No instala paquetes ni modifica el sistema."
