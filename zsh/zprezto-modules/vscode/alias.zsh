#
# Defines Visual Studio Code aliases.
#

if ! zstyle -t ':prezto:module:vscode:alias' skip 'yes'; then

    if [[ $(which code-insiders) && ! $(which code) ]]; then alias code=code-insiders; fi

fi