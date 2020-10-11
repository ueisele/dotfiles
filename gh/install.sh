#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
LINK_DOTFILES_BIN="${ROOT_DIR}/tool.link-dotfiles.sh"

GITHUB_REPO="cli/cli"

function resolve_github_credentials () {
    if [ -n "${GITHUB_USER}" ] && [ -n "${GITHUB_TOKEN}" ]; then
        echo "-u ${GITHUB_USER}:${GITHUB_TOKEN}"
    fi
}

function resolve_arch_type () {
    if (uname -m | grep -q x86_64); then echo amd64; else uname -m; fi
}

function resolve_os_type () {
    if [[ "$OSTYPE" == "linux"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    else
        echo "$OSTYPE"
    fi
}
function resolve_download_url () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local os_type=${3:-$(resolve_os_type)}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep ${arch_type} | grep ${os_type} | grep "tar.gz"
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
    local os_type=${3:-$(resolve_os_type)}
    local target="${4:-${DOTFILES_APP_DIR}}"
	local targetbin="${5:-${DOTFILES_BIN_DIR}}"
    local targetman="${6:-${DOTFILES_MAN_DIR}}"

    local download_url="$(resolve_download_url ${tag} ${arch_type} ${os_type})"   
    if [ -z "${download_url}" ]; then
        fail 1 "Could not determine an artifact for arch '${arch_type}' and os '${os_type}' with tag '${tag}'."
    fi

    if [ ! -d ${target} ]; then
        log "INFO" "Create ${target} as target directory for binaries"
        create_target_dir "${target}"
    fi
    if [ ! -d ${targetbin} ]; then
        log "INFO" "Create ${targetbin} as target directory for binaries"
        create_target_dir "${targetbin}"
    fi
    if [ ! -d ${targetman} ]; then
        log "INFO" "Create ${targetman} as target directory for man pages"
        create_target_dir "${targetman}"
    fi

    local actual_tag="$(resolve_actual_tag ${tag})"
    local filename_short="gh"
    local filename_full="${filename_short}-${actual_tag}"
    if [ -f "${targetbin}/${filename_full}" ]; then
        log "INFO" "Artifact ${targetbin}/${filename_full} has already been downloaded."
    else
        log "INFO" "Download artifact for arch '${arch_type}' and os '${os_type}' with tag '${actual_tag}' from URL ${download_url}"
        mkdir -p "${target}/${filename_full}"
        curl -sfL "${download_url}" | tar -xz -C "${target}/${filename_full}" --overwrite --strip-components=1
        chown -R $(id -u):$(id -g) "${target}/${filename_full}"
        log "INFO" "Artifact has been downloaded to ${target}/${filename_full}"
    fi

    ln -sf "${target}/${filename_full}/bin/${filename_short}" "${targetbin}/${filename_full}"
	ln -sf "${target}/${filename_full}/bin/${filename_short}" "${targetbin}/${filename_short}"
    log "INFO" "Created symlink from ${target}/${filename_full}/bin/${filename_short} to ${targetbin}/${filename_full} and ${targetbin}/${filename_short}"

    ${LINK_DOTFILES_BIN} "${target}/${filename_full}/share/man" "${targetman}"
    log "INFO" "Linked man pages from ${target}/${filename_full}/share/man to ${targetman}"
}

download "$@"