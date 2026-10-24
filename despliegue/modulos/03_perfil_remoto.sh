#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
USUARIO="remoto_lab"
REGLA="/etc/sudoers.d/remoto_lab"
TEMP="$(mktemp)"
trap 'rm -f "$TEMP"' EXIT

crear_scripts() {
    install -o root -g root -m 0755 \
        "$ROOT/usuarios-sudo/reiniciar_ssh_lab.sh" \
        /usr/local/sbin/reiniciar_ssh_lab

    install -o root -g root -m 0755 \
        "$ROOT/usuarios-sudo/renovar_red_lab.sh" \
        /usr/local/sbin/renovar_red_lab
}

crear_regla() {
    printf '%s\n' \
        'remoto_lab ALL=(root) /usr/local/sbin/reiniciar_ssh_lab, /usr/local/sbin/renovar_red_lab' \
        > "$TEMP"

    chown root:root "$TEMP"
    chmod 0440 "$TEMP"
    visudo -c -f "$TEMP"
}

case "${1:-}" in
    --check)
        command -v visudo >/dev/null
        command -v networkctl >/dev/null
        test -f "$ROOT/usuarios-sudo/reiniciar_ssh_lab.sh"
        test -f "$ROOT/usuarios-sudo/renovar_red_lab.sh"
        bash -n "$ROOT/usuarios-sudo/reiniciar_ssh_lab.sh"
        bash -n "$ROOT/usuarios-sudo/renovar_red_lab.sh"
        echo "[OK] Herramientas y scripts disponibles."

        if id "$USUARIO" >/dev/null 2>&1; then
            echo "[OK] El usuario $USUARIO ya existe."
        else
            echo "[INFO] Se crearía el usuario $USUARIO al aplicar."
        fi
        ;;

    --dry-run)
        echo "[SIMULACIÓN] Se crearía remoto_lab si no existe."
        echo "[SIMULACIÓN] Se instalarían los scripts de SSH y red."
        echo "[SIMULACIÓN] Se configuraría $REGLA."
        echo "No se modificará el sistema."
        ;;

    --apply)
        if [[ $EUID -ne 0 ]]; then
            echo "[ERROR] Ejecuta el despliegue con sudo."
            exit 1
        fi

        if ! command -v networkctl >/dev/null 2>&1; then
            echo "[ERROR] No se encuentra networkctl."
            exit 1
        fi

        if ! id "$USUARIO" >/dev/null 2>&1; then
            useradd --create-home --shell /bin/bash "$USUARIO"
            passwd --lock "$USUARIO"
            echo "[OK] Usuario $USUARIO creado y contraseña bloqueada."
        fi

        crear_scripts
        crear_regla
        install -o root -g root -m 0440 "$TEMP" "$REGLA"

        if ! visudo -c; then
            echo "[ERROR] La validación global de sudoers falló."
            exit 1
        fi

        echo "[OK] Perfil remoto instalado."
        echo "[INFO] Permisos limitados a los dos scripts autorizados."
        echo "[INFO] El acceso SSH requiere configurar un método de autenticación aparte."
        ;;

    *)
        echo "Uso: $0 {--check|--dry-run|--apply}" >&2
        exit 2
        ;;
esac
