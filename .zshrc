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
  git
  common-aliases
  tmux
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration
source $HOME/.dotfiles/.dockeraliases # aliases to programs I want to run within docker
source $HOME/.dotfiles/.env # environment variables I need to have set
source $HOME/.dotfiles/.env-secret # same as above, but private and not stored in git
source $HOME/.dotfiles/.aliases # lots of aliases I use
source $HOME/.dotfiles/.swoosh # just a Nike swoosh lol

eval $(thefuck --alias) # this loads thefuck (https://github.com/nvbn/thefuck)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# To customize prompt, run `p10k configure` or edit .p10k.zsh.
[[ ! -f $HOME/.dotfiles/.p10k.zsh ]] || source $HOME/.dotfiles/.p10k.zsh
