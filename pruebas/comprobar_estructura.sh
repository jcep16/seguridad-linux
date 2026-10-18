#!/usr/bin/env bash

set -euo pipefail

directorios=(
    "usuarios-sudo"
    "jail"
    "apparmor"
    "ataques"
    "fail2ban"
    "clamav"
    "logwatch"
    "pruebas"
    "scripts"
    "configuracion"
    "documentacion"
)

errores=0

for directorio in "${directorios[@]}"; do
    if [[ -d "$directorio" ]]; then
        echo "[OK] Directorio encontrado: $directorio"
    else
        echo "[ERROR] Falta el directorio: $directorio"
        errores=$((errores + 1))
    fi
done

if (( errores > 0 )); then
    echo "Se encontraron $errores directorios faltantes."
    exit 1
fi

echo "La estructura básica del proyecto está completa."
