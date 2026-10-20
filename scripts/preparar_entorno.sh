#!/usr/bin/env bash

set -uo pipefail

# Resolver la ruta del repositorio para permitir ejecutar el script
# desde cualquier directorio.
DIRECTORIO_PROYECTO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIRECTORIO_PROYECTO" || exit 1

CONFIGURACION="configuracion/dependencias.conf"

if [[ ! -f "$CONFIGURACION" ]]; then
    echo "[ERROR] No existe $CONFIGURACION"
    exit 1
fi

# Cargar los requisitos definidos para el proyecto.
# shellcheck source=/dev/null
source "$CONFIGURACION"
# Permitir sustituir las herramientas solo durante pruebas automatizadas.
if [[ -n "${HERRAMIENTAS_BASE_PRUEBA:-}" ]]; then
    read -r -a HERRAMIENTAS_BASE <<< "$HERRAMIENTAS_BASE_PRUEBA"
fi
echo "======================================"
echo " Preparación del entorno Seguridad 1"
echo "======================================"
echo

# 1. Comprobar los datos del sistema operativo.
if [[ ! -r /etc/os-release ]]; then
    echo "[ERROR] No se encuentra /etc/os-release"
    exit 1
fi

ID_SISTEMA=""
VERSION_SISTEMA=""
NOMBRE_SISTEMA="desconocido"

while IFS='=' read -r clave valor; do
    valor="${valor%\"}"
    valor="${valor#\"}"

    case "$clave" in
        ID) ID_SISTEMA="$valor" ;;
        VERSION_ID) VERSION_SISTEMA="$valor" ;;
        PRETTY_NAME) NOMBRE_SISTEMA="$valor" ;;
    esac
done < /etc/os-release

echo "Sistema detectado: $NOMBRE_SISTEMA"

if [[ "$ID_SISTEMA" != "$SISTEMA_ID" ]]; then
    echo "[ERROR] Se requiere un sistema basado en $SISTEMA_ID."
    exit 1
fi

if [[ "${1:-}" == "--ci" ]]; then
    echo "[OK] Modo CI: se permite Ubuntu $VERSION_SISTEMA"
elif [[ "$VERSION_SISTEMA" != "$SISTEMA_VERSION" ]]; then
    echo "[ERROR] Se requiere $SISTEMA_ID $SISTEMA_VERSION."
    exit 1
fi
echo "[OK] Sistema operativo compatible"

# 2. Comprobar arquitectura.
if ! command -v dpkg >/dev/null 2>&1; then
    echo "[ERROR] No se encuentra dpkg."
    exit 1
fi

arquitectura=$(dpkg --print-architecture)

if [[ "$arquitectura" != "$ARQUITECTURA" ]]; then
    echo "[ERROR] Se requiere arquitectura $ARQUITECTURA."
    echo "Arquitectura detectada: $arquitectura"
    exit 1
fi

echo "[OK] Arquitectura: $arquitectura"
echo

# 3. Identificar las herramientas base que faltan.
faltantes=()

echo "=== Herramientas base ==="

for herramienta in "${HERRAMIENTAS_BASE[@]}"; do
    if command -v "$herramienta" >/dev/null 2>&1; then
        echo "[OK] $herramienta está disponible"
    else
        echo "[PENDIENTE] $herramienta no está disponible"
        faltantes+=("$herramienta")
    fi
done

# 4. Si no falta ninguna herramienta, no modificar el sistema.
if (( ${#faltantes[@]} == 0 )); then
    echo
    echo "El entorno ya tiene las herramientas base."
    echo "No es necesario instalar paquetes."
    exit 0
fi

echo
echo "Herramientas ausentes: ${faltantes[*]}"
echo "No se instalarán componentes de las prácticas."

# 5. Modo de comprobación: nunca instala ni solicita confirmación.
if [[ "${1:-}" == "--check-only" ]]; then
    echo "[ERROR] Faltan herramientas base."
    echo "Modo de comprobación: no se instalará nada."
    exit 1
fi

# 6. Verificar que el gestor de paquetes está disponible.
if ! command -v apt-get >/dev/null 2>&1; then
    echo "[ERROR] No se encuentra apt-get."
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    if ! command -v sudo >/dev/null 2>&1; then
        echo "[ERROR] Se necesita sudo para instalar los paquetes."
        exit 1
    fi
    SUDO=(sudo)
else
    SUDO=()
fi

# 7. Solicitar autorización explícita.
echo
read -r -p \
    "¿Deseas actualizar los índices e instalar las herramientas base? [s/N]: " \
    respuesta

if [[ ! "$respuesta" =~ ^[sS]([iI])?$ ]]; then
    echo "Operación cancelada. No se han instalado paquetes."
    exit 0
fi

# 8. Actualizar índices e instalar exclusivamente las herramientas base
# que faltan.
if ! "${SUDO[@]}" apt-get update; then
    echo "[ERROR] No se pudieron actualizar los índices."
    exit 1
fi

if ! "${SUDO[@]}" apt-get install -y -- "${faltantes[@]}"; then
    echo "[ERROR] No se pudieron instalar todas las herramientas."
    exit 1
fi

# 9. Verificar el resultado de la instalación.
echo
echo "=== Verificación final ==="

errores=0

for herramienta in "${HERRAMIENTAS_BASE[@]}"; do
    if command -v "$herramienta" >/dev/null 2>&1; then
        echo "[OK] $herramienta está disponible"
    else
        echo "[ERROR] Falta $herramienta"
        errores=$((errores + 1))
    fi
done

if (( errores == 0 )); then
    echo
    echo "Preparación de herramientas base completada."
else
    echo
    echo "La preparación terminó con errores."
    exit 1
fi
