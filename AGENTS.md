# AGENTS.md — dotfiles

## What this repo is

Personal macOS dotfiles managed with **GNU Stow**. Each top-level directory is a Stow package that symlinks its contents into `~/.config` or `~`.

## Setup / sync

```bash
# From repo root, stow a package (creates symlinks):
stow <package>

# Example: stow nvim git zshrc tmux starship
```

Stow expects the directory structure `package/.config/tool/...` → `~/.config/tool/...`. Directories that live at the home root (e.g. `git/.gitconfig`) symlink to `~/.gitconfig`.

## Key packages

| Directory | What it configures |
|-----------|--------------------|
| `zshrc/` | `.zshrc` — zinit plugin manager, zsh-vi-mode, starship, fzf-tab, atuin, zoxide, pyenv |
| `nvim/` | Neovim config at `.config/nvim/` — lazy.nvim plugin manager, Lua-based |
| `tmux/` | `.config/tmux/tmux.conf` — prefix `C-a`, TPM plugin manager, vi keys |
| `git/` | `.gitconfig` — delta pager, user "Grandis SYF" |
| `starship/` | `.config/starship/starship.toml` |
| `ghostty/` | `.config/ghostty/` |
| `kitty/` | `.config/kitty/` |
| `wezterm/` | `.wezterm.lua` |
| `alacritty/` | `.config/alacritty/` |
| `yazi/` | `.config/yazi/` |
| `atuin/` | `.config/atuin/` |
| `atac/` | `.config/atac/` |
| `lazygit/` | `.config/lazygit/` |
| `hammerspoon/` | macOS window manager config |
| `zellij/` | `.config/zellij/` — custom config.kdl, tmux-mode, autolock + zjframes plugins |
| `ccr/` | `.claude-code-router/` — Claude Code Router with multi-provider routing |
| `claude/` | `.claude/` — claude-powerline theme (tokyo-night/dark) |
| `cliapiproxy/` | `.config/cliapiproxy/` — cli-proxy-api-plus config |
| `codex/` | `.codex/` — OpenAI Codex CLI auth/config |
| `crush/` | `.config/crush/` + `.crush/` |
| `gnupg/` | `.gnupg/` — GnuPG keys (sensitive dirs gitignored) |
| `neovide/` | `.config/neovide/` |
| `warp/` | `.warp/` |
| `lazycommit/` | `.config/lazycommit/` |
| `scooter/` | `.config/scooter/config.toml` |
| `suc/` | `.config/suc/` — suc + suc.config.json |
| `cship/` | `.config/cship/` |
| `toney/` | `Library/Application Support/toney/` |
| `font/` | SFMono Nerd Font (Ligaturized) |

## Shell conventions (.zshrc)

- **Editor**: `nvim` (aliases: `vim`, `v`, `vi` all → `nvim`)
- **File manager**: `yazi` via `y()` function (cd-on-exit)
- **Zellij**: aliased to `z`, custom completion for session names
- **Cursor colors**: zsh-vi-mode sets OSC 12 cursor colors based on mode
- **Zellij pane nav**: `Ctrl+H/J/K/L` in zsh-vi-mode normal mode navigates zellij panes
- **Aliases**: `f` → yazi, `a` → atac, `c` → clear, `ls` → eza with git/icons
- **AI CLI aliases**: `code` → `ccr code --dangerously-skip-permissions`, `rovo` → `acli rovodev run`
- **Env cache**: `~/.zsh_env_cache` is regenerated when `.zshrc` is newer; populated from `pass`
- `FUNCNEST=1000` — raised to avoid starship/zvm nesting conflicts
- `skip_global_compinit=1` — skips system compinit for faster startup

## Neovim

- Plugin manager: **lazy.nvim** (auto-installs on first run)
- Config entrypoint: `nvim/.config/nvim/init.lua`
- Lint: **selene** (`selene.toml`), Format: **StyLua** (`.stylua.toml`)
- On `VimLeave`, runs `zellij action switch-mode normal`

## Tmux

- Prefix: **Ctrl-a** (not default Ctrl-b)
- Split: `prefix + |` (vertical), `prefix + -` (horizontal)
- Resize: `prefix + h/j/k/l` by 5 cells
- Pane switch: `prefix + Alt+h/j/k/l` (no prefix needed)
- Reload: `prefix + r`
- TPM plugins in `tmux/.config/tmux/plugins/`

## Git

- Pager: **delta** with side-by-side and navigate mode
- Merge tool: nvim + Diffview
- Global excludes: `/Users/grandis/.gitignore_global`
- LFS enabled

## Secrets / sensitive data

- API keys and endpoints are pulled from **`pass`** at shell startup into `~/.zsh_env_cache`
- GnuPG private keys and seeds are gitignored — do not commit
- `.env` files are gitignored

## AI tool integrations (zshrc)

- `ANTHROPIC_BASE_URL` → Alibaba Dashscope proxy
- `ANTHROPIC_MODEL` → `qwen3.5-plus`
- `ASK_SH_*` env vars point to Qwen worker endpoint
- `CLAUDE_POWERLINE_*` theme set to tokyo-night/dark
