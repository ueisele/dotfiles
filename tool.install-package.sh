#!/usr/bin/env sh
set -e
SCRIPT_DIR="$(dirname $0)"
. ${SCRIPT_DIR}/function.log.sh

ensure_installed () {
    local command="${1:?'Missing command as first parameter!'}"
    local package="${2:-${command}}"

    # Check if already installed
    if command -v ${command} > /dev/null; then
        log "INFO" "${command} is already installed"
        return        
    fi
    log "INFO" "${command} is not installed, try to install it"
    
    local run=""
    if [ "$(id -u)" -ne 0 ]; then
        log "INFO" "Installation triggerd as non root user, try to install ${command} with sudo"
        # Check if sudo is installed and sudo access is allowed
        if ! command -v sudo > /dev/null
        then
            fail 1 "Could not install ${command}, because sudo is not installed"     
        fi
        if ! sudo -v > /dev/null
        then
            fail 1 "Could not install ${command}, because sudo access is not allowed"     
        fi
        run="sudo"
    fi

    # Try to install
    if command -v apt-get > /dev/null
    then
        ${run} apt-get update && ${run} apt-get install -y ${package} && ${run} apt-get autoremove && ${run} apt-get clean
        log "INFO" "Successfully installed ${package} with apt"
        return        
    fi
    if command -v dnf > /dev/null
    then
        ${run} dnf install -y ${package} && ${run} dnf autoremove && ${run} dnf clean all
        log "INFO" "Successfully installed ${package} with dnf"
        return        
    fi
    if command -v yum > /dev/null
    then
        ${run} yum install -y ${package} && ${run} yum clean all
        log "INFO" "Successfully installed ${package} with yum"
        return        
    fi
    if command -v pacman > /dev/null
    then
        ${run} pacman -Sy --noconfirm ${package} && ${run} pacman -Sc --noconfirm 
        log "INFO" "Successfully installed ${package} with pacman"
        return        
    fi
    if command -v apk > /dev/null
    then
        ${run} apk update && ${run} apk add ${package}
        log "INFO" "Successfully installed ${package} with apk"
        return        
    fi

    fail 1 "Could not install ${package}, with apt, dnf, yum, pacman or apk!" 
}

ensure_installed "$@"