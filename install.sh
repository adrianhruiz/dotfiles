#!/usr/bin/env bash
# Enlaza la config de Claude Code de este repo a ~/.claude/
# Uso: ./install.sh
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "$dst.bak-$STAMP"
    echo "  backup: $dst -> $dst.bak-$STAMP"
  fi
  ln -sfn "$src" "$dst"
  echo "  link:   $dst -> $src"
}

echo "Instalando config de Claude Code desde $DOT/claude"
link "$DOT/claude/settings.json"      "$CLAUDE_DIR/settings.json"
link "$DOT/claude/CLAUDE.md"          "$CLAUDE_DIR/CLAUDE.md"
link "$DOT/claude/sounds/habbo.wav"   "$CLAUDE_DIR/sounds/habbo.wav"
link "$DOT/claude/sounds/habbo.m4a"   "$CLAUDE_DIR/sounds/habbo.m4a"

echo "Enlazando config de la statusline (ccstatusline)"
link "$DOT/config/ccstatusline/settings.json" "$HOME/.config/ccstatusline/settings.json"
if ! command -v ccstatusline >/dev/null 2>&1; then
  echo "  ccstatusline no encontrado; instalando con npm..."
  npm install -g ccstatusline@latest
fi

echo "Enlazando skills propias desde $DOT/agents/skills"
for skill in "$DOT"/agents/skills/*/; do
  skill="${skill%/}"
  name="$(basename "$skill")"
  link "$skill" "$HOME/.agents/skills/$name"
  link "$skill" "$CLAUDE_DIR/skills/$name"
done

echo
echo "Hecho. Ahora ejecuta 'claude' e inicia sesion (el login NO se guarda en el repo)."
