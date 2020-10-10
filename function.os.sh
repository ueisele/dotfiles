#!/usr/bin/env sh

_log () {
    local level="${1:?'Missing log level as first parameter!'}"
    local msg="${2:?'Missing log level as second parameter!'}"
    echo "$(date -Isec)|${level}|${msg}"
}

run_with_sudo_if_required () {
    if [ "$(id -u)" -ne 0 ]; then
        if ! command -v sudo > /dev/null ; then
            _log "WARN" "Could not execute command, because sudo is not installed: $(echo "$@")"
            return 1
        elif ! sudo -v > /dev/null ; then
            _log "WARN" "Could not execute command, because sudo access is not allowed: $(echo "$@")"
            return 1
        else
            eval "sudo $@"
        fi
    else
        eval "$@"
    fi
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
