#!/usr/bin/env sh
SCRIPT_DIR="$(readlink -f $(dirname $0))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR})"
. ${ROOT_DIR}/function.log.sh
. ${ROOT_DIR}/function.os.sh

_UPDATE=false
_CLEAN=false
_INSTALL=false
_PACKAGES=""
_INSTALL_PARAMETER=""
_DELIMITER="|"

usage () {
    echo "$0: $1" >&2
    echo
    echo "Usage: $0 [--update] [--clean] [--install <packages, e.g. alpine=gnupg,gpg centos(>=8)=git tzdata>] [--install-parameter <parameter, e.g. centos=--enablerepo=epel-testing>]"
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
        usage "Requires at least one parameter!"
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
                                _PACKAGES="${_PACKAGES}${_DELIMITER}"
                            fi
                            _PACKAGES="${_PACKAGES}$1"
                            shift
                            ;;
                    esac
                done
                ;;
            --install-parameter)
                shift
                while [ $# -gt 0 ]; do
                    case "$1" in
                        ""|--*)
                            break
                            ;;
                        *)
                            if [ -n "${_INSTALL_PARAMETER}" ]; then
                                _INSTALL_PARAMETER="${_INSTALL_PARAMETER}${_DELIMITER}"
                            fi
                            _INSTALL_PARAMETER="${_INSTALL_PARAMETER}$1"
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
    if command -v apt-get > /dev/null
    then
        export DEBIAN_FRONTEND=noninteractive
        run_with_sudo_if_required apt-get update
        log "INFO" "Successfully updated package database with apt"
        export DEBIAN_FRONTEND=interactive
        return        
    fi
    if command -v dnf > /dev/null
    then
        run_with_sudo_if_required dnf check-update
        log "INFO" "Successfully updated package database with dnf"
        return        
    fi
    if command -v yum > /dev/null
    then
        run_with_sudo_if_required yum check-update
        log "INFO" "Successfully updated package database with yum"
        return        
    fi
    if command -v pacman > /dev/null
    then
        run_with_sudo_if_required pacman -Syy --noconfirm 
        log "INFO" "Successfully updated package database with pacman"
        return        
    fi
    if command -v apk > /dev/null
    then
        run_with_sudo_if_required apk update
        log "INFO" "Successfully updated package database with apk"
        return        
    fi

    log "WARN" "Could not update package database with apt, dnf, yum, pacman or apk!" 
}

clean () {
    if command -v apt-get > /dev/null
    then
        export DEBIAN_FRONTEND=noninteractive
        run_with_sudo_if_required apt-get clean -y
        log "INFO" "Successfully cleaned package cache with apt"
        export DEBIAN_FRONTEND=interactive
        return        
    fi
    if command -v dnf > /dev/null
    then
        run_with_sudo_if_required dnf clean all -y
        log "INFO" "Successfully cleaned package cache with dnf"
        return        
    fi
    if command -v yum > /dev/null
    then
        run_with_sudo_if_required yum clean all -y
        log "INFO" "Successfully cleaned package cache with yum"
        return        
    fi
    if command -v pacman > /dev/null
    then
        run_with_sudo_if_required pacman -Sc --noconfirm 
        log "INFO" "Successfully cleaned package cache with pacman"
        return        
    fi
    if command -v apk > /dev/null
    then
        log "INFO" "Successfully cleaned package cache with apk"
        return        
    fi

    log "WARN" "Could not clean package cache with apt, dnf, yum, pacman or apk!" 
}

install_packages () {
    local current_ifs="$IFS"
    IFS="${_DELIMITER}"
    for package_list in ${_PACKAGES}; do
        install_package_for_os $package_list
    done
    IFS="${current_ifs}"
}

install_package_for_os () {
    local package_list="${1:?Missing package list as first parameter!}"
    local current_ifs="$IFS"
    IFS=","
    for entry in ${package_list}; do
        local package="$(get_value_of_entry "${entry}")"
        local expected_os="$(get_os_of_entry "${entry}")"
        local expected_os_version="$(get_version_of_entry "${entry}")"
        local comparator="$(get_version_comparator_of_entry "${entry}")"
        if ( ! has_entry_os_condition "${entry}" ) \
            || ( [ "${expected_os}" = "$(current_os)" ] \
                && ( ( ! has_entry_version_condition "${entry}" ) \
                    || ( [ -n "$(current_os_version)" ] && compare_version "$(current_os_version)" "${comparator}" "${expected_os_version}" ) ) ); then
            install_package "${package}" "$(resolve_install_paramerer)"
            break
        fi
    done
    IFS="${current_ifs}"
}

resolve_install_paramerer () {
    local parameters_for_os=""
    local current_ifs="$IFS"
    IFS="${_DELIMITER}"
    for param_list in ${_INSTALL_PARAMETER}; do
        IFS=','
        for e in ${param_list}; do
            local the_entry_parameter="$(get_value_of_entry "${e}")"
            local the_expected_os="$(get_os_of_entry "${e}")"
            local the_expected_os_version="$(get_version_of_entry "${e}")"
            local the_comparator="$(get_version_comparator_of_entry "${e}")"
            if [ "${the_expected_os}" = "$(current_os)" ] \
                && ( ( ! has_entry_version_condition "${e}" ) \
                    || ( [ -n "$(current_os_version)" ] && compare_version "$(current_os_version)" "${the_comparator}" "${the_expected_os_version}") ); then
                if [ -n "${parameters_for_os}" ]; then
                    parameters_for_os="${parameters_for_os} "
                fi
                parameters_for_os="${parameters_for_os}${the_entry_parameter}"
            fi
        done
        IFS="${_DELIMITER}"
    done
    IFS="${current_ifs}"
    echo "${parameters_for_os}"
}

install_package () {
    local package="${1:?'Missing package as first parameter!'}"
    local parameter="${2:-""}"  
    if command -v apt-get > /dev/null
    then
        export DEBIAN_FRONTEND=noninteractive
        if [ "$(dpkg-query -W -f='${Status}\n' "${package}" 2>&1 | cut -d" " -f1)" != "install" ]; then
            log "INFO" "${package} is not installed, try to install it"
            run_with_sudo_if_required apt-get install -y ${parameter} ${package}
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
        if (is_url "${package}") || (dnf list --available -q ${package} > /dev/null 2>&1) || ! (dnf list --installed -q ${package} > /dev/null 2>&1) ; then
            log "INFO" "${package} is not installed, try to install it"
            run_with_sudo_if_required dnf install -y --best --allowerasing ${parameter} ${package}
            if [ $? -eq 0 ]; then
                log "INFO" "Successfully installed ${package} with dnf"
            elif (is_url "${package}") ; then
                log "INFO" "Could not install ${package} with dnf." 
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
        if (is_url "${package}") || (yum list -q ${package} 2> /dev/null | grep -i available > /dev/null 2>&1) || ! (yum list -q ${package} 2> /dev/null | grep -i installed > /dev/null 2>&1) ; then
            log "INFO" "${package} is not installed, try to install it"
            run_with_sudo_if_required yum install -y ${parameter} ${package}
            if [ $? -eq 0 ]; then
                log "INFO" "Successfully installed ${package} with yum"
            elif (is_url "${package}") ; then
                log "INFO" "Could not install ${package} with yum." 
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
        if ! (pacman -Qi ${package} > /dev/null 2>&1) ; then
            log "INFO" "${package} is not installed, try to install it"
            run_with_sudo_if_required pacman -S --noconfirm ${parameter} ${package} 
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
            run_with_sudo_if_required apk add ${parameter} ${package}
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

has_entry_os_condition () {
    if [ -z "$(get_os_of_entry "$@")" ]; then return 1; else return 0; fi
}

has_entry_version_condition () {
    if [ -z "$(get_version_of_entry "$@")" ]; then return 1; else return 0; fi
}

get_os_of_entry () {
    local the_entry="${1:?Missing the entry as first parameter!}"
    get_group_of_entry "${the_entry}" 2
}

get_version_comparator_of_entry () {
    local the_entry="${1:?Missing the entry as first parameter!}"
    get_group_of_entry "${the_entry}" 4
}

get_version_of_entry () {
    local the_entry="${1:?Missing the entry as first parameter!}"
    get_group_of_entry "${the_entry}" 5
}

get_value_of_entry () {
    local the_entry="${1:?Missing the entry as first parameter!}"
    get_group_of_entry "${the_entry}" 6
}

get_group_of_entry () {
    local the_entry="${1:?Missing the entry as first parameter!}"
    local the_group="${2:?Missing the group numer as second parameter!}"
    echo "${the_entry}" | sed "s/\(\([^(=]*\)\((\([<>=]\+\)\(.*\))\)\?=\)\?\(.*\)/\\${the_group}/"
}

is_url () {
    local the_value="${1:?Requires a value as first parameter}"
    case "${the_value}" in
        http://*)
            return 0
            ;;
        https://*)
            return 0
            ;;
        *)  
            return 1 
            ;;
    esac
}

_main "$@"