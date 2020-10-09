#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(dirname $0)"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh

GITHUB_REPO="stedolan/jq"

function resolve_github_credentials () {
    if [ -n "${GITHUB_USER}" ] && [ -n "${GITHUB_TOKEN}" ]; then
        echo "-u ${GITHUB_USER}:${GITHUB_TOKEN}"
    fi
}

function resolve_arch_type () {
    if (uname -m | grep -q x86_64); then echo 64; else uname -m; fi
}

function resolve_download_url () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep linux | grep ${arch_type}
}

function resolve_actual_tag () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

function create_target_dir () {
    local target="${1:?Missing target dir as first parameter!}"
    mkdir -p "${target}"
}

function download () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local target="${3:-${DOTFILES_BIN_DIR}}"

    local download_url="$(resolve_download_url ${tag} ${arch_type})"   
    if [ -z "${download_url}" ]; then
        fail 1 "Could not determine an artifact for arch '${arch_type}' with tag '${tag}'."
    fi

    if [ ! -d ${target} ]; then
        log "INFO" "Create ${target} as target directory for binaries"
        create_target_dir "${target}"
    fi

    local actual_tag="$(resolve_actual_tag ${tag})"
    local filename_short="jq"
    local filename_full="${filename_short}-${actual_tag}"
    if [ -f "${target}/${filename_full}" ]; then
        log "INFO" "Artifact ${target}/${filename_full} has already been downloaded."
    else
        log "INFO" "Download artifact for arch '${arch_type}' with tag '${actual_tag}' from URL ${download_url}" 
        curl -sfLR -o "${target}/${filename_full}" "${download_url}"
        chmod +x "${target}/${filename_full}"
        log "INFO" "Artifact has been downloaded to ${target}/${filename_full}"
    fi

    ln -sf "${target}/${filename_full}" "${target}/${filename_short}"
    log "INFO" "Created symlink from ${target}/${filename_full} to ${target}/${filename_short}"
}

download "$@"