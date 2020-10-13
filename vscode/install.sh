#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh

function ensure_aliases_are_linked () {
    log "INFO" "Linking VS Code alias files to ${DOTFILES_ETC_ZSH_ALIAS_DIR}"
    mkdir -p "${DOTFILES_ETC_ZSH_ALIAS_DIR}"
    ${LINK_FILES_BIN} "${SCRIPT_DIR}/alias" "${DOTFILES_ETC_ZSH_ALIAS_DIR}"
}

ensure_aliases_are_linked