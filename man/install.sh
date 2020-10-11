#!/usr/bin/env bash
SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
source ${ROOT_DIR}/function.os.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"

function ensure_man_is_installed () {
	log "INFO" "Install man db"
    ${INSTALL_PACKAGE_BIN} --install "alpine(<3.12.0)=man,man-db" "arch=man-pages,manjaro=man-pages,alpine(<3.12.0)=man-pages"
}

function ensure_man_pages_are_installed () {
	if [ "$(current_os)" = "ubuntu" ]; then
		if command -v unminimize &> /dev/null; then
			log "INFO" "Unminimizing system and installing man pages"
			run_with_sudo_if_required unminimize << 'EOF'
y
y
EOF
		fi
	elif [ "$(current_os)" = "fedora" ] || [ "$(current_os)" = "centos" ]; then
		if grep "^tsflags=nodocs" /etc/dnf/dnf.conf > /dev/null 2>&1; then
			log "INFO" "Reinstalling everything with man pages"
			run_with_sudo_if_required sed -i 's/\(^tsflags=nodocs\)/#\1/g' /etc/dnf/dnf.conf
			run_with_sudo_if_required dnf reinstall -y \*
		elif grep "^tsflags=nodocs" /etc/yum.conf > /dev/null 2>&1; then
			log "INFO" "Reinstalling everything with man pages"
			run_with_sudo_if_required sed -i 's/\(^tsflags=nodocs\)/#\1/g' /etc/yum.conf
			run_with_sudo_if_required yum reinstall -y \*
		fi
	elif [ "$(current_os)" = "archlinux" ] || [ "$(current_os)" = "manjaro" ]; then
		if grep "^NoExtract *= *usr/share/man/\*" /etc/pacman.conf > /dev/null 2>&1; then
			log "INFO" "Reinstalling everything with man pages"
			run_with_sudo_if_required sed -i 's/\(^NoExtract *= *usr\/share\/man\/*\)/#\1/g' /etc/pacman.conf
			pacman -Qqn | run_with_sudo_if_required pacman -S --noconfirm -
		fi
	fi
}

ensure_man_is_installed
ensure_man_pages_are_installed