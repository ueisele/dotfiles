#!/usr/bin/env sh
set -e
SCRIPT_DIR=$(dirname $0)
. ${SCRIPT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN=${SCRIPT_DIR}/tool.install-package.sh

ensure_package_database_is_updated () {
    ${INSTALL_PACKAGE_BIN} --update
}

ensure_required_tools_are_installed () {
    log "INFO" "Installing required tools with package manager"
    ${INSTALL_PACKAGE_BIN} --install bash curl git tar unzip findutils
}

ensure_additional_tools_are_installed () {
    log "INFO" "Installing optional tools with package manager"
    ${INSTALL_PACKAGE_BIN} --install centos=epel-release
    ${INSTALL_PACKAGE_BIN} --install wget less htop ubuntu=gpg,fedora=gnupg2,gnupg
    ${INSTALL_PACKAGE_BIN} --install ubuntu=silversearcher-ag,the_silver_searcher --install-parameter centos=--enablerepo=epel-testing
}

ensure_dotfile_tools_are_installed () {
    for tool in $(find ${SCRIPT_DIR} -regextype posix-extended -regex "^${SCRIPT_DIR}/[^_.][^/]*/install\.sh"); do
        log "INFO" "Installing ${tool}"
        ./${tool}
    done
}

ensure_package_database_is_cleaned () {
    ${INSTALL_PACKAGE_BIN} --clean
}

ensure_package_database_is_updated
ensure_required_tools_are_installed
ensure_additional_tools_are_installed
ensure_dotfile_tools_are_installed
ensure_package_database_is_cleaned