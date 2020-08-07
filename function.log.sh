#!/usr/bin/env sh

function fail () {
    local exitcode="${1:?'Missing exit code as first parameter!'}"
    local msg="${@:?'Missing log level as first parameter!'}"
    log "ERROR" "${msg}"
    exit ${exitcode}
}

function log () {
    local level="${1:?'Missing log level as first parameter!'}"
    local msg="${@:?'Missing log level as first parameter!'}"
    echo "$(date -Isec)|${level}|${msg}"
}
