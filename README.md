# dotfiles

Config personal de Claude Code.

## Nuevo PC

```sh
# 1. instalar Claude Code
# 2. clonar este repo
git clone https://github.com/TU-USUARIO/dotfiles ~/dotfiles

# 3. enlazar la config
cd ~/dotfiles && ./install.sh

# 4. arrancar e iniciar sesion
claude
```

El login (`~/.claude/.credentials.json`) **no** está en el repo: se hace a mano en cada máquina.

## Qué incluye

| Archivo | Qué es |
|---|---|
| `claude/settings.json` | tema, hook de sonido, permisos |
| `claude/sounds/` | sonido del hook |

## Actualizar

Como `~/.claude/settings.json` es un symlink a este repo, editas normal y:

```sh
cd ~/dotfiles && git add -A && git commit -m "update" && git push
```
