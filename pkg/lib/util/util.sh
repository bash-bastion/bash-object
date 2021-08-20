# shellcheck shell=bash

# shellcheck disable=SC2192
declare -gA ERRORS_BASH_OBJECT=(
	[ERROR_NOT_FOUND]=
	[ERROR_INTERNAL]=
	[ERROR_SELF_REFERENCE]="A virtual object cannot reference itself"

	[ERROR_ARGUMENTS_INVALID]="Wrong number, empty, or missing required arguments to function"
	[ERROR_ARGUMENTS_INVALID_TYPE]="The type of the final value specified by the user is neither 'object', 'array', nor 'string'"
	[ERROR_ARGUMENTS_INCORRECT_TYPE]="The type of the final value does not match that of the actual final value (at end of query string)"

	[ERROR_FILTER_INVALID]="The filter could not be parsed"
	[ERROR_FILTER_INCORRECT_TYPE]=

	[ERROR_VOBJ_INVALID_TYPE]="The type of the virtual object is neither 'object' nor 'array'"
	[ERROR_VOBJ_INCORRECT_TYPE]="The type of the virtual object does not match with the type of the variable it references"
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
	ERROR_FILTER_INVALID)
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

# @description A stringified version of the filter
# stack. This is used when generating objects to prevent
# conflicts
bash_object.util.generate_filter_stack_string() {
	unset REPLY

	local oldIFS="$IFS"
	IFS='_'
	REPLY="${filter_stack[*]}"
	IFS="$oldIFS"
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
