#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

#-------------------------------------------------------------------------------
# Phase 0: State Variables & Helper Functions
#
# We'll use these variables to keep track of what the user wants to do.
#-------------------------------------------------------------------------------

# --- Actions to perform ---
SETUP_GIT=0
GENERATE_SSH=0
INSTALL_HOMEBREW=0
INSTALL_ZPLUG=0
CLONE_DOTFILES="" # ssh or https
LINK_ZSHRC=0
INSTALL_BREW_PACKAGES=0
INSTALL_NVM=0
SETUP_GO=0
INSTALL_RUST=0
INSTALL_CARGO_PACKAGES=0
INSTALL_UV=0
INSTALL_GCLOUD=0
INSTALL_KREW=0

# --- Helper for asking questions ---
# Sets a variable to 1 (true) if the user agrees.
ask() {
    local prompt="$1"
    local var_name="$2"
    echo "--------------------------------------------------"
    echo "ACTION: $prompt"
    echo "--------------------------------------------------"
    echo "--> Do you want to proceed? (y)es, (n)o"
    read -n 1 -r REPLY
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        eval "$var_name=1"
    fi
}

#-------------------------------------------------------------------------------
# Phase 1: Define Install Functions
#
# Each of these functions performs a single, specific task.
#-------------------------------------------------------------------------------

generate_ssh_key() {
    echo "--> Generating a new SSH key..."
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        echo "--> SSH key already exists at ~/.ssh/id_ed25519. Skipping generation."
        return
    fi

    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N ""
    echo "--> SSH key generated."

    # Start the ssh-agent in the background and add the key
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add ~/.ssh/id_ed25519

    if command -v pbcopy >/dev/null 2>&1; then
        pbcopy < ~/.ssh/id_ed25519.pub
        echo "--> Public key copied to clipboard."
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard < ~/.ssh/id_ed25519.pub
        echo "--> Public key copied to clipboard."
    else
        echo "--> Please copy the following public key to your clipboard:"
        cat ~/.ssh/id_ed25519.pub
    fi

    echo "--> Opening GitHub to add your new SSH key..."
    if command -v open >/dev/null 2>&1; then
      open "https://github.com/settings/keys"
    elif command -v xdg-open >/dev/null 2>&1; then
      xdg-open "https://github.com/settings/keys"
    else
      echo "--> Could not automatically open browser. Please navigate to https://github.com/settings/keys"
    fi
    echo "--> Press any key to continue after adding the key to GitHub."
    read -n 1 -r
}

install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        echo "--> Homebrew is already installed. Skipping."
    else
        echo "--> Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Detect and set the correct Homebrew path
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        # Intel Mac / Linux
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "--> WARNING: Homebrew not found in expected locations. You may need to add it to your PATH manually."
    fi
}

install_zplug() {
    echo "--> Installing zplug..."
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
}

clone_dotfiles() {
    if [ -d "${HOME}/dotfiles" ]; then
        echo "--> ~/dotfiles directory already exists. Skipping clone."
        return
    fi
    if [ "$CLONE_DOTFILES" = "ssh" ]; then
        echo "--> Cloning dotfiles via SSH..."
        git clone git@github.com:debuggerpk/dotfiles.git "${HOME}/dotfiles"
    elif [ "$CLONE_DOTFILES" = "https" ]; then
        echo "--> Cloning dotfiles via HTTPS..."
        git clone https://github.com/debuggerpk/dotfiles.git "${HOME}/dotfiles"
    fi
}

link_zshrc() {
    echo "--> Backing up existing .zshrc and creating symlink..."
    [ -s "${HOME}/.zshrc" ] && mv "${HOME}/.zshrc" "${HOME}/.zshrc.bck"
    ln -s "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"
}

install_brew_packages() {
    echo "--> Installing packages from Brewfile..."
    brew bundle --file="${HOME}/dotfiles/Brewfile" -v
}

install_nvm() {
    echo "--> Installing nvm and latest LTS Node..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    nvm install --lts --default
}

setup_go_env() {
    echo "--> Setting up Go environment (GOPATH=$HOME/go)..."
    export GOPATH=$HOME/go
    grep -qxF 'export GOPATH=$HOME/go' "${HOME}/.zshrc" || echo 'export GOPATH=$HOME/go' >> "${HOME}/.zshrc"
}

install_rust() {
    echo "--> Installing Rust non-interactively..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
}

install_cargo_packages() {
    local packages_file="${HOME}/dotfiles/cargo_packages.txt"
    echo "--> Installing Cargo packages from $packages_file..."
    if [ -f "$packages_file" ]; then
        while read -r package || [[ -n "$package" ]]; do
            # Skip empty lines
            [ -z "$package" ] && continue
            echo "--> Installing cargo package: $package"
            cargo install "$package"
        done < "$packages_file"
    else
        echo "--> WARNING: $packages_file not found. Skipping."
    fi
}

install_uv() {
    echo "--> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_gcloud() {
    echo "--> Installing Google Cloud SDK..."
    brew install --cask google-cloud-sdk
}

install_krew() {
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
}


#-------------------------------------------------------------------------------
# Phase 2: Ask All Questions
#
# Gather all user input before performing any actions.
#-------------------------------------------------------------------------------
ask_all_questions() {
    echo "--- Git Configuration ---"
    echo "--> Enter your Git username:"
    read -r GIT_USERNAME
    echo "--> Enter your Git email:"
    read -r GIT_EMAIL

    ask "Generate a new SSH key for Git" GENERATE_SSH
    ask "Install Homebrew (package manager)" INSTALL_HOMEBREW
    ask "Install zplug (ZSH plugin manager)" INSTALL_ZPLUG

    echo "--------------------------------------------------"
    echo "ACTION: Clone dotfiles repository"
    echo "--------------------------------------------------"
    echo "--> How do you want to clone? (s)sh, (h)ttps, (any other key to skip)"
    read -n 1 -r REPLY
    echo
    case "$REPLY" in
      s|S) CLONE_DOTFILES="ssh" ;;
      h|H) CLONE_DOTFILES="https" ;;
    esac

    ask "Link ~/.zshrc to dotfiles" LINK_ZSHRC
    ask "Install packages from Brewfile" INSTALL_BREW_PACKAGES
    ask "Install nvm and latest LTS Node" INSTALL_NVM
    ask "Setup Go Environment" SETUP_GO
    ask "Install Rust via rustup" INSTALL_RUST
    ask "Install packages from cargo_packages.txt" INSTALL_CARGO_PACKAGES
    ask "Install Python toolchain with uv" INSTALL_UV
    ask "Install Google Cloud SDK" INSTALL_GCLOUD
    ask "Install Kubernetes Krew" INSTALL_KREW
}

#-------------------------------------------------------------------------------
# Phase 3: Confirm and Execute
#
# Show the user what will happen and get final confirmation.
#-------------------------------------------------------------------------------
confirm_and_execute() {
    echo
    echo "=================================================="
    echo "            Configuration Summary"
    echo "=================================================="
    echo "Git User: $GIT_USERNAME"
    echo "Git Email: $GIT_EMAIL"
    echo
    echo "ACTIONS TO BE PERFORMED:"
    [ $GENERATE_SSH -eq 1 ] && echo "  - Generate new SSH key"
    [ $INSTALL_HOMEBREW -eq 1 ] && echo "  - Install Homebrew"
    [ $INSTALL_ZPLUG -eq 1 ] && echo "  - Install zplug"
    [ -n "$CLONE_DOTFILES" ] && echo "  - Clone dotfiles repository (via $CLONE_DOTFILES)"
    [ $LINK_ZSHRC -eq 1 ] && echo "  - Link ~/.zshrc"
    [ $INSTALL_BREW_PACKAGES -eq 1 ] && echo "  - Install Homebrew packages"
    [ $INSTALL_NVM -eq 1 ] && echo "  - Install nvm and Node.js"
    [ $SETUP_GO -eq 1 ] && echo "  - Set up Go environment"
    [ $INSTALL_RUST -eq 1 ] && echo "  - Install Rust"
    [ $INSTALL_CARGO_PACKAGES -eq 1 ] && echo "  - Install Cargo packages"
    [ $INSTALL_UV -eq 1 ] && echo "  - Install uv"
    [ $INSTALL_GCLOUD -eq 1 ] && echo "  - Install Google Cloud SDK"
    [ $INSTALL_KREW -eq 1 ] && echo "  - Install Krew for kubectl"
    echo "=================================================="

    echo "--> Proceed with the execution? (y/n)"
    read -n 1 -r REPLY
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted by user."
        exit 1
    fi

    # Execute all selected actions
    echo "--> Starting setup..."
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"

    [ $GENERATE_SSH -eq 1 ] && generate_ssh_key
    [ $INSTALL_HOMEBREW -eq 1 ] && install_homebrew
    [ $INSTALL_ZPLUG -eq 1 ] && install_zplug
    [ -n "$CLONE_DOTFILES" ] && clone_dotfiles
    [ $LINK_ZSHRC -eq 1 ] && link_zshrc
    [ $INSTALL_BREW_PACKAGES -eq 1 ] && install_brew_packages
    [ $INSTALL_NVM -eq 1 ] && install_nvm
    [ $SETUP_GO -eq 1 ] && setup_go_env
    [ $INSTALL_RUST -eq 1 ] && install_rust
    [ $INSTALL_CARGO_PACKAGES -eq 1 ] && install_cargo_packages
    [ $INSTALL_UV -eq 1 ] && install_uv
    [ $INSTALL_GCLOUD -eq 1 ] && install_gcloud
    [ $INSTALL_KREW -eq 1 ] && install_krew

    echo "--------------------------------------------------"
    echo "✅ Setup complete!"
    echo "Please restart your shell or run 'source ~/.zshrc' for all changes to take effect."
    echo "--------------------------------------------------"
}

#-------------------------------------------------------------------------------
# Main Execution
#-------------------------------------------------------------------------------
main() {
    ask_all_questions
    confirm_and_execute
}

main
