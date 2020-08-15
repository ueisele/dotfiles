#!/usr/bin/env bash
set -e
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
SCRIPT_DIR=$(pwd)
ROOT_DIR=${SCRIPT_DIR}
popd > /dev/null

export DOTFILES_STORE_DIR=${ROOT_DIR}/.store
export DOTFILES_BIN_DIR=${DOTFILES_STORE_DIR}/bin
