#!/usr/bin/env bash

# Helper function to prompt for user action
prompt_action() {
  echo "--------------------------------------------------"
  echo "ACTION: $1"
  echo "--------------------------------------------------"
  echo "--> Do you want to proceed? (y)es, (n)o, (c)ustomize"
  read -n 1 -r REPLY
  echo
}

## install homebrew
prompt_action "Install Homebrew (https://brew.sh)"
case "$REPLY" in
  y|Y)
    echo "--> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ;;
  c|C)
    echo "--> The command to be run is:"
    echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "--> No other customization options available for this step."
    ;;
  *)
    echo "--> Skipping Homebrew installation."
    ;;
esac

## install & activate zplug
prompt_action "Install zplug (ZSH plugin manager)"
case "$REPLY" in
  y|Y)
    echo "--> Installing zplug..."
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    ;;
  c|C)
    echo "--> The command to be run is:"
    echo "curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh"
    echo "--> No other customization options available for this step."
    ;;
  *)
    echo "--> Skipping zplug installation."
    ;;
esac

## clone dotfiles to $HOME/dotfiles
# The script assumes you have already cloned the dotfiles repository.
# If not, you can run this command manually:
# git clone git@github.com:debuggerpk/dotfiles.git ~/dotfiles

## Backup Existing .zshrc, and create a link to ~/dotfiles/.zshrc in $HOME
prompt_action "Link ~/.zshrc to dotfiles"
case "$REPLY" in
  y|Y)
    echo "--> Backing up existing .zshrc and creating symlink..."
    [ -s "${HOME}/.zshrc" ] && mv "${HOME}/.zshrc" "${HOME}/.zshrc.bck"
    ln -s "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"
    ;;
  *)
    echo "--> Skipping .zshrc symlink."
    ;;
esac

## Prepare Development Environment
echo
echo "--- Preparing Development Environment ---"
echo

## install all packages via brew
prompt_action "Install packages from Brewfile"
case "$REPLY" in
  y|Y)
    echo "--> Installing packages from Brewfile..."
    CURRENT_DIR=$(pwd)
    cd "${HOME}/dotfiles" || exit
    brew bundle -v
    cd "${CURRENT_DIR}" || exit
    ;;
  c|C)
    echo "--> Opening Brewfile for customization..."
    ${EDITOR:-vi} "${HOME}/dotfiles/Brewfile"
    echo "--> Press any key to continue with installation after editing, or Ctrl+C to abort."
    read -n 1 -r
    echo "--> Installing packages from (potentially modified) Brewfile..."
    CURRENT_DIR=$(pwd)
    cd "${HOME}/dotfiles" || exit
    brew bundle -v
    cd "${CURRENT_DIR}" || exit
    ;;
  *)
    echo "--> Skipping Brewfile installation."
    ;;
esac

## Python with uv
prompt_action "Install Python with uv"
case "$REPLY" in
  y|Y)
    echo "--> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source "$HOME/.cargo/env" # uv is installed via cargo, so we source this
    ;;
  c|C)
    echo "--> The command to be run is:"
    echo "curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "--> No other customization options available for this step."
    ;;
  *)
    echo "--> Skipping uv installation."
    ;;
esac

## install nvm
prompt_action "Install Node Version Manager (nvm) and latest LTS Node"
case "$REPLY" in
  y|Y)
    echo "--> Installing nvm and Node..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    nvm install --lts --default
    ;;
  c|C)
    echo "--> The command to be run is:"
    echo "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
    echo "nvm install --lts --default"
    echo "--> No other customization options available for this step."
    ;;
  *)
    echo "--> Skipping nvm installation."
    ;;
esac

## Setup GO
prompt_action "Setup Go Environment"
case "$REPLY" in
  y|Y)
    echo "--> Setting up Go environment (GOPATH=$HOME/go)..."
    export GOPATH=$HOME/go
    echo "--> Adding GOPATH to ~/.zshrc if not already present."
    grep -qxF 'export GOPATH=$HOME/go' "${HOME}/.zshrc" || echo 'export GOPATH=$HOME/go' >> "${HOME}/.zshrc"
    ;;
  c|C)
    echo "--> Enter custom GOPATH (default: $HOME/go):"
    read -r CUSTOM_GOPATH
    GOPATH=${CUSTOM_GOPATH:-$HOME/go}
    export GOPATH
    echo "--> Adding GOPATH=$GOPATH to ~/.zshrc if not already present."
    grep -qxF "export GOPATH=$GOPATH" "${HOME}/.zshrc" || echo "export GOPATH=$GOPATH" >> "${HOME}/.zshrc"
    ;;
  *)
    echo "--> Skipping Go environment setup."
    ;;
esac

# install rust
prompt_action "Install Rust via rustup"
case "$REPLY" in
  y|Y)
    echo "--> Installing Rust non-interactively..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Source cargo env to make cargo available in the current shell
    source "$HOME/.cargo/env"
    ;;
  c|C)
    echo "--> To customize, run the following command manually:"
    echo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    echo "--> This will start the interactive installer."
    ;;
  *)
    echo "--> Skipping Rust installation."
    ;;
esac

## Install Cargo Packages
prompt_action "Install Cargo packages from cargo_packages.txt"
CARGO_PACKAGES_FILE="${HOME}/dotfiles/cargo_packages.txt"
case "$REPLY" in
  y|Y)
    echo "--> Installing Cargo packages..."
    if [ -f "$CARGO_PACKAGES_FILE" ]; then
      xargs cargo install < "$CARGO_PACKAGES_FILE"
    else
      echo "--> WARNING: $CARGO_PACKAGES_FILE not found. Skipping."
    fi
    ;;
  c|C)
    echo "--> Opening $CARGO_PACKAGES_FILE for customization..."
    ${EDITOR:-vi} "$CARGO_PACKAGES_FILE"
    echo "--> Press any key to continue with installation after editing, or Ctrl+C to abort."
    read -n 1 -r
    echo "--> Installing packages from (potentially modified) $CARGO_PACKAGES_FILE..."
    if [ -f "$CARGO_PACKAGES_FILE" ]; then
      xargs cargo install < "$CARGO_PACKAGES_FILE"
    else
      echo "--> WARNING: $CARGO_PACKAGES_FILE not found. Skipping."
    fi
    ;;
  *)
    echo "--> Skipping Cargo package installation."
    ;;
esac

## Cloud Development
prompt_action "Install Google Cloud SDK"
case "$REPLY" in
  y|Y)
    echo "--> Installing Google Cloud SDK..."
    brew install --cask google-cloud-sdk
    ;;
  *)
    echo "--> Skipping Google Cloud SDK installation."
    ;;
esac

## install krew (kubectl plugin manager)
prompt_action "Install Kubernetes Krew (Plugin Manager)"
case "$REPLY" in
  y|Y)
    echo "--> Installing Krew..."
    (
      set -x; cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
    )
    ;;
  c|C)
    echo "--> The commands to be run are shown below (with 'set -x'). You can copy and modify them."
    echo "
    (
      set -x; cd \"\$(mktemp -d)\" &&
      OS=\"\$(uname | tr '[:upper:]' '[:lower:]')\" &&
      ARCH=\"\$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\\(arm\\)\\(64\\)\\?.*/\\1\\2/' -e 's/aarch64\$/arm64/')\" &&
      KREW=\"krew-\${OS}_\${ARCH}\" &&
      curl -fsSLO \"https://github.com/kubernetes-sigs/krew/releases/latest/download/\${KREW}.tar.gz\" &&
      tar zxvf \"\${KREW}.tar.gz\" &&
      ./\"\${KREW}\" install krew
    )
    "
    echo "--> No other customization options available for this step."
    ;;
  *)
    echo "--> Skipping Krew installation."
    ;;
esac
