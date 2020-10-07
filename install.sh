#!/usr/bin/env sh
set -e
SCRIPT_DIR=$(dirname $0)
. ${SCRIPT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN=${SCRIPT_DIR}/tool.install-package.sh

ensure_required_tools_are_installed () {
    log "INFO" "Installing required tools with package manager"
    ${INSTALL_PACKAGE_BIN} bash
    ${INSTALL_PACKAGE_BIN} curl
    ${INSTALL_PACKAGE_BIN} git
    ${INSTALL_PACKAGE_BIN} tar
    ${INSTALL_PACKAGE_BIN} unzip
}

ensure_additional_tools_are_installed () {
    log "INFO" "Installing optional tools with package manager"
    ${INSTALL_PACKAGE_BIN} wget
    ${INSTALL_PACKAGE_BIN} less
    ${INSTALL_PACKAGE_BIN} gpg
}

ensure_dotfile_tools_are_installed () {
    for tool in $(find ${SCRIPT_DIR} -regextype posix-extended -regex "^${SCRIPT_DIR}/[^_.][^/]*/install\.sh"); do
        log "INFO" "Installing ${tool}"
        ./${tool}
    done
}

ensure_required_tools_are_installed
ensure_additional_tools_are_installed
ensure_dotfile_tools_are_installed