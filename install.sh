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
    ${INSTALL_PACKAGE_BIN} --install \
        "centos(==6)=http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm" \
        "centos(==7)=https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.8-1.x86_64.rpm" \
        git
    ${INSTALL_PACKAGE_BIN} --install bash curl tar unzip findutils "arch=inetutils,manjaro=inetutils,alpine=net-tools,hostname"
}

ensure_additional_tools_are_installed () {
    log "INFO" "Installing optional tools with package manager"
    ${INSTALL_PACKAGE_BIN} --install wget less "ubuntu=gpg,fedora=gnupg2,centos=gnupg2,gnupg"
    ${INSTALL_PACKAGE_BIN} --install "centos=epel-release" htop
    ${INSTALL_PACKAGE_BIN} --install "ubuntu=silversearcher-ag,the_silver_searcher" --install-parameter "centos(>=8)=--enablerepo=epel-testing"
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