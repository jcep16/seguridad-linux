#!/bin/bash

echo "=== Comprobación del sistema ==="
echo "Fecha: $(date)"
echo "Usuario actual: $(whoami)"
echo "Sistema operativo:"
cat /etc/os-release | grep PRETTY_NAME

if [ "$EUID" -eq 0 ]; then
    echo "Privilegios: administrador (root)"
else
    echo "Privilegios: usuario normal"
fi

echo "=== Comprobación finalizada ==="
