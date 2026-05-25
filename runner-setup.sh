#!/bin/bash
# Script para registrar un runner self-hosted en el repositorio
set -e

REPO_URL="https://github.com/kfabriciocastilloleo-arch/lab5"
RUNNER_DIR="$HOME/actions-runner"
LABELS="linux,lab5-runner"

echo "━━━ SETUP RUNNER SELF-HOSTED ━━━"
echo ""

# 1. Crear directorio
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

# 2. Descargar runner
echo "📥 Descargando runner..."
curl -o actions-runner-linux-x64-2.322.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz

# 3. Extraer
echo "📦 Extrayendo..."
tar xzf actions-runner-linux-x64-2.322.0.tar.gz

# 4. Configurar
echo "⚙️ Configurando runner..."
echo "📝 Labels: $LABELS"
echo "🔗 Repo: $REPO_URL"
echo ""
echo "Ve a Settings → Actions → Runners → New runner"
echo "Copia el token y pásalo al siguiente comando:"
echo ""
echo "  cd $RUNNER_DIR && ./config.sh --url $REPO_URL --token <TOKEN> --labels $LABELS"
echo ""

# 5. Iniciar (opcional)
echo ""
echo "Para iniciar el runner:"
echo "  ./run.sh    (modo interactivo)"
echo "  o"
echo "  sudo ./svc.sh install && sudo ./svc.sh start   (modo servicio)"
