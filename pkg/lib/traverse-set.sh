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

	# TODO: test, old versions of bash
	if [[ ! -v 4 ]]; then
			bash_object.util.die 'ERROR_INTERNAL_MISCELLANEOUS' "final_value is empty"
			return
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
					if bash_object.ensure.variable_does_exist "$final_value[@]"; then :; else
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
					if bash_object.ensure.variable_does_exist "$final_value[@]"; then :; else
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
					bash_object.util.die 'ERROR_INTERNAL_INVALID_PARAM' "final_value_type: $final_value_type"
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
							bash_object.util.die 'ERROR_INTERNAL_INVALID_VOBJ' "vmd_dtype: $vmd_dtype"
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
					echo "omicron" >&3
					:
				elif ((i+1 == ${#REPLIES[@]})); then
					if [ "$final_value_type" = object ]; then
						case "$vmd_dtype" in
						object)

							;;
						array)
							;;
						esac
					elif [ "$final_value_type" = array ]; then
						case "$vmd_dtype" in
						object)
							;;
						array)
							;;
						esac
					elif [ "$final_value_type" = string ]; then
						case "$vmd_dtype" in
						object)
							# TODO: test this
							echo "Error: Cannot set string on object"
							return 1
							;;
						array)
							echo "Error: Cannot set string on array"
							return 1
							;;
						esac
					fi
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
