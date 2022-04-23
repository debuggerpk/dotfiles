#!/usr/bin/env bash
## install homebrew
echo "Install Homebrew (https://brew.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## install & activate zplug
echo "Install zplug (ZSH plguin manager)"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

## clone dotfiles to $HOME/dotfiles
echo "Clone dotfiles to $HOME/dotfiles"
git clone git@github.com:debuggerpk/dotfiles.git ~/dotfiles

## Backup Existing .zshrc, and create a link to ~/dotfiles/.zshrc in $HOME
[ -s "${HOME}/.zshrc" ] && mv ${HOME}/.zshrc ${HOME}/.zshrc.bck
ln -s ${HOME}/dotfiles/.zshrc ${HOME}/.zshrc

## Prepare Development Environment
echo "Preparing Development Environment"
## install all packages via brew
echo "Homebrew Packages"
CURRENT_DIR=`pwd`
export CLOUDSDK_PYTHON='/usr/bin/python3'
cd ${HOME}/dotfiles
brew bundle -v
cd ${CURRENT_DIR}

## python poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

## install krew (kubectl plugin manager)
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

## install nvm
echo "Node/Node Version Manager"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install --lts --default

# install rust
echo "Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "Cargo Packages"
cargo install cargo-bloat \
  cargo-bump \
  cargo-chef \
  cargo-edit \
  cargo-expand \
  cargo-generate \
  cargo-readme \
  cargo-release \
  cargo-strip \
  cargo-wasi \
  cargo-watch \
  cross

# install vim

## install vim-plug
echo "Install Vim Plug: The VIM Plugin Manager"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## copy .vimrc
mkdir -p ~/.config/nvim
ln -s ~/.dotfiles/.vimrc ~/.config/nvim/init.vim
nvim +'PlugInstall --sync' +'PlugUpdate' +qa

## adding shell integrations for iterm2
echo "Adding shell integrations for iterm2"
UTILITIES=(imgcat imgls it2api it2attention it2check it2copy it2dl it2getvar it2git it2setcolor it2setkeylabel it2ul it2universion)
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
