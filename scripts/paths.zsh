# Add modifications to PATH environment variable

export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  # Add pyenv shims and autocompletion
  eval "$(pyenv init -)"

  # Add auto-activation of virtualenvs
  eval "$(pyenv virtualenv-init -)"

  # Setup virtualenvwrapper commands
  # PS: This also installs virtualenvwrapper if missing
  pyenv virtualenvwrapper_lazy
fi