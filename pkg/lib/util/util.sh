# shellcheck shell=bash

declare -gA ERRORS_BASH_OBJECT=(
	[ERROR_VALUE_NOT_FOUND]='Attempted to access either a member of an object or an index of an array, but the member or index does not exist'
	[ERROR_VALUE_INCORRECT_TYPE]='Attempted to get or set a value, but somewhere a value with a different type was expected'
	[ERROR_INTERNAL_INVALID_VOBJ]='Internal virtual object has incorrect metadata'
)

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
