# shellcheck shell=bash

# shellcheck disable=SC2192
declare -gA ERRORS_BASH_OBJECT=(
	[ERROR_VALUE_NOT_FOUND]=
	[ERROR_VALUE_INCORRECT_TYPE]=
	[ERROR_INVALID_FILTER]=
	[ERROR_INVALID_ARGS]=
	[ERROR_INTERNAL_INVALID_VOBJ]=
	[ERROR_INTERNAL_INVALID_PARAM]=
	[ERROR_INTERNAL_MISCELLANEOUS]=
)

bash_object.util.die() {
	local error_key="$1"
	local error_context="${2:-<empty>}"

	# TODO: test
	# if [[ ! -v 'ERRORS_BASH_OBJECT["$error_key"]' ]]; then
	# 	return 77
	# fi

	local error_output=
	case "$error_key" in
	ERROR_INVALID_FILTER)
		printf -v error_output 'Failed to parse filter:
  -> code: %s
  -> context: %s
  -> PARSER_COLUMN_NUMBER: %s
' "$error_key" "$error_context" "$PARSER_COLUMN_NUMBER"
		;;
	*)
		printf -v error_output 'Failed to perform operation:
  -> code: %s
  -> context: %s
' "$error_key" "$error_context"
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
