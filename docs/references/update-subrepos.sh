#!/bin/bash
# Script para actualizar todos los subrepos de referencia

set -e

REPOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/repos"

if [ ! -d "$REPOS_DIR" ]; then
  echo "❌ Directorio repos no encontrado: $REPOS_DIR"
  exit 1
fi

echo "🔄 Actualizando subrepos en: $REPOS_DIR"
echo ""

cd "$REPOS_DIR"

for repo in */; do
  echo "📦 Actualizando $repo..."

  if [ ! -d "$repo/.git" ]; then
    echo "  ⚠️  No es un repo git, saltando..."
    echo ""
    continue
  fi

  cd "$repo"

  # Obtener branch actual
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  # Intentar pull desde origin
  if git pull origin "$current_branch" 2>&1 | grep -q "Already up to date"; then
    echo "  ✅ Ya está actualizado"
  else
    echo "  ✅ Actualizado"
  fi

  cd ..
  echo ""
done

echo "✨ Todos los subrepos han sido actualizados"
