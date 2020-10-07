#!/usr/bin/env bash

# notes:
# - https://medium.com/@rajsek/zsh-bash-startup-files-loading-order-bashrc-zshrc-etc-e30045652f2e
# - https://wiki.archlinux.org/index.php/zsh
# - https://wiki.archlinux.org/index.php/Color_output_in_console

set -e
SCRIPT_DIR="$(dirname $0)"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"

function ensure_zsh_is_installed () {
    ${INSTALL_PACKAGE_BIN} zsh
}

function ensure_prezto_installed () {
    if [ ! -d "${HOME}/.zprezto" ]; then
        git clone --recursive --depth 1 --jobs 8 https://github.com/sorin-ionescu/prezto.git "${HOME}/.zprezto"
    else
        (cd "${HOME}/.zprezto" && git pull && git submodule update --init --recursive)
    fi
}

function ensure_zsh_is_default_shell () {
    chsh -s /bin/zsh
}

ensure_zsh_is_installed
ensure_prezto_installed
ensure_zsh_is_default_shell