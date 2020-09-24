#!/usr/bin/env sh
set -e

render_templates_todir () {
    local templatedir="${1:?"Missing template dir as first parameter!"}"
    for template in $(find -H "${templatedir}" -maxdepth 4 -name '*.btpl' -not -path '*.git*'); do
        local outdir="${2:-"$(dirname ${template})"}"
        render_template_tofile "${template}" "${outdir}"
    done
}

render_template_tofile () {
    local template="${1:?"Missing template file path as first parameter!"}"
    local outdir="${2:-"$(dirname ${template})"}"
    local outfile="${outdir}/$(basename ${template%.*})"
    render_template "$1" > "$outfile" 
}

render_template () {
    local template="${1:?"Missing template file path as first parameter!"}"
    eval "cat <<EOF
`cat ${template}`
EOF"
}
