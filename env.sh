#!/usr/bin/env bash

export DOTFILES_DIR="$(readlink -f "$(dirname ${BASH_SOURCE[0]})")"
export DOTFILES_STORE_DIR="${DOTFILES_DIR}/.store"
export DOTFILES_BIN_DIR="${DOTFILES_STORE_DIR}/bin"