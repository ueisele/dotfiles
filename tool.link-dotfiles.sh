#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
ROOT_DIR=${SCRIPT_DIR}
source ${ROOT_DIR}/env.sh
source ${SCRIPT_DIR}/function.log.sh

function link_dotfiles_in_dir () {
    local sourcedir="${1:?Missing source dir as first parameter!}"
    local targetdir="${2:-${HOME}}"
    for file in $(find ${sourcedir} -not -name '*.btpl' -not -type d); do
        filedir="$(dirname ${file})"
        relfiledir="$(realpath --relative-to=${sourcedir} ${filedir})"
        mkdir -p "${targetdir}/${relfiledir}"
        relfile="$(realpath --relative-to=${sourcedir} ${file})"
        if [ -f "${targetdir}/${relfile}" ] && ! [ -h "${targetdir}/${relfile}" ]; then
            mv -bf "${targetdir}/${relfile}" "${targetdir}/${relfile}.orig"
        elif [ -h "${targetdir}/${relfile}" ]; then
            rm -f "${targetdir}/${relfile}"
        fi
        log "INFO" "Creating  ${targetdir}/${relfile} as symlink, pointing to $(realpath ${file})"
        ln -sr "$(realpath ${file})" "${targetdir}/${relfile}"
    done
}

link_dotfiles_in_dir "$@"