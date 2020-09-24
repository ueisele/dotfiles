#
# Provides Visual Studio Code aliases and functions.
#

# Return if requirements are not found.
if (( ! $+commands[code] )) && (( ! $+commands[code-insiders] )); then
  return 1
fi

# Source module files.
source "${0:h}/alias.zsh"