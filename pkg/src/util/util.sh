# shellcheck shell=bash

# shellcheck disable=SC2192,SC2034
declare -gA ERRORS_BASH_OBJECT=(
	[ERROR_NOT_FOUND]=
	[ERROR_INTERNAL]=
	[ERROR_SELF_REFERENCE]="A virtual object cannot reference itself"

	[ERROR_ARGUMENTS_INVALID]="Wrong number, empty, or missing required arguments to function"
	[ERROR_ARGUMENTS_INVALID_TYPE]="The type of the final value specified by the user is neither 'object', 'array', nor 'string'"
	[ERROR_ARGUMENTS_INCORRECT_TYPE]="The type of the final value does not match that of the actual final value (at end of query string). Or, the type implied by your query string does not match up with the queried object"

	[ERROR_QUERYTREE_INVALID]="The querytree could not be parsed"

	[ERROR_VOBJ_INVALID_TYPE]="The type of the virtual object is neither 'object' nor 'array'"
	[ERROR_VOBJ_INCORRECT_TYPE]="The type of the virtual object does not match with the type of the variable it references"
)

bash_object.util.die() {
	local error_key="$1"
	local error_context="${2:-<empty>}"

	local error_output=
	case "$error_key" in
	ERROR_QUERYTREE_INVALID)
		printf -v error_output 'Failed to parse querytree:
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

	printf -v REPLY '%q' "__bash_object_${root_object_name}___${root_object_query}_${random_string}"
}

# @description Prints the contents of a particular variable or vobject
bash_object.util.print_hierarchy() {
	local object_name="$1"
	local current_indent="$2"

	if object_type="$(declare -p "$object_name" 2>/dev/null)"; then :; else
		bash_object.util.die 'ERROR_NOT_FOUND' "The variable '$object_name' does not exist"
		return
	fi
	object_type="${object_type#declare -}"

	local -n _object="$object_name"
	if [ "${object_type::1}" = 'A' ]; then
		for object_key in "${!_object[@]}"; do
			local object_value="${_object[$object_key]}"
			if [ "${object_value::2}" = $'\x1C\x1D' ]; then
				# object_value is a vobject
				bash_object.parse_virtual_object "$object_value"
				local virtual_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"

				printf '%*s' "$current_indent" ''
				printf '%s\n' "|__ $object_key ($virtual_object_name)"

				bash_object.util.print_hierarchy "$virtual_object_name" $((current_indent+3))
			else
				# object_value is a string
				printf '%*s' "$current_indent" ''
				printf '%s\n' "|__ $object_key: $object_value"
			fi
		done; unset object_key
	elif [ "${object_type::1}" = 'a' ]; then
		for object_value in "${_object[@]}"; do
			# object_value is a vobject
			if [ "${object_value::2}" = $'\x1C\x1D' ]; then
				bash_object.parse_virtual_object "$object_value"
				local virtual_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"

				printf '%*s' "$current_indent" ''
				printf '%s\n' "|- ($virtual_object_name)"

				bash_object.util.print_hierarchy "$virtual_object_name" $((current_indent+2))
			else
				printf '%*s' "$current_indent" ''
				printf '%s\n' "|- $object_value"
			fi
		done
	else
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "The type of the named object ($object_name) is neither an array nor an object"
		return
	fi
}

# @description Prints the contents of a particular variable or vobject
bash_object.util.unset() {
	local object_name="$1"

	if object_type="$(declare -p "$object_name" 2>/dev/null)"; then :; else
		bash_object.util.die 'ERROR_NOT_FOUND' "The variable '$object_name' does not exist"
		return
	fi
	object_type="${object_type#declare -}"

	local -n _object="$object_name"
	if [ "${object_type::1}" = 'A' ]; then
		for object_key in "${!_object[@]}"; do
			local object_value="${_object[$object_key]}"
			if [ "${object_value::2}" = $'\x1C\x1D' ]; then
				# object_value is a vobject
				bash_object.parse_virtual_object "$object_value"
				local virtual_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"

				bash_object.util.unset "$virtual_object_name"
				unset "$virtual_object_name"
			fi
		done; unset object_key
	elif [ "${object_type::1}" = 'a' ]; then
		for object_value in "${_object[@]}"; do
			# object_value is a vobject
			if [ "${object_value::2}" = $'\x1C\x1D' ]; then
				bash_object.parse_virtual_object "$object_value"
				local virtual_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"

				bash_object.util.unset "$virtual_object_name"
				unset "$virtual_object_name"
			fi
		done
	else
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "The type of the named object ($object_name) is neither an array nor an object"
		return
	fi
}

# @description A stringified version of the querytree stack. This is used when
# generating objects to prevent conflicts
bash_object.util.generate_querytree_stack_string() {
	unset REPLY; REPLY=

	local oldIFS="$IFS"
	IFS='_'
	REPLY="${querytree_stack[*]}"
	IFS="$oldIFS"
}
