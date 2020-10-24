#!/usr/bin/env bash
SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh

function ensure_man_is_installed () {
	log "INFO" "Install man db"
    ${INSTALL_PACKAGE_BIN} --install "alpine(<3.12.0)=man,man-db" "arch=man-pages,manjaro=man-pages,alpine(<3.12.0)=man-pages"
}

function ensure_man_pages_are_installed () {
	if [ "$(current_os)" = "ubuntu" ]; then
		if command -v unminimize > /dev/null 2>&1; then
			log "INFO" "Unminimizing system and installing man pages"
			echo -e "y\\ny\\n" | run_with_sudo_if_required unminimize
		fi
	elif [ "$(current_os)" = "fedora" ] || [ "$(current_os)" = "centos" ]; then
		if grep "^tsflags=nodocs" /etc/dnf/dnf.conf > /dev/null 2>&1; then
			log "INFO" "Reinstalling everything with man pages (dnf)"
			run_with_sudo_if_required "sed -i 's/\(^tsflags=nodocs\)/#\1/g' /etc/dnf/dnf.conf"
			run_with_sudo_if_required "dnf reinstall -y \*"
		elif grep "^tsflags=nodocs" /etc/yum.conf > /dev/null 2>&1; then
			log "INFO" "Reinstalling everything with man pages (yum)"
			run_with_sudo_if_required "sed -i 's/\(^tsflags=nodocs\)/#\1/g' /etc/yum.conf"
			run_with_sudo_if_required "yum reinstall -y \*"
		fi
	elif [ "$(current_os)" = "arch" ] || [ "$(current_os)" = "manjaro" ]; then
		if grep "^NoExtract *= *usr/share/man/\*" /etc/pacman.conf > /dev/null 2>&1; then
			log "INFO" "Reinstalling everything with man pages (pacman)"
			${INSTALL_PACKAGE_BIN} --install "arch=pacutils,manjaro=pacutils"
			run_with_sudo_if_required "sed -i 's/\(^NoExtract *= *usr\/share\/man\/*\)/#\1/g' /etc/pacman.conf"
			if executed_in_container; then
				# auto-resolve everything
				run_with_sudo_if_required pacinstall --install --yolo $(pacman -Qqn)
			else
				# no automatic conflict resolution; prompt user if default answer does not lead to success
				if ! run_with_sudo_if_required pacinstall --install --no-confirm $(pacman -Qqn); then
					run_with_sudo_if_required pacinstall --install $(pacman -Qqn)
				fi
			fi
		fi
	fi
}

ensure_man_is_installed
ensure_man_pages_are_installed