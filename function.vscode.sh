#!/usr/bin/env sh

is_devcontainer () {
    is_remotecontainer || is_codespaces
}

is_remotecontainer () {
    [ "${REMOTE_CONTAINERS}" = "true" ]
}

is_codespaces () {
    [ "${CODESPACES}" = "true" ]
}