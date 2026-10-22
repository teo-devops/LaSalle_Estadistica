#!/usr/bin/env bash
# Preparar los cuadernos de Estadistica en Linux o macOS.
# No necesita sudo. También lo usa el devcontainer (.devcontainer/).
#
# Uso:   ./instalar.sh          (entorno + JupyterLab)
#        ./instalar.sh --vscode (ademas, extensiones de VS Code si esta instalado)
set -euo pipefail

cd "$(dirname "$0")"
CURSO="$(pwd)"

echo "====================================================="
echo "  PREPARAR ESTADISTICA EN LINUX / MACOS"
echo "====================================================="
echo
echo "Se descargara uv (Astral) si no lo tienes, Python 3.12"
echo "y las bibliotecas del curso. Necesitas Internet."
echo

error() {
    echo
    echo "====================================================="
    echo "  NO SE HA COMPLETADO LA INSTALACION"
    echo "====================================================="
    echo "$1"
    echo "Copia el mensaje de error de ARRIBA y ensenaselo al profesorado."
    echo "Puedes volver a ejecutar este script despues de resolverlo."
    exit 1
}

for f in pyproject.toml uv.lock datos sesiones/sesion1/s1.ipynb; do
    [ -e "$f" ] || error "Falta '$f'. Descarga y extrae la carpeta COMPLETA del curso."
done

echo "[1/3] Comprobando uv..."
if command -v uv >/dev/null 2>&1; then
    UV="$(command -v uv)"
elif [ -x "$HOME/.local/bin/uv" ]; then
    UV="$HOME/.local/bin/uv"
else
    echo "uv no esta instalado. Descargando desde astral.sh..."
    if command -v curl >/dev/null 2>&1; then
        curl -LsSf https://astral.sh/uv/install.sh | sh || error "Fallo la descarga de uv."
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://astral.sh/uv/install.sh | sh || error "Fallo la descarga de uv."
    else
        error "Necesitas curl o wget para descargar uv."
    fi
    UV="$HOME/.local/bin/uv"
    [ -x "$UV" ] || error "No se encontro uv tras instalarlo."
fi
echo "Usando $("$UV" --version)"

echo
echo "[2/3] Descargando Python 3.12 y las bibliotecas del curso..."
"$UV" sync --locked --group lab || error "uv sync ha fallado."

echo
echo "[3/3] VS Code (opcional)..."
if [ "${1:-}" = "--vscode" ]; then
    if command -v code >/dev/null 2>&1; then
        code --install-extension ms-python.python
        code --install-extension ms-toolsai.jupyter
    else
        echo "No se encontro el comando 'code'; se omite."
    fi
else
    echo "Omitido (usa ./instalar.sh --vscode para instalar las extensiones)."
fi

echo
echo "====================================================="
echo "  TODO LISTO"
echo "====================================================="
echo "Para abrir JupyterLab en el navegador:"
echo "    cd \"$CURSO\" && make lab"
echo "(o, sin make:  uv run --group lab jupyter lab)"
echo
echo "En VS Code: abre la carpeta, sesiones > sesion1 > s1.ipynb"
echo "y elige el kernel Python 3.12 de ${UV_PROJECT_ENVIRONMENT:-.venv}."
