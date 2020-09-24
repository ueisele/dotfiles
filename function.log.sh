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
    echo "$(date -Isec)|${level}|${msg}"
}
