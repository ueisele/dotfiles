#!/usr/bin/env sh
SCRIPT_DIR="$(dirname $0)"
. ${SCRIPT_DIR}/function.log.sh

_UPDATE=false
_CLEAN=false
_INSTALL=false
_PACKAGES=""

usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--update] [--clean] [--install <packages, e.g. alpine=gnupg,gpg tzdata>]"
    echo
    return 1
}

_main () {
    parseCmd "$@"
    local retval=$?
    if [ $retval != 0 ]; then
        exit $retval
    fi

    if [ "$_UPDATE" = true ]; then
        update
    fi
    if [ "$_INSTALL" = true ]; then
        install_packages
    fi
    if [ "$_CLEAN" = true ]; then
        clean
    fi
}

parseCmd () {
    if [ $# -eq 0 ]; then
        usage "Requires at least one paramater!"
        return $?
    fi
    while [ $# -gt 0 ]; do
        case "$1" in
            --update)
                _UPDATE=true
                shift
                ;;
            --clean)
                _CLEAN=true
                shift
                ;;
            --install)
                _INSTALL=true
                shift
                while [ $# -gt 0 ]; do
                    case "$1" in
                        ""|--*)
                            break
                            ;;
                        *)
                            if [ -n "${_PACKAGES}" ]; then
                                _PACKAGES="${_PACKAGES}:"
                            fi
                            _PACKAGES="${_PACKAGES}$1"
                            shift
                            ;;
                    esac
                done
                ;;
            *)
                usage "Unknown option: $1"
                return $?
                ;;
        esac
    done
    if [ "${_INSTALL}" = true ] && [ -z "${_PACKAGES}" ] ; then
        usage "Requires at least one package to install"
        return $?
    fi
    return 0
}

update () {
    local run="$(determine_run_prefix)"
    if command -v apt-get > /dev/null
    then
        export DEBIAN_FRONTEND=noninteractive
        ${run} apt-get update
        log "INFO" "Successfully updated package database with apt"
        export DEBIAN_FRONTEND=interactive
        return        
    fi
    if command -v dnf > /dev/null
    then
        ${run} dnf --refresh check-upgrade
        log "INFO" "Successfully updated package database with dnf"
        return        
    fi
    if command -v yum > /dev/null
    then
        ${run} yum check-update
        log "INFO" "Successfully updated package database with yum"
        return        
    fi
    if command -v pacman > /dev/null
    then
        ${run} pacman -Syy --noconfirm 
        log "INFO" "Successfully updated package database with pacman"
        return        
    fi
    if command -v apk > /dev/null
    then
        ${run} apk update
        log "INFO" "Successfully updated package database with apk"
        return        
    fi

    fail 1 "Could not update package database with apt, dnf, yum, pacman or apk!" 
}

clean () {
    local run="$(determine_run_prefix)"
    if command -v apt-get > /dev/null
    then
        export DEBIAN_FRONTEND=noninteractive
        ${run} apt-get autoremove && ${run} apt-get clean
        log "INFO" "Successfully cleaned package cache with apt"
        export DEBIAN_FRONTEND=interactive
        return        
    fi
    if command -v dnf > /dev/null
    then
        ${run} dnf autoremove && ${run} dnf clean all
        log "INFO" "Successfullycleaned package cache with dnf"
        return        
    fi
    if command -v yum > /dev/null
    then
        ${run} yum clean all
        log "INFO" "Successfully cleaned package cache with yum"
        return        
    fi
    if command -v pacman > /dev/null
    then
        ${run} pacman -Sc --noconfirm 
        log "INFO" "Successfully cleaned package cache with pacman"
        return        
    fi
    if command -v apk > /dev/null
    then
        log "INFO" "Successfully cleaned package cache with apk"
        return        
    fi

    fail 1 "Could not clean package cache with apt, dnf, yum, pacman or apk!" 
}

install_packages () {
    local current_ifs=$IFS
    IFS=':'
    for package_list in ${_PACKAGES}; do
        install_package_for_os $package_list
    done
    IFS=${current_ifs}
}

determine_run_prefix () {
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
    echo ${run}
}

install_package_for_os () {
    local package_list=${1:?Missing package list as first parameter!}
    IFS=','
    for entry in ${package_list}; do
        case "${entry}" in
            *=*)
                local os=$(echo ${entry} | cut -d= -f1)
                local package=$(echo ${entry} | cut -d= -f2)
                if [ "${os}" = "$(current_os)" ]; then
                    install_package ${package}
                    break
                fi
                ;;
            *)
                install_package ${entry}
                break
                ;;
        esac
    done
    IFS=${current_ifs}
}

current_os () {
    cat /etc/*-release | grep ^ID= | cut -d= -f2 | sed -e 's/^"//' -e 's/"$//'
}

install_package () {
    local package="${1:?'Missing package as first parameter!'}"  
    local run="$(determine_run_prefix)"
    if command -v apt-get > /dev/null
    then
        export DEBIAN_FRONTEND=noninteractive
        if ! (dpkg-query --list ${package} 2>&1 > /dev/null) ; then
            log "INFO" "${package} is not installed, try to install it"
            ${run} apt-get install -y ${package}
            if [ $? -eq 0 ]; then
                log "INFO" "Successfully installed ${package} with apt"
            else
                fail 1 "Could not install ${package} with apt!"
            fi
        else
            log "INFO" "${package} is already installed"
        fi
        export DEBIAN_FRONTEND=interactive
        return        
    fi
    if command -v dnf > /dev/null
    then
        if ! (dnf list --installed -q ${package} 2>&1 &> /dev/null) ; then
            log "INFO" "${package} is not installed, try to install it"
            ${run} dnf install -y ${package}
            if [ $? -eq 0 ]; then
                log "INFO" "Successfully installed ${package} with dnf"
            else
                fail 1 "Could not install ${package} with dnf!"
            fi
        else
            log "INFO" "${package} is already installed"
        fi
        return        
    fi
    if command -v yum > /dev/null
    then
        if ! (yum list -q ${package} | grep -i installed 2>&1 &> /dev/null) ; then
            log "INFO" "${package} is not installed, try to install it"
            ${run} yum install -y ${package} && ${run} yum clean all
            if [ $? -eq 0 ]; then
                log "INFO" "Successfully installed ${package} with yum"
            else
                fail 1 "Could not install ${package} with yum!"
            fi
        else
            log "INFO" "${package} is already installed"
        fi
        return        
    fi
    if command -v pacman > /dev/null
    then
        if ! (pacman -Qi ${package} 2>&1 > /dev/null) ; then
            log "INFO" "${package} is not installed, try to install it"
            ${run} pacman -S --noconfirm ${package} 
            if [ $? -eq 0 ]; then
                log "INFO" "Successfully installed ${package} with pacman"
            else
                fail 1 "Could not install ${package} with pacman!"
            fi
        else
            log "INFO" "${package} is already installed"
        fi
        return        
    fi
    if command -v apk > /dev/null
    then
        if [ -z "$(apk list -I ${package})" ]; then
            log "INFO" "${package} is not installed, try to install it"
            ${run} apk add ${package}
            if [ $? -eq 0 ]; then
                log "INFO" "Successfully installed ${package} with apk"
            else
                fail 1 "Could not install ${package} with apk!"
            fi
        else
            log "INFO" "${package} is already installed"
        fi
        return        
    fi

    fail 1 "Could not install ${package}, with apt, dnf, yum, pacman or apk!" 
}

_main "$@"