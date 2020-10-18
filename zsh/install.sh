#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh

function ensure_zsh_is_installed () {
    log "INFO" "Installing ZSH shell"
    ${INSTALL_PACKAGE_BIN} --install \
        "centos(==7)=https://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el7.noarch.rpm"
    ${INSTALL_PACKAGE_BIN} \
        --install-parameter "centos(==7)=--enablerepo=gf-plus" \
        --install zsh "alpine=zsh-doc"
}

function ensure_prezto_installed () {
    if [ ! -d "${HOME}/.zprezto" ]; then
        log "INFO" "Cloning Prezto GitHub Repository to ${HOME}/.zprezto"
        git clone --recursive --depth 1 $(jobs_if_possible 8) https://github.com/sorin-ionescu/prezto.git "${HOME}/.zprezto"
    else
        log "INFO" "Updating Prezto GitHub Repository in ${HOME}/.zprezto"
        (cd "${HOME}/.zprezto" && git pull && git submodule update --init --recursive)
    fi
}

function ensure_dotfiles_are_templated () {
    log "INFO" "Templating ZSH dotfiles"
	${TEMPLATE_BTPL_BIN} "${SCRIPT_DIR}/files"
}

function ensure_dotfiles_are_linked () {
    log "INFO" "Linking ZSH dotfiles to ${HOME}"
	${LINK_FILES_BIN} "${SCRIPT_DIR}/files"
}

function jobs_if_possible () {
    local job_count=${1:-1}

    local expeced_smallest_git_version="2.9.5"
    local git_version="$(git --version | sed 's/git version \([0-9.]\+\)/\1/')"
    
    local lowest_version="$(echo -e "${expeced_smallest_git_version}\\n${git_version}" | sort -V | head -n1)"

    if [ "${git_version}" != "${lowest_version}" ] || [ "${git_version}" == "${expeced_smallest_git_version}" ]; then
        echo "--jobs ${job_count}"
    fi
}

ensure_zsh_is_installed
ensure_prezto_installed
ensure_dotfiles_are_templated
ensure_dotfiles_are_linked