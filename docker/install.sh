#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(dirname $0)"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
LINK_DOTFILES_BIN="${ROOT_DIR}/tool.link-dotfiles.sh"

function ensure_binfiles_are_linked () {
    log "INFO" "Linking Docker bin files to ${DOTFILES_BIN_DIR}"
	${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/bin" "${DOTFILES_BIN_DIR}"
}

if command -v docker &> /dev/null ; then
    ensure_binfiles_are_linked
fi