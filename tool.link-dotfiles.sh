#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR})"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh

function link_dotfiles_in_dir () {
    local sourcedir="${1:?Missing source dir as first parameter!}"
    local targetdir="${2:-"${HOME}"}"
    for file in $(find "${sourcedir}" -not -name '*.btpl' -not -type d); do
        link_dotfile "${file}" "${sourcedir}" "${targetdir}"
    done
}

function link_dotfile () {
    local sourcefile="${1:?Missing source file as first parameter!}"
    local sourcedir="${2:-"$(dirname "${sourcefile}")"}"
    local targetdir="${3:-"${HOME}"}"
    local filedir="$(dirname ${file})"
    local relfiledir="$(realpath --relative-to=${sourcedir} ${filedir})"
    mkdir -p "${targetdir}/${relfiledir}"
    local relfile="$(realpath --relative-to=${sourcedir} ${file})"
    if [ -f "${targetdir}/${relfile}" ] && ! [ -h "${targetdir}/${relfile}" ]; then
        mv -bf "${targetdir}/${relfile}" "${targetdir}/${relfile}.orig"
    elif [ -h "${targetdir}/${relfile}" ]; then
        rm -f "${targetdir}/${relfile}"
    fi
    log "INFO" "Creating ${targetdir}/${relfile} as symlink, pointing to $(realpath ${file})"
    ln -sr "$(realpath ${file})" "${targetdir}/${relfile}"
}

function _main () {
    local source="${1:?Missing source as first parameter!}"
    if [ -d "${source}" ]; then
        link_dotfiles_in_dir "$@"
    else
        link_dotfile "$@"
    fi
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    _main "$@"
fi