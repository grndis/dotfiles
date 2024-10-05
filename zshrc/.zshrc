################################################################
# Shell Options
################################################################
setopt globdots  #include hidden files in globbing


################################################################
# MacOS Homebrew
################################################################
if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


################################################################
# Zinit
################################################################
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"


################################################################
# Zinit Plugins
################################################################
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode



################################################################
# ZVM Custom Config
################################################################
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

################################################################
# Load completions
################################################################
autoload -Uz compinit && compinit
zinit cdreplay -q


################################################################
# Keybindings
################################################################
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region


################################################################
# History
################################################################
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


################################################################
# Completion styling
################################################################
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


################################################################
# Aliases
################################################################
alias vim='nvim'
alias c='clear'
alias ls="eza --color=always --git --icons=always"

################################################################
# Shell integrations
################################################################
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"


################################################################
# pnpm
################################################################
export PNPM_HOME="/Users/grandis/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


################################################################
# Export PATH
################################################################
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/Users/grandis/.composer/vendor/bin"
export PATH="/usr/local/elasticsearch/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

################################################################
## Pyenv setup
################################################################
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

################################################################
# Starship
################################################################
eval "$(starship init zsh)"

