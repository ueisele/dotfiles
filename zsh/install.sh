#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(dirname $0)"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"
BTPL_BIN="${ROOT_DIR}/tool.btpl.sh"
LINK_DOTFILES_BIN="${ROOT_DIR}/tool.link-dotfiles.sh"

function ensure_zsh_requirements_are_installed () {
    log "INFO" "Installing chsh tool for changing user shell"
    ${INSTALL_PACKAGE_BIN} --install "fedora(>=24)=util-linux-user,centos(>=8)=util-linux-user,alpine=shadow"
    if [ "$(current_os)" = "alpine" ] && [ ! -e /etc/pam.d/chsh ]; then
        log "INFO" "Allow passwordless change of user shell, by creating corresponding /etc/pam.d/chsh"
        printf "#%%PAM-1.0\\nauth       sufficient   pam_shells.so" | run_with_sudo_if_required tee -a /etc/pam.d/chsh
    fi
}

function ensure_zsh_is_installed () {
    log "INFO" "Installing ZSH shell"
    ${INSTALL_PACKAGE_BIN} --install \
        "centos(==7)=https://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el7.noarch.rpm"
    ${INSTALL_PACKAGE_BIN} \
        --install-parameter "centos(==7)=--enablerepo=gf-plus" \
        --install zsh
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

function ensure_zsh_is_default_shell () {
    local current_shell="$(grep "^$(id -un)" /etc/passwd | cut -d":" -f7)"
    local expeced_shell="$(command -v zsh)"
    if [ "${current_shell}" != "${expeced_shell}" ]; then
        log "INFO" "Change login shell of $(id -un) from ${current_shell} to ${expeced_shell}"
        chsh -s "${current_shell}"
    fi
}

function ensure_dotfiles_are_templated () {
    log "INFO" "Templating ZSH dotfiles"
	${BTPL_BIN} "${SCRIPT_DIR}/files"
}

function ensure_dotfiles_are_linked () {
    log "INFO" "Linking ZSH dotfiles to ${HOME}"
	${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/files"
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

ensure_zsh_requirements_are_installed
ensure_zsh_is_installed
ensure_prezto_installed
ensure_zsh_is_default_shell
ensure_dotfiles_are_templated
ensure_dotfiles_are_linked