#
# Configures direnv
#

# Return if requirements are not found
if [ ! -f "${HOME}/.asdf/asdf.sh" ]; then
    return 1
fi

source "${HOME}/.asdf/asdf.sh"