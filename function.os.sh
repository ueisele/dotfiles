#!/usr/bin/env sh

_log () {
    local level="${1:?'Missing log level as first parameter!'}"
    local msg="${2:?'Missing log level as second parameter!'}"
    echo "$(date -Isec)|${level}|${msg}"
}

sudo_if_required () {
    local alternative_action=${1:-"skip"}
    local run_prefix=""
    if [ "$(id -u)" -ne 0 ]; then
        if ! command -v sudo > /dev/null ; then
            # sudo is not installed"
            if [ "${alternative_action}" = "abort" ]; then
                run_prefix="$(log "ERROR" "Aboring execution, because sudo is not installed!"); exit 1; "
            else
                run_prefix="$(log "WARN" "Skipping command, because sudo is not installed!") || "
            fi  
        elif ! sudo -v > /dev/null ; then
            # sudo access is not allowed"
            if [ "${alternative_action}" = "abort" ]; then
                run_prefix="$(log "ERROR" "Aboring execution, because sudo access is not allowed!"); exit 1; "
            else
                run_prefix="$(log "WARN" "Skipping command, because sudo access is not allowed!") || "
            fi  
        else
            run_prefix="sudo "
        fi
    fi
    echo ${run_prefix}
}

current_os () {
    if [ -e /etc/os-release ]; then
        cat /etc/os-release | grep ^ID= | cut -d= -f2 | sed -e 's/^"//' -e 's/"$//'
    elif [ -e /etc/centos-release ]; then
        # Centos == 6
        echo "centos"
    fi
}

current_os_version () {
    if [ -e /etc/os-release ]; then
        cat /etc/os-release | grep ^VERSION_ID= | cut -d= -f2 | sed -e 's/^"//' -e 's/"$//'
    elif [ -e /etc/system-release ]; then
        # Centos == 6
        cat /etc/centos-release | sed "s/.* \([0-9]\+\).*/\1/"
    fi
}

compare_version () {
    local lhs_version="${1:?Missing LHS version as first parameter!}"
    local version_comparator="${2:?Missing version comparator as second parameter!}"
    local rhs_version="${3:?Missing RHS version as third parameter!}"

    local lowest_version="$(printf "${lhs_version}\\n${rhs_version}" | sort -V | head -n1)"

    case "${version_comparator}" in
        "==")
            test "${lhs_version}" = "${rhs_version}"
            ;;
        ">")
            test "${lhs_version}" != "${lowest_version}"
            ;;
        "<")
            test "${lhs_version}" = "${lowest_version}" && test "${lhs_version}" != "${rhs_version}"
            ;;
        ">=")
            test "${lhs_version}" != "${lowest_version}" || test "${lhs_version}" = "${rhs_version}"
            ;;
        "<=")
            test "${lhs_version}" = "${lowest_version}" || test "${lhs_version}" = "${rhs_version}"
            ;;
        *)
            log "WARN" "'${version_comparator}' is not a valid version comparator! Use one of: ==, >, <, >=, <="
            return 1
            ;;
    esac
}

sudo_if_required