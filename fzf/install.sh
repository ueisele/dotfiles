#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh

GITHUB_REPO_BIN="junegunn/fzf-bin"
GITHUB_REPO_SUPPLEMENT="junegunn/fzf"

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
    local name_short="fzf"
    local name_full="${name_short}-${actual_tag}"

    if [ -f "${DOTFILES_APP_DIR}/${name_full}/download.timestamp" ]; then
        log "INFO" "Artifact ${name_full} has already been downloaded."
    else
        log "INFO" "Download release for arch '${arch_type}' and os '${os_type}' with tag '${actual_tag}' from URL ${download_url}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}"
        curl -sfL --retry ${RETRIES} "${download_url}" | tar -xz -C "${DOTFILES_APP_DIR}/${name_full}" --overwrite
        chown -R $(id -u):$(id -g) "${DOTFILES_APP_DIR}/${name_full}"
        log "INFO" "Release has been downloaded to ${DOTFILES_APP_DIR}/${name_full}"

        log "INFO" "Download wrapper script for tmux for tag ${actual_tag}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}"
        download_github_raw_content "${GITHUB_REPO_SUPPLEMENT}" "${actual_tag}" "bin" "${DOTFILES_APP_DIR}/${name_full}" "${name_short}-tmux" "+x"

        log "INFO" "Download man pages for tag ${actual_tag}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}/man"
        download_github_raw_content "${GITHUB_REPO_SUPPLEMENT}" "${actual_tag}" "man/man1" "${DOTFILES_APP_DIR}/${name_full}/man" "${name_short}.1"
        download_github_raw_content "${GITHUB_REPO_SUPPLEMENT}" "${actual_tag}" "man/man1" "${DOTFILES_APP_DIR}/${name_full}/man" "${name_short}-tmux.1"

        log "INFO" "Download Zsh Key-Bindings for tag ${actual_tag}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}"
        download_github_raw_content "${GITHUB_REPO_SUPPLEMENT}" "${actual_tag}" "shell" "${DOTFILES_APP_DIR}/${name_full}" "key-bindings.zsh"

        echo "$(date -Isec)" > "${DOTFILES_APP_DIR}/${name_full}/download.timestamp"
    fi

    mkdir -p "${DOTFILES_BIN_DIR}"
	ln -srf "${DOTFILES_APP_DIR}/${name_full}/${name_short}" "${DOTFILES_BIN_DIR}/${name_short}"
	ln -srf "${DOTFILES_APP_DIR}/${name_full}/${name_short}-tmux" "${DOTFILES_BIN_DIR}/${name_short}-tmux"
    log "INFO" "Linked binaries from ${DOTFILES_APP_DIR}/${name_full} to ${DOTFILES_BIN_DIR}/${name_short} and ${DOTFILES_BIN_DIR}/${name_short}-tmux"

    mkdir -p "${DOTFILES_MAN_DIR}/man1"
    ln -srf "${DOTFILES_APP_DIR}/${name_full}/man/${name_short}.1" "${DOTFILES_MAN_DIR}/man1/${name_short}.1"
    ln -srf "${DOTFILES_APP_DIR}/${name_full}/man/${name_short}-tmux.1" "${DOTFILES_MAN_DIR}/man1/${name_short}-tmux.1"
    log "INFO" "Linked man pages from ${DOTFILES_APP_DIR}/${name_full}/man to ${DOTFILES_MAN_DIR}/man1"

    mkdir -p "${DOTFILES_KEYBINDINGS_ZSH_DIR}"
    ln -srf "${DOTFILES_APP_DIR}/${name_full}/key-bindings.zsh" "${DOTFILES_KEYBINDINGS_ZSH_DIR}/fzf.zsh"
    log "INFO" "Linked Zsh Key-Bindings from ${DOTFILES_APP_DIR}/${name_full}/key-bindings.zsh to ${DOTFILES_KEYBINDINGS_ZSH_DIR}/fzf.zsh"
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
    
    curl $(resolve_github_credentials) -sL --retry ${RETRIES} https://api.github.com/repos/${GITHUB_REPO_BIN}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep ${arch_type} | grep ${os_type}
}

function resolve_actual_tag () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL --retry ${RETRIES} https://api.github.com/repos/${GITHUB_REPO_BIN}/releases/${query} | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

function download_github_raw_content () {
    local repo="${1:?Requires GitHub repo as first parameter!}"
    local tag="${2:?Requires tag as second parameter!}"
    local sourcedir="${3:?Requires source dir as third parameter!}"
    local targetdir="${4:?Requires target dir as fourth parameter!}"
    local file="${5:?Requires file as fith parameter!}"
    local mod="${6:-""}"
    curl -sfLR --retry ${RETRIES} -o "${targetdir}/${file}" "https://raw.githubusercontent.com/${repo}/${tag}/${sourcedir}/${file}"
    if [ -n "${mod}" ]; then
        chmod "${mod}" "${targetdir}/${file}"
    fi
    log "INFO" "Downloaded ${sourcedir}/${file} from GitHub Repo ${repo}:${tag} to ${targetdir}/${file}"
}

function resolve_github_credentials () {
    if [ -n "${GITHUB_USER}" ] && [ -n "${GITHUB_TOKEN}" ]; then
        echo "-u ${GITHUB_USER}:${GITHUB_TOKEN}"
    fi
}

ensure_downloaded_and_installed_from_github "$@"