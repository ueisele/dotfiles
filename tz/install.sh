#!/usr/bin/env bash

set -e
SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"

function ensure_tzdata_is_installed () {
    ${INSTALL_PACKAGE_BIN} --install tzdata
}

function ensure_timezone_is_europe_berkin () {
	if [ -e /etc/localtime ]; then
		rm /etc/localtime
	fi
	ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
}

ensure_tzdata_is_installed
ensure_timezone_is_europe_berkin