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
BTPL_BIN="${ROOT_DIR}/tool.btpl.sh"
LINK_DOTFILES_BIN="${ROOT_DIR}/tool.link-dotfiles.sh"

function ensure_zsh_is_installed () {
    ${INSTALL_PACKAGE_BIN} --install "fedora=util-linux-user,centos(>=8)=util-linux-user"
    ${INSTALL_PACKAGE_BIN} --install \
        "centos(==7)=https://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el7.noarch.rpm"
    ${INSTALL_PACKAGE_BIN} \
        --install-parameter "centos(==7)=--enablerepo=gf-plus" \
        --install zsh
}

function ensure_prezto_installed () {
    if [ ! -d "${HOME}/.zprezto" ]; then
        git clone --recursive --depth 1 --jobs 8 https://github.com/sorin-ionescu/prezto.git "${HOME}/.zprezto"
    else
        (cd "${HOME}/.zprezto" && git pull && git submodule update --init --recursive)
    fi
}

function ensure_zsh_is_default_shell () {
    chsh -s $(command -v zsh)
}

function ensure_dotfiles_are_templated () {
	${BTPL_BIN} "${SCRIPT_DIR}/files"
}

function ensure_dotfiles_are_linked () {
	${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/files"
}

ensure_zsh_is_installed
ensure_prezto_installed
ensure_zsh_is_default_shell
ensure_dotfiles_are_templated
ensure_dotfiles_are_linked