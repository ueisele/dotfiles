#!/usr/bin/env bash

# notes:
# - https://medium.com/@rajsek/zsh-bash-startup-files-loading-order-bashrc-zshrc-etc-e30045652f2e
# - https://wiki.archlinux.org/index.php/zsh
# - https://wiki.archlinux.org/index.php/Color_output_in_console
# - https://getantibody.github.io/install/

set -e
SCRIPT_DIR=$(dirname $0)
source ${SCRIPT_DIR}/../function.log.sh
INSTALL_PACKAGE_BIN=${SCRIPT_DIR}/../tool.install-package.sh

function ensure_zsh_is_installed () {
    ${INSTALL_PACKAGE_BIN} zsh
}

function ensure_antibody_is_installed () {
    curl -sfL git.io/antibody | sh -s - -b /usr/local/bin
}

ensure_zsh_is_installed