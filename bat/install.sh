#!/usr/bin/env bash
set -e
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
SCRIPT_DIR=$(pwd)
ROOT_DIR=$(readlink -f ${SCRIPT_DIR}/..)
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
popd > /dev/null

BAT_GITHUB_REPO="sharkdp/bat"

# notes:
# - https://github.com/sharkdp/bat
# - https://github.com/eth-p/bat-extras
# - https://github.com/dandavison/delta
# - https://github.com/burntsushi/ripgrep

function resolve_arch_type () {
    uname -m
}

function resolve_libc_type () { 
    if (ldd --version | grep -i musl); then echo musl; else echo gnu; fi
}

function resolve_download_url () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local libc_type=${3:-$(resolve_libc_type)}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl -sL https://api.github.com/repos/${BAT_GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep ${arch_type} | grep ${libc_type}
}

function resolve_actual_tag () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl -sL https://api.github.com/repos/${BAT_GITHUB_REPO}/releases/${query} | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

function create_target_dir () {
    local target="${1:?Missing target dir as first parameter!}"
    mkdir -p "${target}"
}

function download () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local libc_type=${3:-$(resolve_libc_type)}
    local target="${4:-${DOTFILES_BIN_DIR}}"

    local download_url="$(resolve_download_url ${tag} ${arch_type} ${libc_type})"   
    if [ -z "${download_url}" ]; then
        fail 1 "Could not determine an artifact for arch '${arch_type}' and libc '${libc_type}' with tag '${tag}'."
    fi

    if [ ! -d ${target} ]; then
        log "INFO" "Create ${target} as target directory for binaries"
        create_target_dir "${target}"
    fi

    local actual_tag="$(resolve_actual_tag ${tag})"
    local filename_short="bat"
    local filename_full="${filename_short}-${actual_tag}"
    if [ -f "${target}/${filename_full}" ]; then
        log "Artifact ${target}/${filename_full} has already been downloaded."
    else
        log "INFO" "Download artifact for arch '${arch_type}' and libc '${libc_type}' with tag '${actual_tag}' from URL ${download_url}" 
        #wget "${download_url}"" -qO - | tar -xz -C "${target}" --overwrite --strip-components=1 --wildcards "*/bat"
        curl -sfL "${download_url}" | tar -xz -C "${target}" --overwrite --strip-components=1 --wildcards "*/${filename_short}"
        mv -f "${target}/${filename_short}" "${target}/${filename_full}"
        log "INFO" "Artifact has been downloaded to ${target}/${filename_full}"
    fi

    ln -sf "${target}/${filename_full}" "${target}/${filename_short}"
    log "INFO" "Created symlink from ${target}/${filename_full} to ${target}/${filename_short}"
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    download "$@"
fi