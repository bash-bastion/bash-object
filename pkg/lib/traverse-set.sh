# shellcheck shell=bash

bash_object.traverse-set() {
	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 ''
		stdtrace.log 0 "CALL: bash_object.traverse-set: $*"
	fi

	local final_value_type="$1"
	local root_object_name="$2"
	local filter="$3"
	local final_value="$4"

	if (( $# != 4)); then
		bash_object.util.die 'ERROR_INVALID_ARGS' "Incorrect arguments for subcommand 'set-$final_value_type'"
		return
	fi

	# TODO test
	# Ensure parameters are not empty
	local variable=
	for variable_name in final_value_type root_object_name filter; do
		local -n variable="$variable_name"

		if [ -z "$variable" ]; then
			bash_object.util.die 'ERROR_INVALID_ARGS' "Variable '$variable' is empty. Please check passed parameters"
			return
		fi
	done

	if [ -n "${VERIFY_BASH_OBJECT+x}" ]; then
		# TODO: test
		# Check 'root_object_name'
		local root_object_type=
		if root_object_type="$(declare -p "$root_object_name" 2>/dev/null)"; then :; else
			bash_object.util.die 'ERROR_INVALID_ARGS' "The final value of '$root_object_name' does not exist"
			return
		fi
		root_object_type="${root_object_type#declare -}"
		if [ "${root_object_type::1}" != 'A' ]; then
			bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "The root object must have a type of 'object'"
			return
		fi

		# TODO: test
		# Check 'final_value' for type correctness
		if [ "$final_value_type" != string ]; then
			local actual_final_value_type=
			if ! actual_final_value_type="$(declare -p "$final_value" 2>/dev/null)"; then
				bash_object.util.die 'ERROR_INVALID_ARGS' "The final value of '$final_value' does not exist"
				return
			fi
			actual_final_value_type="${actual_final_value_type#declare -}"
			case "${actual_final_value_type::1}" in
				A) actual_final_value_type='object' ;;
				a) actual_final_value_type='array' ;;
				i) actual_final_value_type='integer' ;;
				-) actual_final_value_type='string' ;;
				*) actual_final_value_type='unknown' ;;
			esac

			if [ "$final_value_type" == object ]; then
				if [ "$actual_final_value_type" != object ]; then
					bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "The type of the final value was expected to be '$final_value_type', but was actually '$actual_final_value_type'"
					return
				fi
			elif [ "$final_value_type" == array ]; then
				if [ "$actual_final_value_type" != array ]; then
					bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "The type of the final value was expected to be '$final_value_type', but was actually '$actual_final_value_type'"
					return
				fi
			else
				# case 'string' is handled above
				bash_object.util.die 'ERROR_INTERNAL_INVALID_PARAM' "Unexpected final_value_type '$final_value_type   $actual_final_value_type'"
				return
			fi
		fi
	fi

	# Start traversing at the root object
	local current_object_name="$root_object_name"
	local -n current_object="$root_object_name"

	# A stack of all the evaluated filter elements
	local -a filter_stack=()

	# Parse the filter, and recurse over their elements
	case "$filter" in
		*']'*) bash_object.parse_filter --advanced "$filter" ;;
		*) bash_object.parse_filter --simple "$filter" ;;
	esac
	for ((i=0; i<${#REPLIES[@]}; i++)); do
		local key="${REPLIES[$i]}"
		filter_stack+=("$key")

		local oldIFS="$IFS"
		IFS='_'
		local filter_stack_string="${filter_stack[*]}"
		IFS="$oldIFS"

		bash_object.trace_loop

		# If 'key' is not a member of object or index of array, error
		if [ -z "${current_object["$key"]+x}" ]; then
			# If we are before the last element in the query, then error
			if ((i+1 < ${#REPLIES[@]})); then
				bash_object.util.die 'ERROR_VALUE_NOT_FOUND' "Key or index '$key' is not in '$filter_stack_string'"
				return
			# If we are at the last element in the query
			elif ((i+1 == ${#REPLIES[@]})); then
				if [ "$final_value_type" = object ]; then
					# TODO: test this
					# shellcheck disable=SC1087
					if bash_object.ensure.variable_does_exist "$final_value"; then :; else
						return
					fi

					bash_object.util.generate_vobject_name "$root_object_name" "$filter_stack_string"
					local global_object_name="$REPLY"

					if bash_object.ensure.variable_is_valid "$global_object_name"; then :; else
						return
					fi

					if bash_object.ensure.variable_does_not_exist "$global_object_name"; then :; else
						return
					fi

					if ! eval "declare -gA $global_object_name=()"; then
						bash_object.util.die 'ERROR_INTERNAL_MISCELLANEOUS' 'Eval declare failed'
						return
					fi

					current_object["$key"]=$'\x1C\x1D'"type=object;&$global_object_name"

					local -n globel_object="$global_object_name"
					local -n object_to_copy_from="$final_value"

					# TODO: test if object_to_copy is of the correct type

					for key in "${!object_to_copy_from[@]}"; do
						# shellcheck disable=SC2034
						globel_object["$key"]="${object_to_copy_from["$key"]}"
					done
				elif [ "$final_value_type" = array ]; then
					# TODO: test this
					# shellcheck disable=SC1087
					if bash_object.ensure.variable_does_exist "$final_value"; then :; else
						return
					fi

					bash_object.util.generate_vobject_name "$root_object_name" "$filter_stack_string"
					local global_array_name="$REPLY"

					if bash_object.ensure.variable_is_valid "$global_array_name"; then :; else
						return
					fi

					if bash_object.ensure.variable_does_not_exist "$global_array_name"; then :; else
						return
					fi

					if ! eval "declare -ga $global_array_name=()"; then
						bash_object.util.die 'ERROR_INTERNAL_MISCELLANEOUS' 'Eval declare failed'
						return
					fi

					current_object["$key"]=$'\x1C\x1D'"type=array;&$global_array_name"

					local -n global_array="$global_array_name"
					local -n array_to_copy_from="$final_value"

					# TODO: test if object_to_copy is of the correct type

					# shellcheck disable=SC2034
					global_array=("${array_to_copy_from[@]}")
				elif [ "$final_value_type" = string ]; then
					current_object["$key"]="$final_value"
				else
					bash_object.util.die 'ERROR_INTERNAL_INVALID_PARAM' "Unexpected final_value_type '$final_value_type'"
					return
				fi
			fi
		# If 'key' is already a member of object or index of array
		else
			local key_value="${current_object["$key"]}"

			# If 'key_value' is a virtual object, dereference it
			if [ "${key_value::2}" = $'\x1C\x1D' ]; then
				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 2 "BLOCK: OBJECT/ARRAY"
				fi

				virtual_item="${key_value#??}"
				bash_object.parse_virtual_object "$virtual_item"
				local current_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"
				local -n current_object="$current_object_name"

				if ((i+1 < ${#REPLIES[@]})); then
					# TODO: test these internal invalid errors (error when type=array references object, etc.)?
					:
				elif ((i+1 == ${#REPLIES[@]})); then
					case "$vmd_dtype" in
						object)
							bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' 'Was going to set-string, but found existing object'
							return
							;;
						array)
							bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' 'Was going to set-string, but found existing array'
							return
							;;
						*)
							bash_object.util.die 'ERROR_INTERNAL_INVALID_VOBJ' "Unexpected vmd_dtype '$vmd_dtype'"
							return
							;;
					esac
				fi
			# Otherwise, 'key_value' is a string
			else
				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 2 "BLOCK: STRING"
				fi

				if ((i+1 < ${#REPLIES[@]})); then
					# TODO error message
					bash_object.util.die 'ERROR_VALUE_NOT_FOUND' "Encountered string using accessor '$key', but expected to find either an object or array, in accordance with the filter"
					return
					:
				elif ((i+1 == ${#REPLIES[@]})); then
					current_object["$key"]="$final_value"
				fi
			fi
		fi

		bash_object.trace_current_object
		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			stdtrace.log 0 "END BLOCK"
		fi
	done
}
