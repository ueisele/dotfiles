#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh

GITHUB_REPO="cli/cli"

RETRIES=3

function ensure_downloaded_and_installed_from_github () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local os_type=${3:-$(resolve_os_type)}

    local download_url="$(resolve_download_url ${tag} ${arch_type} ${os_type})"   
    if [ -z "${download_url}" ]; then
        fail 1 "Could not determine an artifact for arch '${arch_type}' and os '${os_type}' with tag '${tag}'."
    fi

    local actual_tag="$(resolve_actual_tag ${tag})"
    local name_short="gh"
    local name_full="${name_short}-${actual_tag}"

    if [ -f "${DOTFILES_APP_DIR}/${name_full}/download.timestamp" ]; then
        log "INFO" "Artifact ${name_full} has already been downloaded."
    else
        log "INFO" "Download artifact for arch '${arch_type}' and os '${os_type}' with tag '${actual_tag}' from URL ${download_url}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}"
        curl -sfL --retry ${RETRIES} "${download_url}" | tar -xz -C "${DOTFILES_APP_DIR}/${name_full}" --overwrite --strip-components=1
        chown -R $(id -u):$(id -g) "${DOTFILES_APP_DIR}/${name_full}"
        log "INFO" "Artifact has been downloaded to ${DOTFILES_APP_DIR}/${name_full}"

        log "INFO" "Generating Zsh completion script with 'gh completion -s zsh'"
        ${DOTFILES_APP_DIR}/${name_full}/bin/${name_short} completion -s zsh > "${DOTFILES_APP_DIR}/${name_full}/completion.zsh"
        log "INFO" "Saved Zsh completion script to ${DOTFILES_APP_DIR}/${name_full}/completion.zsh"

        echo "$(date -Isec)" > "${DOTFILES_APP_DIR}/${name_full}/download.timestamp"
    fi

    mkdir -p "${DOTFILES_BIN_DIR}"
	ln -srf "${DOTFILES_APP_DIR}/${name_full}/bin/${name_short}" "${DOTFILES_BIN_DIR}/${name_short}"
    log "INFO" "Linked binary from ${DOTFILES_APP_DIR}/${name_full}/bin/${name_short} to ${DOTFILES_BIN_DIR}/${name_short}"

    mkdir -p "${DOTFILES_MAN_DIR}"
    ${LINK_DOTFILES_BIN} "${DOTFILES_APP_DIR}/${name_full}/share/man" "${DOTFILES_MAN_DIR}"
    log "INFO" "Linked man pages from ${DOTFILES_APP_DIR}/${name_full}/share/man to ${DOTFILES_MAN_DIR}"

    mkdir -p "${DOTFILES_COMPLETIONS_ZSH_DIR}"
    ln -srf  "${DOTFILES_APP_DIR}/${name_full}/completion.zsh" "${DOTFILES_COMPLETIONS_ZSH_DIR}/_${name_short}"
    log "INFO" "Linked ZSH auto completion from ${DOTFILES_APP_DIR}/${name_full}/completion.zsh to ${DOTFILES_COMPLETIONS_ZSH_DIR}/_${name_short}"
}

function resolve_arch_type () {
    if (uname -m | grep -q x86_64); then echo amd64; else uname -m; fi
}

function resolve_os_type () {
    if [[ "$OSTYPE" == "linux"* ]]; then
        echo "linux"
    else
        echo "$OSTYPE"
    fi
}
function resolve_download_url () {
    local tag=${1:-"latest"}
    local arch_type=${2:-$(resolve_arch_type)}
    local os_type=${3:-$(resolve_os_type)}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL --retry ${RETRIES} https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep ${arch_type} | grep ${os_type} | grep "tar.gz"
}

function resolve_actual_tag () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL --retry ${RETRIES} https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

function resolve_github_credentials () {
    if [ -n "${GITHUB_USER}" ] && [ -n "${GITHUB_TOKEN}" ]; then
        echo "-u ${GITHUB_USER}:${GITHUB_TOKEN}"
    fi
}

if [ "$(current_os)" != "alpine" ]; then
    ensure_downloaded_and_installed_from_github "$@"
else
    log "INFO" "Skipping installation of gh, because gh is not available for Alpine"
fi