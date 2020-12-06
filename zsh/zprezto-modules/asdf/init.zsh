#
# Configures asdf
#

# Return if requirements are not found
if [ ! -f "${HOME}/.asdf/asdf.sh" ]; then
    return 1
fi

# Init asdf
source "${HOME}/.asdf/asdf.sh"

# Init specific asdf plugins
if [[ -f "${HOME}/.asdf/plugins/java/set-java-home.zsh" ]]; then
    source "${HOME}/.asdf/plugins/java/set-java-home.zsh"
fi