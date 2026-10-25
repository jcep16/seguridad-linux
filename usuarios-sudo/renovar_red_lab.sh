#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script debe ejecutarse como root." >&2
    exit 1
fi

exec /usr/bin/networkctl reconfigure enp1s0
