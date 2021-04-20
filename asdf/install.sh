#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh

function ensure_asdf_is_installed () {
    if [ ! -d "${HOME}/.asdf" ]; then
        log "INFO" "Cloning asdf GitHub Repository to ${HOME}/.asdf"
        git clone https://github.com/asdf-vm/asdf.git "${HOME}/.asdf"
    else
        log "INFO" "Updating asdf GitHub Repository in ${HOME}/.asdf"
        (cd "${HOME}/.asdf" && bin/asdf update)
    fi
    (cd "${HOME}/.asdf" && git checkout "$(git describe --abbrev=0 --tags)")

    mkdir -p "${DOTFILES_ETC_ZSH_COMPLETION_DIR}"
    ln -srf  "${HOME}/.asdf/completions/_asdf" "${DOTFILES_ETC_ZSH_COMPLETION_DIR}/_asdf"
    log "INFO" "Linked ZSH auto completion from ${HOME}/.asdf/completions/_asdf to ${DOTFILES_ETC_ZSH_COMPLETION_DIR}/_asdf"
}

ensure_asdf_is_installed