#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(dirname $0)"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
LINK_DOTFILES_BIN="${ROOT_DIR}/tool.link-dotfiles.sh"

GITHUB_REPO="ogham/exa"

# notes:
# - https://github.com/ogham/exa

function resolve_arch_type () {
    uname -m
}

function resolve_os_type () {
    if [[ "$OSTYPE" == "linux"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "$OSTYPE"
    fi
}

function resolve_download_url () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local os_type=${3:-$(resolve_os_type)}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl -sL https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep ${arch_type} | grep ${os_type}
}

function resolve_actual_tag () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl -sL https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

function create_target_dir () {
    local target="${1:?Missing target dir as first parameter!}"
    mkdir -p "${target}"
}

function download () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local os_type=${3:-$(resolve_os_type)}
    local target="${4:-${DOTFILES_BIN_DIR}}"

    local download_url="$(resolve_download_url ${tag} ${arch_type} ${os_type})"   
    if [ -z "${download_url}" ]; then
        fail 1 "Could not determine an artifact for arch '${arch_type}' and os '${os_type}' with tag '${tag}'."
    fi

    if [ ! -d ${target} ]; then
        log "INFO" "Create ${target} as target directory for binaries"
        create_target_dir "${target}"
    fi

    local actual_tag="$(resolve_actual_tag ${tag})"
    local filename_short="exa"
    local filename_full="${filename_short}-${actual_tag}"
    if [ -f "${target}/${filename_full}" ]; then
        log "INFO" "Artifact ${target}/${filename_full} has already been downloaded."
    else
        log "INFO" "Download artifact for arch '${arch_type}' and os '${os_type}' with tag '${actual_tag}' from URL ${download_url}"
        local tmpfile="$(mktemp)"
        curl -sfLR -o "${tmpfile}" "${download_url}"
        unzip -o -d "${target}" "${tmpfile}"
        rm "${tmpfile}"
        mv -f "${target}/${filename_short}-${os_type}-${arch_type}" "${target}/${filename_full}"        
        log "INFO" "Artifact has been downloaded to ${target}/${filename_full}"

        mkdir -p "${DOTFILES_COMPLETIONS_ZSH_DIR}"
        curl -sfLR -o "${DOTFILES_COMPLETIONS_ZSH_DIR}/_${filename_short}" "https://raw.githubusercontent.com/${GITHUB_REPO}/${actual_tag}/contrib/completions.zsh"
        log "INFO" "Created ZSH auto completion file ${DOTFILES_COMPLETIONS_ZSH_DIR}/_${filename_short}"
    fi

    ln -sf "${target}/${filename_full}" "${target}/${filename_short}"
    log "INFO" "Created symlink from ${target}/${filename_full} to ${target}/${filename_short}"
}

function link_aliases () {
    ${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/aliases" "${DOTFILES_ALIASES_DIR}"
}

download "$@"
link_aliases