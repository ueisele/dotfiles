#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh

GITHUB_REPO="neovim/neovim"

RETRIES=3

function ensure_neovim_is_installed () {
	if [ "$(current_os)" != "alpine" ]; then
		ensure_downloaded_and_installed_from_github "$@"
	else
		ensure_installed_as_package
	fi
}

function ensure_downloaded_and_installed_from_github () {
    local tag=${1:-"latest"}

    local download_url="$(resolve_download_url ${tag})"   
    if [ -z "${download_url}" ]; then
        fail 1 "Could not determine an artifact for tag '${tag}'."
    fi

    local actual_tag="$(resolve_actual_tag ${tag})"
    local name_short="nvim"
    local name_full="${name_short}-${actual_tag}"

    if [ -f "${DOTFILES_APP_DIR}/${name_full}/download.timestamp" ]; then
        log "INFO" "Artifact ${name_full} has already been downloaded."
    else
        log "INFO" "Download artifact for tag '${actual_tag}' from URL ${download_url}"
        local tmpdir="$(mktemp -d)"
		curl -sfLR --retry ${RETRIES} -o "${tmpdir}/nvim.appimage" "${download_url}"
		chmod +x "${tmpdir}/nvim.appimage"
		(cd ${tmpdir} && ./nvim.appimage --appimage-extract > /dev/null)
		chown -R $(id -u):$(id -g) "${tmpdir}"
		chmod -R a+rX "${tmpdir}"
		mv -f "${tmpdir}/squashfs-root" "${DOTFILES_APP_DIR}/${name_full}"
		rm -r "${tmpdir}"
        log "INFO" "Artifact has been downloaded to ${DOTFILES_APP_DIR}/${name_full}"

        echo "$(date -Isec)" > "${DOTFILES_APP_DIR}/${name_full}/download.timestamp"
    fi

    mkdir -p "${DOTFILES_BIN_DIR}"
	ln -srf "${DOTFILES_APP_DIR}/${name_full}/AppRun" "${DOTFILES_BIN_DIR}/${name_short}"
    log "INFO" "Linked binary from ${DOTFILES_APP_DIR}/${name_full}/AppRun to ${DOTFILES_BIN_DIR}/${name_short}"

    mkdir -p "${DOTFILES_MAN_DIR}/man1"
    ln -srf "${DOTFILES_APP_DIR}/${name_full}/usr/man/man1/${name_short}.1" "${DOTFILES_MAN_DIR}/man1"
    log "INFO" "Linked man page from ${DOTFILES_APP_DIR}/${name_full}/usr/man/man1/${name_short}.1 to ${DOTFILES_MAN_DIR}/man1/${name_short}.1"
}

function ensure_installed_as_package () {
    ${INSTALL_PACKAGE_BIN} --install neovim "alpine=neovim-doc"
}

function ensure_dotfiles_are_linked () {
	${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/files"
}

function ensure_plugins_are_installed () {
	if [ "$(current_os)" != "alpine" ]; then
		local nvim_path="${DOTFILES_BIN_DIR}/"
	fi

	${nvim_path}nvim +'PlugInstall --sync' +qa
	${nvim_path}nvim +'PlugUpdate' +qa
}

function ensure_aliases_are_linked () {
    ${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/aliases" "${DOTFILES_ALIASES_DIR}"
}

function resolve_download_url () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL --retry ${RETRIES} https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep "nvim.appimage$"
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

ensure_neovim_is_installed "$@"
ensure_dotfiles_are_linked
ensure_plugins_are_installed
ensure_aliases_are_linked