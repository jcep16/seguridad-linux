#!/bin/bash

echo "=== Usuarios y grupos del sistema ==="

echo
echo "Usuarios configurados:"
getent passwd | cut -d: -f1

echo
echo "Grupos administrativos habituales:"
getent group sudo
getent group adm

echo
echo "Usuario actual:"
whoami

echo
echo "Grupos del usuario actual:"
groups

echo
echo "=== Comprobación finalizada ==="
