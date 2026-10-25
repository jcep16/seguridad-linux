#!/usr/bin/env bash
set -Eeuo pipefail

DESTINO="/var/backups/web_lab"
ORIGEN="/var/www"
ARCHIVO="$DESTINO/web_$(date +%Y%m%d_%H%M%S).tar.gz"

exec /usr/bin/tar -czf "$ARCHIVO" -C "$ORIGEN" .
