#!/usr/bin/env bash
set -Eeuo pipefail

case "${1:-}" in
    update)
        exec /usr/bin/apt-get update
        ;;
    upgrade)
        exec /usr/bin/apt-get upgrade
        ;;
    *)
        echo "Uso: $0 {update|upgrade}" >&2
        exit 2
        ;;
esac
