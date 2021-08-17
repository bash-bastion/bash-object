# shellcheck shell=bash

declare -gA ERRORS_BASH_OBJECT=(
	[ERROR_VALUE_NOT_FOUND]='Attempted to access either a member of an object or an index of an array, but the member or index does not exist'
	[ERROR_VALUE_INCORRECT_TYPE]='Attempted to get or set a value, but somewhere a value with a different type was expected'
	[ERROR_INVALID_FILTER]='The supplied filter is invalid'
	[ERROR_INVALID_ARGS]='Invalid arguments'
	[ERROR_INTERNAL_INVALID_VOBJ]='Internal virtual object has incorrect metadata'
	[ERROR_INTERNAL_INVALID_PARAM]='Internal parameter has an incorrect value'
	[ERROR_INTERNAL_MISCELLANEOUS]='Miscellaneous error occured'
)

bash_object.util.die() {
	local error_key="$1"
	local error_context="${2:-<empty>}"

	local error_message="${ERRORS_BASH_OBJECT["$error_key"]}"

	local error_output=
	case "$error_key" in
	ERROR_INVALID_FILTER)
		printf -v error_output 'Failed to perform operation:
  -> code: %s
  -> message: %s
  -> context: %s
  -> PARSER_COLUMN_NUMBER: %s' "$error_key" "$error_message" "$error_context" "$PARSER_COLUMN_NUMBER"
		;;
	*)
		printf -v error_output 'Failed to parse filter:
  -> code: %s
  -> message: %s
  -> context: %s' "$error_key" "$error_message" "$error_context"
		;;
	esac

	printf '%s' "$error_output"
	return 2
}

bash_object.util.generate_vobject_name() {
	unset REPLY

	local root_object_name="$1"
	local root_object_query="$2"

	local random_string=
	if ((BASH_VERSINFO[0] >= 6)) || ((BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 1)); then
		random_string="${SRANDOM}_${SRANDOM}_${SRANDOM}_${SRANDOM}_${SRANDOM}"
	else
		random_string="${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}"
	fi

	REPLY="__bash_object_${root_object_name}_${root_object_query}_${random_string}"
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
