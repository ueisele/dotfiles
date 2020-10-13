#!/usr/bin/env bash

export DOTFILES_DIR="$(readlink -f "$(dirname ${BASH_SOURCE[0]})")"
export DOTFILES_STORE_DIR="${DOTFILES_DIR}/.store"
export DOTFILES_BIN_DIR="${DOTFILES_STORE_DIR}/bin"
export DOTFILES_CONFIG_DIR="${DOTFILES_STORE_DIR}/etc"
export DOTFILES_COMPLETIONS_ZSH_DIR="${DOTFILES_CONFIG_DIR}/completions/zsh"
export DOTFILES_ALIASES_DIR="${DOTFILES_CONFIG_DIR}/aliases"
export DOTFILES_KEYBINDINGS_ZSH_DIR="${DOTFILES_CONFIG_DIR}/keybindings/zsh"
export DOTFILES_APP_DIR="${DOTFILES_STORE_DIR}/opt"
export DOTFILES_SHARE_DIR="${DOTFILES_STORE_DIR}/share"
export DOTFILES_MAN_DIR="${DOTFILES_SHARE_DIR}/man"

export INSTALL_PACKAGE_BIN="${DOTFILES_DIR}/tool.install-package.sh"
export LINK_DOTFILES_BIN="${DOTFILES_DIR}/tool.link-dotfiles.sh"
export BTPL_BIN="${ROOT_DIR}/tool.btpl.sh"