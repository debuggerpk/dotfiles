echo "zsh: preparing ..."
# global variables
export CLICOLOR=1
export CLOUDSDK_PYTHON='/usr/bin/python3'
export KEYTIMEOUT=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# history
export HISTSIZE=10000
export SAVEHIST=10000
setopt SHARE_HISTORY

echo "zsh: bashcompinit, zmv ..."

# zsh utilities
autoload -U +X bashcompinit && bashcompinit
autoload -U zmv

# homebrew
echo "Enabling Homebrew and linking formulas"
eval "$(/opt/homebrew/bin/brew shellenv)"
export LDFLAGS="-L$(brew --prefix openssl)/lib"
export CPPFLAGS="-I$(brew --prefix openssl)/include"

echo "node: with nvm and bun ..."

# node
export NVM_AUTO_USE=true
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# bun
export BUN_INSTALL="$HOME/.bun"

echo "python: with uv ..."
source $HOME/.local/bin/env

# python
echo "go: path & root, this requires internet ..."

# go
export GOPATH=$HOME/go
export GOROOT=/opt/homebrew/opt/go/libexec

echo "k8s: krew plugin manager .."

# krew
export KREW_ROOT="${HOME}/.krew"

echo "zsh: updating path ..."

# path
path+=(
  "$HOME/.yarn/bin" # yarn
  "$HOME/.cargo/bin" # rust
  "$HOME/.local/bin" # poetry
  "$BUN_INSTALL/bin" # bun
  "$GOPATH/bin" # go
  "$GOROOT/bin" # go
  "$KREW_ROOT/bin" # krew
)

echo "zsh: zplug ..."

source ~/.zplug/init.zsh

# load plugins
zplug "cpitt/zsh-dotenv",                       from:github
zplug "lukechilds/zsh-nvm",                     from:github
zplug "zsh-users/zsh-history-substring-search", defer:1
zplug "zsh-users/zsh-syntax-highlighting",      defer:1
zplug "zsh-users/zsh-autosuggestions",          defer:1

# zplug init
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
      echo; zplug install
  fi
fi

zplug load --verbose

# zplug plugin configurations
if zplug check zsh-users/zsh-autosuggestions; then
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
fi

bindkey -v

if zplug check zsh-users/zsh-history-substring-search; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

echo "zsh: loading completions from brew"

# completions
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

## gcloud comletions
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"

## terraform completions
# complete -o nospace -C /usr/local/bin/terraform terraform

## nvm completions
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

## bun completions
[ -s "/Users/jay/.bun/_bun" ] && source "/Users/jay/.bun/_bun"

echo "zsh: setting up prompt"



echo "zsh: handy aliases"

# aliases
alias vi="nvim"
alias vim="nvim"
alias dkrup="docker-compose up"
alias dkrdn="docker-compose down"
alias ls="lsd"
alias cd="z"

echo "zsh: finalazing .."

# starship
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

echo "happy coding ..."

. "$HOME/.local/bin/env"
