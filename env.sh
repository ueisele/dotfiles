#!/usr/bin/env bash
set -e
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
SCRIPT_DIR=$(pwd)
popd > /dev/null

export DOTFILES_BIN_DIR=$(readlink -f ${SCRIPT_DIR}/bin)
