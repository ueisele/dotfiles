#!/usr/bin/env bash
set -e
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
SCRIPT_DIR=$(pwd)
ROOT_DIR=$(readlink -f ${SCRIPT_DIR}/..)
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
popd > /dev/null