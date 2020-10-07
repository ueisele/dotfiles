#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
ROOT_DIR=${SCRIPT_DIR}
source ${ROOT_DIR}/env.sh

function render_template_tofile () {
    local template="${1:?"Missing template file path as first parameter!"}"
    local outdir="${2:-"$(dirname ${template})"}"
    local outfile="${outdir}/$(basename ${template%.*})"
    render_template "$1" > "$outfile" 
}

function render_template () {
    local template="${1:?"Missing template file path as first parameter!"}"
    eval "cat <<EOF
`cat ${template}`
EOF"
}

render_template_tofile "$@"