#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh

function ensure_binfiles_are_linked () {
    log "INFO" "Linking Docker bin files to ${DOTFILES_BIN_DIR}"
    mkdir -p "${DOTFILES_BIN_DIR}"
	${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/bin" "${DOTFILES_BIN_DIR}"
}

if command -v docker &> /dev/null ; then
    ensure_binfiles_are_linked
else
    log "INFO" "Skipping Docker configuration, because docker command is missing"
fi