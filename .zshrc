# ensure that gdate is available for timing
export PATH="/usr/local/bin:$PATH"

# start timing the prompt boot
local _start=`gdate +%s%3N`
DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"
ZSH_CUSTOM=$HOME/.omz-custom
source $HOME/.local_zshrc

source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
  echo "Creating a zgen save"
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-completions src
  zgen save
fi

fasd_cache="$HOME/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

# generic shell stuff
[[ -s $HOME/.aliases ]] && source $HOME/.aliases
[[ -s $HOME/.env ]] && source $HOME/.env
[[ -s $HOME/.functions ]] && source $HOME/.functions

# tmuxinator: I'll be back
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

# thefuck
command -v thefuck >&/dev/null && eval $(thefuck --alias oops)

# rbenv
command -v rbenv >& /dev/null && eval "$(rbenv init -)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*" --glob "!_build/*" --glob "!deps/*" --glob "!.DS_Store" --glob "!public/*" --glob "!log/*" --glob "!tmp/*" --glob "!vendor/*" --glob "!.git-crypt/*" --glob "!.vagrant/*"'

# # direnv
command -v direnv >& /dev/null && eval "$(direnv hook zsh)"

# bind up and down arrows to search through history
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# custom low level zsh prompt
autoload -Uz vcs_info
# autoload -U colors && colors
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git*' formats "%{$fg[green]%}(%b) %{$reset_color%}%m%u%c%{$reset_color%}"
precmd() {
  vcs_info
}
setopt prompt_subst
PROMPT='%/ ${vcs_info_msg_0_}
$ '

export PATH="$HOME/.cargo/bin:$PATH"

# finish timing the prompt boot
local _end=`gdate +%s%3N`
ruby -e "puts ($_end.to_i - $_start.to_i).to_s + 'ms to prompt'"

# neovim if possible
if command -v nvim > /dev/null; then
  export EDITOR=nvim
  alias vim=nvim
  alias vi=nvim
else
  export EDITOR=vim
fi
