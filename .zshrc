export DOTFILES_DIR="$HOME/.config/dotfiles"

# create local env files if they don't exist
touch $DOTFILES_DIR/.env-local
touch $DOTFILES_DIR/.env-op-service-account

# create local bin folder in case it doesn't exist
mkdir -p $HOME/.local/bin

source $DOTFILES_DIR/.env-op-service-account # op service account env file, sourced at the top so we can ensure we're already logged in
source $DOTFILES_DIR/.check-internet # check if we have internet before we do anything
source $DOTFILES_DIR/.update-dotfiles # update from git if needed

# if we updated, we need to exit and restart the shell to pull the latest changes
if [ -n "$UPDATED_DOTFILES" ]; then
  echo "----------------------------------------"
  echo "Dotfiles updated, restarting shell to pull the latest changes."
  echo "----------------------------------------"
  exec $SHELL
fi

source $DOTFILES_DIR/.env # we need PATH set early

if [ -z "$NO_INTERNET" ]; then
  source $DOTFILES_DIR/.gpg # source the gpg file early, it handles 1password login
  source $DOTFILES_DIR/.ssh # ensure our SSH key is loaded locally
else
  echo "----------------------------------------"
  echo "No internet, skipping 1Password login and gpg passphrase caching. Expect things to be broken!"
  echo "----------------------------------------"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

fpath+=~/.zfunc

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

# Powerlevel 9k Settings
DEFAULT_USER=$DEFAULT_USER

# dir options
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_with_package_name"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  fzf-tab
  git
  common-aliases
  tmux
  zsh-autosuggestions
)

# User configuration
source $DOTFILES_DIR/.env-local # local env file
source $DOTFILES_DIR/.dockeraliases # aliases to programs I want to run within docker
source $DOTFILES_DIR/.aliases # lots of aliases I use
source $DOTFILES_DIR/.swoosh # just a Nike swoosh lol

eval $(thefuck --alias) # this loads thefuck (https://github.com/nvbn/thefuck)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# load NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit .p10k.zsh.
[[ ! -f $DOTFILES_DIR/.p10k.zsh ]] || source $DOTFILES_DIR/.p10k.zsh

# set up nix
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi

# fzf
[ -f $DOTFILES_DIR/.fzf.zsh ] && source $DOTFILES_DIR/.fzf.zsh


source $DOTFILES_DIR/.env-secret # source the private env file last because it might depend on things
