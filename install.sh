#!/bin/bash

CURRENT_DIR=`dirname -- "$( readlink -f -- "$0"; )"`
cd "$CURRENT_DIR" || exit 1

# ensure brew is on PATH when script is run from .zshrc after a pull
if ! command -v brew >/dev/null 2>&1; then
  if [ "$(uname)" = "Darwin" ] && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# create local env files
touch $CURRENT_DIR/.config/dotfiles/.env-local
touch $CURRENT_DIR/.config/dotfiles/.env-op-service-account

# create local bin folder in case it doesn't exist
mkdir -p $HOME/.local/bin

# install homebrew if we don't have it yet
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ "$(uname)" == "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# gotta do stow and git-crypt early so files are in their final locations
brew install stow git-crypt
stow . -t "$HOME"

source $HOME/.config/dotfiles/.env

if [ "$(uname)" == "Darwin" ]; then
  brew install 1password-cli gnupg
else
  # linux: op is vendored at .bin/op (x86-64) since 1password-cli is a mac-only cask
  brew install gnupg
fi

# skip 1Password/gpg/ssh/git-crypt when run after a pull (op session not available in that context)
if [ -z "$DOTFILES_AFTER_PULL" ]; then
  # set up gpg key password caching and import gpg key
  export GPG_TTY=$(tty)
  source $HOME/.config/dotfiles/.gpg
  op read op://secrets/gpg/private.key | gpg --import --batch --pinentry-mode loopback --passphrase-file <(op read op://secrets/gpg/password)

  # install ssh key
  mkdir -p $HOME/.ssh
  op read op://secrets/ssh/private_key > $HOME/.ssh/id_ed25519
  chmod 600 $HOME/.ssh/id_ed25519

  # git-crypt should be ready to go now
  git-crypt unlock
fi

# install oh-my-zsh if we don't have it yet
if [ ! -d $HOME/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # oh-my-zsh probably moved our .zshrc, let's put it back.
  rm -f $HOME/.zshrc $HOME/.zshrc.pre-oh-my-zsh
  stow . -t $HOME
fi

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# install powerlevel10k
[ -d "$ZSH_CUSTOM_DIR/themes/powerlevel10k" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM_DIR/themes/powerlevel10k"

# install zsh-autosuggestions
[ -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"

# install fzf-tab
[ -d "$ZSH_CUSTOM_DIR/plugins/fzf-tab" ] || git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM_DIR/plugins/fzf-tab"

# install tailscale if we don't have it yet
command -v tailscale >/dev/null 2>&1 || curl -fsSL https://tailscale.com/install.sh | sh

# install rust if we don't have it yet (rustup drops $HOME/.cargo/env when done)
[ -f $HOME/.cargo/env ] || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
[ -f $HOME/.cargo/env ] && source $HOME/.cargo/env # ensure cargo is available for the rest of the install script

# install packages from homebrew
brew install \
  tmux thefuck lsd deno llvm \
  golang highlight jq fzf gh bat \
  fd ripgrep volta delta yt-dlp

# oh-my-tmux
[ -d $HOME/.oh-my-tmux ] || git clone --single-branch https://github.com/gpakosz/.tmux.git $HOME/.oh-my-tmux
mkdir -p $HOME/.config/tmux
ln -s -f $HOME/.oh-my-tmux/.tmux.conf $HOME/.config/tmux/tmux.conf

if [ "$(uname)" == "Darwin" ]; then
  brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font
fi

# set up go folders
mkdir -p $HOME/.go/{bin,src,pkg}
