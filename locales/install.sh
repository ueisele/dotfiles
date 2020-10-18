#!/usr/bin/env bash
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh

function ensure_locales_are_installed () {
	if [ "$(current_os)" = "alpine" ]; then
		log "INFO" "Skipping installation of locales, because Alpine does not support locales"
		return
	fi
	if command -v locale > /dev/null && locale -a | grep -q en_US.utf8; then
		log "INFO" "Locale en_US.utf8 is already installed"
		return
	fi

	${INSTALL_PACKAGE_BIN} --install \
		"debian=locales,ubuntu=locales" \
		"fedora=glibc-locale-source,centos(>=8)=glibc-locale-source" "fedora(>=30)=langpacks-en,centos(>=8)=langpacks-en" "fedora(>=30)=glibc-langpack-en,centos(>=8)=glibc-langpack-en"
	if [ "$(current_os)" = "debian" ] || [ "$(current_os)" = "ubuntu" ]; then
		log "INFO" "Generating en_US.UTF-8 locale"
		run_with_sudo_if_required "sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen"
		run_with_sudo_if_required locale-gen
	fi
}

ensure_locales_are_installed