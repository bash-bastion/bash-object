# shellcheck shell=bash

# TODO
stdtrace.log() {
    local level="$1"
    local message="$2"

    local padding=
    case "$level" in
        0) padding= ;;
        1) padding="  " ;;
        2) padding="    " ;;
        3) padding="      " ;;
    esac

    printf '%s\n' "TRACE $level: $padding| $message" >&3
}
