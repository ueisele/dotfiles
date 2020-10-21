#
# Configures direnv
#

# Return if requirements are not found
if (( ! $+commands[direnv] )); then
    return 1
fi

eval "$(direnv hook zsh)"