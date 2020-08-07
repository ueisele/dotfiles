#!/usr/bin/env sh
set -e
SCRIPT_DIR=$(dirname $0)
source ${SCRIPT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN=${SCRIPT_DIR}/tool.install-package.sh

function ensure_required_tools_are_installed () {
    ${INSTALL_PACKAGE_BIN} curl
    ${INSTALL_PACKAGE_BIN} less
    ${INSTALL_PACKAGE_BIN} git
    ${INSTALL_PACKAGE_BIN} bash
}

function try_optional_tools_are_installed () {
    ${INSTALL_PACKAGE_BIN} man || true
    ${INSTALL_PACKAGE_BIN} wget || true
}

ensure_required_tools_are_installed
try_optional_tools_are_installed