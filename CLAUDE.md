# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles managed with **GNU Stow**. Each top-level directory is a Stow package that symlinks into `~/.config` or `~`.

## Syncing changes

```bash
# From repo root, stow a package (creates/updates symlinks):
stow <package>

# Restow after changing targets:
stow -R <package>

# Example: stow nvim git zshrc tmux starship
```

Stow maps `package/.config/tool/...` → `~/.config/tool/...` and `package/.fic` → `~/.fic`. After editing any config file, run `stow -R <package>` to relink.

## Architecture

- **No build system.** This is a config repo — changes take effect after `stow` and restarting the relevant app or sourcing the shell.
- **zshrc** is the central hub: env vars from `pass` cached in `~/.zsh_env_cache`, zinit plugins, zsh-vi-mode with starship deferred init, zellij pane nav bindings.
- **ccr/** is the Claude Code Router: `config.json` defines multi-provider routing (cliproxy via localhost:4444) with transformer plugins for gemini-cli, qwen-cli, and rovo-cli. CLI alias `code` → `ccr code --dangerously-skip-permissions`.
- **nvim** uses lazy.nvim with AstroNvim-style structure. Entrypoint: `nvim/.config/nvim/init.lua`. Plugin configs live in `nvim/.config/nvim/lua/plugins/setup-*.lua`.
- **zellij** config in KDL format with custom plugins (autolock, zjframes, sessionizer) loaded from `~/.config/zellij/plugins/`. Pane mode toggle is `Ctrl+]`.

## Key conventions

- Shell aliases: `v`/`vim`/`vi` → `nvim`, `z` → zellij, `f` → yazi, `a` → atac, `c` → clear
- `FUNCNEST=1000` and `skip_global_compinit=1` are required for starship/zvm compatibility
- Neovim lint: **selene** (`selene.toml`), format: **StyLua** (`.stylua.toml`)
- Neovim on exit triggers `zellij action switch-mode normal`
- Git pager is **delta** (side-by-side, navigate mode); merge tool is nvim + Diffview
- Secrets come from `pass` — never commit `.env`, `.gnupg/private-keys-v1.d/`, or `*/*.gpg`
- `.zsh_env_cache` is auto-regenerated when `.zshrc` is newer; do not edit it directly

## Testing changes

There are no automated tests. Verify changes by:
1. `stow -R <package>` to relink
2. Source the shell or restart the app to pick up changes
3. For nvim: `nvim --headless "+checkhealth"` for health checks; run selene/stylua manually for lint/format