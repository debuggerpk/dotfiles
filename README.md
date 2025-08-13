# dotfiles

Personal dotfiles by [debuggerpk](https://github.com/debuggerpk), intended as a reference for a modern development setup.

## Quick Install

To get started, you can run the setup script. This will clone the repository and symlink the `.zshrc` file.

**Warning:** The script will back up your existing `.zshrc` to `.zshrc.bck`.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/debuggerpk/dotfiles/master/setup.sh)"
```

## What's Included?

These dotfiles configure your shell environment with a curated set of tools and plugins for a productive development workflow. The recent updates have streamlined the startup process by removing unnecessary output and improving environment variable settings.

### Core Components
- **Shell:** [Zsh](https://www.zsh.org/) as the primary shell.
- **Plugin Manager:** [zplug](https://github.com/zplug/zplug) for managing Zsh plugins.
- **Prompt:** [Starship](https://starship.rs/) for a minimal, fast, and infinitely customizable prompt.
- **Navigation:** [zoxide](https://github.com/ajeetdsouza/zoxide), a smarter `cd` command that learns your habits.
- **File Listing:** [lsd](https://github.com/lsd-rs/lsd) as a modern replacement for `ls` with icons and colors.

### Language Environments
The `.zshrc` file comes pre-configured for managing multiple versions of popular programming languages:
- **Go:** Sets up `GOPATH` and a dynamic `GOROOT` using `brew`.
- **Node.js:** Integrated with [NVM](https://github.com/nvm-sh/nvm) for version management.
- **Python:** Integrated with [pyenv](https://github.com/pyenv/pyenv) and `pyenv-virtualenv`.
- **Bun:** Support for the [Bun](https://bun.sh/) runtime.

### Tools & Integrations
- **Kubernetes:** `krew` plugin manager path is configured.
- **Google Cloud SDK:** Completions are automatically sourced.
- **Terraform:** Completions are enabled.
- **Neovim:** `vi` and `vim` are aliased to `nvim`.

## Prerequisites

- **[Homebrew](https://brew.sh/):** Required for installing most of the tools and for the dynamic Go setup to work correctly.
- **`zsh`:** Needs to be your default shell.
- **`git`:** Required for cloning the repository.