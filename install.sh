#!/usr/bin/env sh
set -e
SCRIPT_DIR=$(dirname $0)
. ${SCRIPT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN=${SCRIPT_DIR}/tool.install-package.sh
BTPL_BIN=${SCRIPT_DIR}/tool.btpl.sh

ensure_required_tools_are_installed () {
    log "INFO" "Installing required tools with package manager"
    ${INSTALL_PACKAGE_BIN} bash
    ${INSTALL_PACKAGE_BIN} curl
    ${INSTALL_PACKAGE_BIN} git
}

ensure_additional_tools_are_installed () {
    log "INFO" "Installing optional tools with package manager"
    ${INSTALL_PACKAGE_BIN} wget
    ${INSTALL_PACKAGE_BIN} less
    ${INSTALL_PACKAGE_BIN} vim
    ${INSTALL_PACKAGE_BIN} gpg
}

ensure_dotfile_tools_are_installed () {
    for tool in $(find ${SCRIPT_DIR} -regextype posix-extended -regex "^${SCRIPT_DIR}/[^_.][^/]*/install\.sh"); do
        log "INFO" "Installing ${tool}"
        ./${tool}
    done
}

ensure_dotfiles_are_templated () {
    for template in $(find ${SCRIPT_DIR} -regextype posix-extended -regex "^${SCRIPT_DIR}/[^_.][^/]*/files/.*\.btpl"); do
        log "INFO" "Rendering template ${template}"
        ./${BTPL_BIN} "${template}"
    done
}

ensure_dotfiles_are_linked () {
    for filesdir in $(find ${SCRIPT_DIR} -regextype posix-extended -regex "^${SCRIPT_DIR}/[^_.][^/]*/files" -type d); do
        for file in $(find ${filesdir} -not -name '*.btpl' -not -type d); do
            filedir="$(dirname ${file})"
            relfiledir="$(realpath --relative-to=${filesdir} ${filedir})"
            mkdir -p "${HOME}/${relfiledir}"
            relfile="$(realpath --relative-to=${filesdir} ${file})"
            if [ -f "${HOME}/${relfile}" ] && ! [ -h "${HOME}/${relfile}" ]; then
                mv -bf "${HOME}/${relfile}" "~/${relfile}.orig"
            elif [ -h "${HOME}/${relfile}" ]; then
                rm -f "${HOME}/${relfile}"
            fi
            log "INFO" "Creating  ${HOME}/${relfile} as symlink, pointing to $(realpath ${file})"
            ln -sr "$(realpath ${file})" "${HOME}/${relfile}"
        done
    done
}

ensure_required_tools_are_installed
ensure_additional_tools_are_installed
ensure_dotfile_tools_are_installed
ensure_dotfiles_are_templated
ensure_dotfiles_are_linked