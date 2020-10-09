#!/usr/bin/env bash

# notes:
# - https://neovim.io/
# - https://github.com/caarlos0/dotfiles/tree/master/vim

set -e
SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"
LINK_DOTFILES_BIN="${ROOT_DIR}/tool.link-dotfiles.sh"

function ensure_neovim_is_installed () {
	${INSTALL_PACKAGE_BIN} --install "centos=epel-release"
	${INSTALL_PACKAGE_BIN} --install make gcc python3 "arch=python-pip,manjaro=python-pip,alpine=py3-pip,python3-pip"
	pip3 install --user pynvim
    ${INSTALL_PACKAGE_BIN} --install neovim
}

function ensure_dotfiles_are_linked () {
	${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/files"
}

function ensure_plugins_are_installed () {
	nvim +'PlugInstall --sync' +qa
	nvim +'PlugUpdate' +qa
}

function link_aliases () {
    ${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/aliases" "${DOTFILES_ALIASES_DIR}"
}

ensure_neovim_is_installed
ensure_dotfiles_are_linked
ensure_plugins_are_installed
link_aliases