#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh

GITHUB_REPO="sharkdp/bat"

function download_and_install () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local os_type=${3:-$(resolve_os_type)}

    local download_url="$(resolve_download_url ${tag} ${arch_type} ${os_type})"   
    if [ -z "${download_url}" ]; then
        fail 1 "Could not determine an artifact for arch '${arch_type}' and os '${os_type}' with tag '${tag}'."
    fi

    local actual_tag="$(resolve_actual_tag ${tag})"
    local name_short="bat"
    local name_full="${name_short}-${actual_tag}"

    if [ -f "${DOTFILES_APP_DIR}/${name_full}/${name_short}" ]; then
        log "INFO" "Artifact ${name_full} has already been downloaded."
    else
        log "INFO" "Download artifact for arch '${arch_type}' and os '${os_type}' with tag '${actual_tag}' from URL ${download_url}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}"
        curl -sfL "${download_url}" | tar -xz -C "${DOTFILES_APP_DIR}/${name_full}" --overwrite --strip-components=1
        chown -R $(id -u):$(id -g) "${DOTFILES_APP_DIR}/${name_full}"
        log "INFO" "Artifact has been downloaded to ${DOTFILES_APP_DIR}/${name_full}"
    fi

    mkdir -p "${DOTFILES_BIN_DIR}"
	ln -srf "${DOTFILES_APP_DIR}/${name_full}/${name_short}" "${DOTFILES_BIN_DIR}/${name_short}"
    log "INFO" "Linked binary from ${DOTFILES_APP_DIR}/${name_full}/${name_short} to ${DOTFILES_BIN_DIR}/${name_short}"

    mkdir -p "${DOTFILES_MAN_DIR}/man1"
    ln -srf "${DOTFILES_APP_DIR}/${name_full}/${name_short}.1" "${DOTFILES_MAN_DIR}/man1"
    log "INFO" "Linked man page from ${DOTFILES_APP_DIR}/${name_full}/${name_short}.1 to ${DOTFILES_MAN_DIR}/man1/${name_short}.1"

    mkdir -p "${DOTFILES_COMPLETIONS_ZSH_DIR}"
    ln -srf  "${DOTFILES_APP_DIR}/${name_full}/autocomplete/${name_short}.zsh" "${DOTFILES_COMPLETIONS_ZSH_DIR}/_${name_short}"
    log "INFO" "Linked ZSH auto completion from ${DOTFILES_APP_DIR}/${name_full}/autocomplete/${name_short}.zsh to ${DOTFILES_COMPLETIONS_ZSH_DIR}/_${name_short}"
}

function resolve_arch_type () {
    uname -m
}

function resolve_os_type () {
    if [[ "$OSTYPE" == "linux"* ]]; then
        echo "linux-$(resolve_libc_type)"
    else
        echo "$OSTYPE"
    fi
}

function resolve_libc_type () { 
    if (ldd $(command -v sh) | grep -q -i musl); then echo musl; else echo gnu; fi
}

function resolve_download_url () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local os_type=${3:-$(resolve_os_type)}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep ${arch_type} | grep ${os_type}
}

function resolve_actual_tag () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

function resolve_github_credentials () {
    if [ -n "${GITHUB_USER}" ] && [ -n "${GITHUB_TOKEN}" ]; then
        echo "-u ${GITHUB_USER}:${GITHUB_TOKEN}"
    fi
}

download_and_install "$@"