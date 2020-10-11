#!/usr/bin/env bash
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"

function ensure_tzdata_is_installed () {
	log "INFO" "Install timezone package tzdata"
    ${INSTALL_PACKAGE_BIN} --install tzdata
}

function ensure_timezone_is_europe_berlin () {
	log "INFO" "Set timezone to Europe/Berlin"
	run_with_sudo_if_required ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
	if [ "$?" -ne 0 ]; then
		fail 1 "Could not set timezone!"
	fi
}

ensure_tzdata_is_installed
ensure_timezone_is_europe_berlin