# shellcheck shell=bash

bash_object.traverse-set() {
	# TODO: rename zerocopy, as it's misleading - ex. 'zerocopy' object would be slower
	local flag_zerocopy='no'

	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 ''
		stdtrace.log 0 "CALL: bash_object.traverse-set: $*"
	fi

	local final_value_type="$1"
	local root_object_name="$2"
	local filter="$3"
	local final_value="$4"

	if (( $# != 4)); then
		bash_object.util.die 'ERROR_INVALID_ARGS' "Expected '4' arguments, but received '$#'"
		return
	fi

	# TODO: zerocopy check
	# Ensure parameters are not empty
	if [ "$flag_zerocopy" = no ]; then
		for ((i=1; i<=$#; i++)); do
			if [ -z "${!i}" ]; then
				bash_object.util.die 'ERROR_INVALID_ARGS' "Positional parameter '$i' is empty. Please check passed parameters"
				return
			fi
		done
	elif [ "$flag_zerocopy" = yes ]; then
		# If we are zerocopying, it means the string or array is passed on the
		# command line; we don't check it since the string or the first element
		# of array or string could be empty
		for ((i=1; i<=$#-1; i++)); do
		if [ -z "${!i}" ]; then
			bash_object.util.die 'ERROR_INVALID_ARGS' "Positional parameter '$i' is empty. Please check passed parameters"
			return
		fi
		done
	else
		bash_object.util.die 'ERROR_INTERNAL_MISCELLANEOUS' "Unexpected final_value_type '$final_value_type   $actual_final_value_type'"
		return
	fi

	if [ -n "${VERIFY_BASH_OBJECT+x}" ]; then
		# Ensure the root object exists, and is an associative array
		local root_object_type=
		if root_object_type="$(declare -p "$root_object_name" 2>/dev/null)"; then :; else
			bash_object.util.die 'ERROR_VALUE_NOT_FOUND' "The associative array '$root_object_name' does not exist"
			return
		fi
		root_object_type="${root_object_type#declare -}"
		if [ "${root_object_type::1}" != 'A' ]; then
			bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "The 'root object' must be an associative array"
			return
		fi

		# TODO: dont' do this in zerocopy mode
		# Ensure the 'final_value' is the same type as specified by the user
		if [ "$final_value_type" != string ]; then # remove this conditional when consistency and zerocopy mode
			local actual_final_value_type=
			if ! actual_final_value_type="$(declare -p "$final_value" 2>/dev/null)"; then
				bash_object.util.die 'ERROR_VALUE_NOT_FOUND' "The variable '$final_value' does not exist"
				return
			fi
			actual_final_value_type="${actual_final_value_type#declare -}"
			case "${actual_final_value_type::1}" in
				A) actual_final_value_type='object' ;;
				a) actual_final_value_type='array' ;;
				-) actual_final_value_type='string' ;;
				*) actual_final_value_type='other' ;;
			esac

			if [ "$final_value_type" == object ]; then
				if [ "$actual_final_value_type" != object ]; then
					bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "Argument 'set-$final_value_type' was specified, but a variable with type '$actual_final_value_type' was passed"
					return
				fi
			elif [ "$final_value_type" == array ]; then
				if [ "$actual_final_value_type" != array ]; then
					bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "Argument 'set-$final_value_type' was specified, but a variable with type '$actual_final_value_type' was passed"
					return
				fi
			# TODO: currently extraneous, but needed after 'zerocopy' implementation
			elif [ "$final_value_type" == string ]; then
				if [ "$actual_final_value_type" != string ]; then
					bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "Argument 'set-$final_value_type' was specified, but a variable with type '$actual_final_value_type' was passed"
					return
				fi
			else
				bash_object.util.die 'ERROR_INTERNAL_INVALID_PARAM' "Unexpected final_value_type '$final_value_type'"
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
