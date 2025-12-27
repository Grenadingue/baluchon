command_exists()
{
    command -v $1 >/dev/null 2>&1
}

# Autoenv github.com/kennethreitz/autoenv
if [ -f /usr/share/autoenv-git/activate.sh ]; then
  . /usr/share/autoenv-git/activate.sh
fi

# Node version manager
if [ -f /usr/share/nvm/init-nvm.sh ]; then
  source /usr/share/nvm/init-nvm.sh
fi

# Ruby rbenv
if command_exists rbenv; then
  user_rbenv_path="$HOME/.rbenv/bin"
  if [ -d ${user_rbenv_path} ]; then
    export PATH="$PATH:$HOME/.rbenv/bin"
  fi
  eval "$(rbenv init -)"
fi

# Ruby RVM
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    ## Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
    export PATH="$PATH:$HOME/.rvm/bin"
    ## Load RVM into a shell session *as a function*
    source "$HOME/.rvm/scripts/rvm"
    ## Load autocompetion
    [[ -r "$HOME/.rvm/scripts/completion" ]] && source "$HOME/.rvm/scripts/completion"
fi

# Archlinux pacman like package manager wrapper
# Try to enable pacapt as pacman if we're not on Arch
if [ -f ~/.baluchon.d/pacapt-enabler.bash ]; then
  . ~/.baluchon.d/pacapt-enabler.bash
fi

# Load bash git auto-completion script
if [ -f /usr/share/git/completion/git-completion.bash ]; then
  . /usr/share/git/completion/git-completion.bash
fi

# The fuck
if command_exists thefuck; then
  eval $(thefuck --alias) &
fi

# Flutter
if command_exists flutter && command_exists chromium; then
  export CHROME_EXECUTABLE="$(which chromium)"
fi

# Pacman AUR wrapper
if command_exists yay; then
  alias yay='yay --answerdiff All --sudoloop'
fi

# Export default editor
if command_exists emacs; then
  export EDITOR='emacs -nw'
elif command_exists vim; then
  export EDITOR='vim'
elif command_exists vi; then
  export EDITOR='vi'
fi

# Fuzzy Finding
if command_exists fzf; then
  . /usr/share/fzf/key-bindings.bash
  . /usr/share/fzf/completion.bash
fi
