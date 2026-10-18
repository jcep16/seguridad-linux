#!/bin/bash

set -u

echo "=== Inventario del proyecto Seguridad 1 ==="
echo

echo "Sistema operativo:"
grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"'

echo
echo "Arquitectura:"
dpkg --print-architecture

echo
echo "Versión del kernel:"
uname -r

echo
echo "Componentes previstos:"
printf '%s\n' \
    "Usuarios y sudo" \
    "SSH y jail" \
    "AppArmor" \
    "Hydra" \
    "Fail2ban" \
    "ClamAV" \
    "Logwatch"

echo
echo "Este script solo consulta información."
echo "No instala paquetes ni modifica el sistema."
