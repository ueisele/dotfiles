#!/usr/bin/env bash

## dotfile dirs 
export DOTFILES_DIR="$(readlink -f "$(dirname ${BASH_SOURCE[0]})")"
export DOTFILES_STORE_DIR="${DOTFILES_DIR}/.store"
# /bin
export DOTFILES_BIN_DIR="${DOTFILES_STORE_DIR}/bin"
# /etc
export DOTFILES_ETC_DIR="${DOTFILES_STORE_DIR}/etc"
export DOTFILES_ETC_ZSH_DIR="${DOTFILES_ETC_DIR}/zsh"
export DOTFILES_ETC_ZSH_COMPLETION_DIR="${DOTFILES_ETC_ZSH_DIR}/completion.d"
export DOTFILES_ETC_ZSH_ALIAS_DIR="${DOTFILES_ETC_ZSH_DIR}/alias.d"
export DOTFILES_ETC_ZSH_KEYBINDING_DIR="${DOTFILES_ETC_ZSH_DIR}/keybinding.d"
# /opt
export DOTFILES_APP_DIR="${DOTFILES_STORE_DIR}/opt"
# /share
export DOTFILES_SHARE_DIR="${DOTFILES_STORE_DIR}/share"
export DOTFILES_MAN_DIR="${DOTFILES_SHARE_DIR}/man"

## dotfile tools
export INSTALL_PACKAGE_BIN="${DOTFILES_DIR}/tool.install-package.sh"
export LINK_FILES_BIN="${DOTFILES_DIR}/tool.link-files.sh"
export TEMPLATE_BTPL_BIN="${DOTFILES_DIR}/tool.template-btpl.sh"