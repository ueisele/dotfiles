#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR})"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh

render_templates_indir_tofile () {
    local sourcedir="${1:?"Missing template file path as first parameter!"}"
    local outdir="${2:-"${sourcedir}"}"
    for template in $(find "${sourcedir}" -regextype posix-extended -regex ".*\.btpl"); do
        render_template_tofile "${template}" "${outdir}"
    done
}

function render_template_tofile () {
    local template="${1:?"Missing template file path as first parameter!"}"
    local outdir="${2:-"$(dirname ${template})"}"
    local outfile="${outdir}/$(basename ${template%.*})"
    log "INFO" "Rendering template ${template}"
    render_template "$1" > "$outfile" 
}

function render_template () {
    local template="${1:?"Missing template file path as first parameter!"}"
    eval "cat <<EOF
`cat ${template}`
EOF"
}

function _main () {
    local template="${1:?"Missing template path as first parameter!"}"
    if [ -d "${template}" ]; then
        render_templates_indir_tofile "$@"
    else
        render_template_tofile "$@"
    fi
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    _main "$@"
fi
