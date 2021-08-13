# shellcheck shell=bash

declare -gA ERRORS_BASH_OBJECT=(
	[ERROR_VALUE_NOT_FOUND]='Attempted to access either a member of an object or an index of an array, but the member or index does not exist'
	[ERROR_VALUE_INCORRECT_TYPE]='Attempted to get or set a value, but somewhere a value with a different type was expected'
	[ERROR_INTERNAL_INVALID_VOBJ]='Internal virtual object has incorrect metadata'
	[ERROR_INTERNAL_INVALID_PARAM]='Internal parameter has an incorrect value'
)

bash_object.util.traverse_fail() {
	local error_key="$1"
	local error_context="$2"

	if [ -z "$error_context" ]; then
		error_context='<empty>'
	fi

	local error_message="${ERRORS_BASH_OBJECT["$error_key"]}"

	local error_output=
	printf -v error_output 'Failed to perform object operation:
  -> code: %s
  -> message: %s
  -> context: %s' "$error_key" "$error_message" "$error_context"

	printf '%s' "$error_output"
	return 2
}
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
