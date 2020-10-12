#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh

GITHUB_REPO="ogham/exa"

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
    local name_short="exa"
    local name_full="${name_short}-${actual_tag}"

    if [ -f "${DOTFILES_APP_DIR}/${name_full}/download.timestamp" ]; then
        log "INFO" "Artifact ${name_full} has already been downloaded."
    else
        log "INFO" "Download artifact for arch '${arch_type}' and os '${os_type}' with tag '${actual_tag}' from URL ${download_url}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}"
        local tmpfile="$(mktemp)"
        curl -sfLR --retry ${RETRIES} -o "${tmpfile}" "${download_url}"
        unzip -o -d "${DOTFILES_APP_DIR}/${name_full}" "${tmpfile}"
        rm "${tmpfile}"
        mv -f "${DOTFILES_APP_DIR}/${name_full}/${name_short}-${os_type}-${arch_type}" "${DOTFILES_APP_DIR}/${name_full}/${name_short}"        
        log "INFO" "Artifact has been downloaded to ${DOTFILES_APP_DIR}/${name_full}"

        log "INFO" "Download man page for tag ${actual_tag}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}/man"
        download_github_raw_content "${GITHUB_REPO}" "${actual_tag}" "contrib/man" "${DOTFILES_APP_DIR}/${name_full}/man" "${name_short}.1"

        log "INFO" "Download ZSH autocompletion for tag ${actual_tag}"
        mkdir -p "${DOTFILES_APP_DIR}/${name_full}"
        download_github_raw_content "${GITHUB_REPO}" "${actual_tag}" "contrib" "${DOTFILES_APP_DIR}/${name_full}" "completions.zsh"

        echo "$(date -Isec)" > "${DOTFILES_APP_DIR}/${name_full}/download.timestamp"
    fi

    mkdir -p "${DOTFILES_BIN_DIR}"
	ln -srf "${DOTFILES_APP_DIR}/${name_full}/${name_short}" "${DOTFILES_BIN_DIR}/${name_short}"
    log "INFO" "Linked binary from ${DOTFILES_APP_DIR}/${name_full}/${name_short} to ${DOTFILES_BIN_DIR}/${name_short}"

    mkdir -p "${DOTFILES_MAN_DIR}/man1"
    ln -srf "${DOTFILES_APP_DIR}/${name_full}/man/${name_short}.1" "${DOTFILES_MAN_DIR}/man1"
    log "INFO" "Linked man page from ${DOTFILES_APP_DIR}/${name_full}/man/${name_short}.1 to ${DOTFILES_MAN_DIR}/man1/${name_short}.1"

    mkdir -p "${DOTFILES_COMPLETIONS_ZSH_DIR}"
    ln -srf  "${DOTFILES_APP_DIR}/${name_full}/completions.zsh" "${DOTFILES_COMPLETIONS_ZSH_DIR}/_${name_short}"
    log "INFO" "Linked ZSH auto completion from ${DOTFILES_APP_DIR}/${name_full}/completions.zsh to ${DOTFILES_COMPLETIONS_ZSH_DIR}/_${name_short}"
}

function ensure_installed_as_package () {
	${INSTALL_PACKAGE_BIN} --install "alpine(>=3.11.0)=exa" "alpine(>=3.11.0)=exa-doc"
}

function ensure_aliases_are_linked () {
    mkdir -p "${DOTFILES_ALIASES_DIR}"
    ${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/aliases" "${DOTFILES_ALIASES_DIR}"
}

function resolve_arch_type () {
    uname -m
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
    
    curl $(resolve_github_credentials) -sL --retry ${RETRIES} https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep ${arch_type} | grep ${os_type}
}

function resolve_actual_tag () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL --retry ${RETRIES} https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
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

if [ "$(current_os)" != "alpine" ]; then
    ensure_downloaded_and_installed_from_github "$@"
    ensure_aliases_are_linked
elif compare_version "$(current_os_version)" ">=" "3.11.0"; then
    ensure_installed_as_package
    ensure_aliases_are_linked
else
    log "INFO" "Skipping installation of exa, because exa is not available for Alpine < 3.11"
fi