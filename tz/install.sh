#!/usr/bin/env bash
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh

function ensure_tzdata_is_installed () {
	log "INFO" "Install timezone package tzdata"
    ${INSTALL_PACKAGE_BIN} --install tzdata "alpine=tzdata-doc"
}

function ensure_timezone_is_europe_berlin () {
	log "INFO" "Set timezone to Europe/Berlin"
	run_with_sudo_if_required ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
	if [ "$?" -ne 0 ]; then
		log "INFO" "Could not set timezone system-wide"
	fi
}

ensure_tzdata_is_installed
ensure_timezone_is_europe_berlin