#!/bin/bash

echo "=== Comprobación del sistema ==="
echo "Fecha: $(date)"
echo "Usuario actual: $(whoami)"
echo "Sistema operativo:"
grep PRETTY_NAME /etc/os-release
if [ "$EUID" -eq 0 ]; then
    echo "Privilegios: administrador (root)"
else
    echo "Privilegios: usuario normal"
fi

echo "=== Comprobación finalizada ==="
