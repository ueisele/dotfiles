#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(dirname $0)"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
. ${ROOT_DIR}/env.sh
. ${ROOT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"

function ensure_bash_is_installed () {
    ${INSTALL_PACKAGE_BIN} bash
}

function ensure_bashcompletion_is_installed () {
    ${INSTALL_PACKAGE_BIN} bash-completion
}

function backup_original_bash_dotfiles () {
    if [ -f ~/.bashrc ] && ! [ -h ~/.bashrc ]; then
        cp -f -b ~/.bashrc ~/.bashrc.orig
    fi
    if [ -f ~/.bash_aliases ] && ! [ -h ~/.bash_aliases ]; then
        cp -f -b ~/.bash_aliases ~/.bash_aliases.orig
    fi 
    if [ -f ~/.bash_logout ] && ! [ -h ~/.bash_logout ]; then
        cp -f -b ~/.bash_logout ~/.bash_logout.orig
    fi
    if [ -f ~/.profile ] && ! [ -h ~/.profile ]; then
        cp -f -b ~/.profile ~/.profile.orig
    fi 
}

ensure_bash_is_installed
ensure_bashcompletion_is_installed
backup_original_bash_dotfiles