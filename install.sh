#!/usr/bin/env sh
set -e
SCRIPT_DIR="$(readlink -f $(dirname $0))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR})"
. ${ROOT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"

ensure_package_database_is_updated () {
    ${INSTALL_PACKAGE_BIN} --update
}

ensure_required_tools_are_installed () {
    log "INFO" "Installing required tools with package manager"
    ${INSTALL_PACKAGE_BIN} --install "debian=apt-utils,ubuntu=apt-utils"
    ${INSTALL_PACKAGE_BIN} --install \
        "centos(==6)=http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm" \
        "centos(==7)=https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.8-1.x86_64.rpm" \
        git "alpine=git-doc"
    ${INSTALL_PACKAGE_BIN} --install \
        bash "alpine=bash-doc" curl "alpine=curl-doc" tar "alpine=tar-doc" unzip "alpine=unzip-doc" findutils "alpine=findutils-doc" \
        "arch=inetutils,manjaro=inetutils,alpine=net-tools,hostname" "alpine=net-tools-doc" \
        "alpine=coreutils" "alpine=coreutils-doc" "alpine=util-linux" "alpine=util-linux-doc"
}

ensure_additional_tools_are_installed () {
    log "INFO" "Installing optional tools with package manager"
    ${INSTALL_PACKAGE_BIN} --install \
        wget "alpine=wget-doc" less "alpine=less-doc" \
        "debian=ldnsutils,ubuntu=ldnsutils,fedora=ldns-utils,centos=ldns,arch=ldns,manjaro=ldns,alpine=drill" "alpine=ldns-doc" \
        "ubuntu=gpg,fedora=gnupg2,centos=gnupg2,gnupg" "alpine=gnupg-doc" \
        "debian=exuberant-ctags,ubuntu=exuberant-ctags,ctags" "alpine=ctags-doc"
    ${INSTALL_PACKAGE_BIN} --install "centos=epel-release" htop "alpine=htop-doc"
    ${INSTALL_PACKAGE_BIN} \
        --install-parameter "centos(>=8)=--enablerepo=epel-testing" \
        --install "debian=silversearcher-ag,ubuntu=silversearcher-ag,the_silver_searcher" "alpine=the_silver_searcher-doc"
    ${INSTALL_PACKAGE_BIN} --install-parameter "alpine=-X http://dl-cdn.alpinelinux.org/alpine/edge/testing" --install xsel "alpine=xsel-doc"
}

ensure_dotfile_tools_are_installed () {
    for tool in $(find ${ROOT_DIR} -regextype posix-extended -regex "^${ROOT_DIR}/[^_.][^/]*/install\.sh"); do
        log "INFO" "Installing ${tool}"
        ${tool}
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