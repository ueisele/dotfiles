#!/usr/bin/env sh

fail () {
    local exitcode="${1:?'Missing exit code as first parameter!'}"
    local msg="${2:?'Missing messages as second parameter!'}"
    log "ERROR" "${msg}"
    exit ${exitcode}
}

log () {
    local level="${1:?'Missing log level as first parameter!'}"
    local msg="${2:?'Missing log level as second parameter!'}"
    echo "$(date -Isec)|$(caller)|${level}|${msg}"
}

caller () {
    if [ -n "${DOTFILES_DIR}" ]; then
        local escaped_dotfiles_dir="$(echo "${DOTFILES_DIR}" | sed 's/\//\\\//g' )"
        echo "$(realpath $0 | sed "s/${escaped_dotfiles_dir}\///g")"
    else
        echo "$(basename $0)"
    fi
}