#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
ROOT_DIR="${SCRIPT_DIR}"

export DOTFILES_DIR="$(readlink -f "${ROOT_DIR}")"
export DOTFILES_STORE_DIR="${DOTFILES_DIR}/.store"
export DOTFILES_BIN_DIR="${DOTFILES_STORE_DIR}/bin"