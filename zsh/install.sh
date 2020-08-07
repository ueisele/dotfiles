#!/usr/bin/env bash
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