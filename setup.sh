#!/usr/bin/env bash
## install homebrew
# echo "Install Homebrew (https://brew.sh)"
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# eval "$(/opt/homebrew/bin/brew shellenv)"

## install & activate zplug
echo "Install zplug (ZSH plguin manager)"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

## clone dotfiles to $HOME/dotfiles
# echo "Clone dotfiles to $HOME/dotfiles"
# git clone git@github.com:debuggerpk/dotfiles.git ~/dotfiles

## Backup Existing .zshrc, and create a link to ~/dotfiles/.zshrc in $HOME
[ -s "${HOME}/.zshrc" ] && mv" ${HOME}/.zshrc" "${HOME}/.zshrc.bck"
ln -s "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"

## Prepare Development Environment
echo "Preparing Development Environment"

## install all packages via brew
echo "Homebrew Packages"
CURRENT_DIR=$(pwd)
cd "${HOME}/dotfiles" || exit
brew bundle -v
cd "${CURRENT_DIR}" || exit

## Python
echo "Python with uv"
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

## install nvm
echo "Node/Node Version Manager"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts --default

## Setup GO
export GOPATH=$HOME/go

# install rust
echo "Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "Cargo Packages"
cargo install \
  bottom \
  cargo-bloat \
  cargo-bump \
  cargo-chef \
  cargo-edit \
  cargo-expand \
  cargo-generate \
  cargo-readme \
  cargo-release \
  cargo-strip \
  cargo-update \
  cargo-wasi \
  cargo-watch \
  cross \
  licensure \
  mdbook \
  procs \
  xargo

## Cloud Development
brew install --cask google-cloud-sdk

## install krew (kubectl plugin manager)
echo "Kubernetes Krew (Plugin Manager)"
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
