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

echo
echo "Hecho. Ahora ejecuta 'claude' e inicia sesion (el login NO se guarda en el repo)."
