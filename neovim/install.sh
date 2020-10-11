#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"
LINK_DOTFILES_BIN="${ROOT_DIR}/tool.link-dotfiles.sh"

GITHUB_REPO="neovim/neovim"

function resolve_github_credentials () {
    if [ -n "${GITHUB_USER}" ] && [ -n "${GITHUB_TOKEN}" ]; then
        echo "-u ${GITHUB_USER}:${GITHUB_TOKEN}"
    fi
}

function resolve_download_url () {
    local tag=${1:-"latest"}

    local query=$(if [ ${tag} == "latest" ]; then echo ${tag}; else echo "tags/${tag}"; fi)
    
    curl $(resolve_github_credentials) -sL https://api.github.com/repos/${GITHUB_REPO}/releases/${query} | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/' | grep "nvim.appimage$"
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

function download_and_install_neovim () {
    local tag=${1:-"latest"}
    local target="${2:-${DOTFILES_APP_DIR}}"
	local targetbin="${3:-${DOTFILES_BIN_DIR}}"

    local download_url="$(resolve_download_url ${tag})"   
    if [ -z "${download_url}" ]; then
        fail 1 "Could not determine an artifact for tag '${tag}'."
    fi

    if [ ! -d ${target} ]; then
        log "INFO" "Create ${target} as target directory for apps"
        create_target_dir "${target}"
    fi
    if [ ! -d ${targetbin} ]; then
        log "INFO" "Create ${targetbin} as target directory for binaries"
        create_target_dir "${targetbin}"
    fi

    local actual_tag="$(resolve_actual_tag ${tag})"
    local filename_short="nvim"
    local filename_full="${filename_short}-${actual_tag}"
    if [ -f "${targetbin}/${filename_full}" ]; then
        log "INFO" "Artifact ${targetbin}/${filename_full} has already been downloaded."
    else
        log "INFO" "Download artifact for tag '${actual_tag}' from URL ${download_url}"
        local tmpdir="$(mktemp -d)"
		curl -sfLR -o "${tmpdir}/nvim.appimage" "${download_url}"
		chmod +x "${tmpdir}/nvim.appimage"
		(cd ${tmpdir} && ./nvim.appimage --appimage-extract > /dev/null)
		chown -R $(id -u):$(id -g) "${tmpdir}"
		chmod -R a+rX "${tmpdir}"
		mv -f "${tmpdir}/squashfs-root" "${target}/${filename_full}"
		rm -r "${tmpdir}"
        log "INFO" "Artifact has been downloaded to ${target}/${filename_full}"
    fi

    ln -sf "${target}/${filename_full}/AppRun" "${targetbin}/${filename_full}"
	ln -sf "${target}/${filename_full}/AppRun" "${targetbin}/${filename_short}"
    log "INFO" "Created symlink from ${target}/${filename_full}/AppRun to ${targetbin}/${filename_full} and ${targetbin}/${filename_short}"
}

function ensure_neovim_is_installed () {
	if [ "$(current_os)" != "alpine" ]; then
		download_and_install_neovim "$@"
	else
		${INSTALL_PACKAGE_BIN} --install neovim "alpine=neovim-doc"
	fi
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

function link_aliases () {
    ${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/aliases" "${DOTFILES_ALIASES_DIR}"
}

ensure_neovim_is_installed "$@"
ensure_dotfiles_are_linked
ensure_plugins_are_installed
link_aliases