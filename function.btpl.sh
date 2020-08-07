#!/usr/bin/env bash
set -e
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
source env.sh
popd > /dev/null

function render_templates_todir () {
    local templatedir=${1:?"Missing template dir as first parameter!"}
    for template in $(find -H "${templatedir}" -maxdepth 4 -name '*.btpl' -not -path '*.git*'); do
        echo "$(dirname ${template})/generated"
    done
}

function render_template_tofile () {
    local template=${1:?"Missing template file path as first parameter!"}
    local outdir=${2:-$(dirname ${template})}
    local outfile="${outdir}/$(basename ${template%.*})"
    render_template "$1" > "$outfile" 
}

function render_template () {
    local template=${1:?"Missing template file path as first parameter!"}
    eval "cat <<EOF
`cat ${template}`
EOF"
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    render_template_tofile "$@"
fi