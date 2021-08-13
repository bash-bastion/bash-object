# shellcheck shell=bash

bash_object.traverse-get() {
	unset REPLY

	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 ''
		stdtrace.log 0 "CALL: bash_object.traverse-get: $*"
	fi

	local final_value_type="$1"
	local root_object_name="$2"
	local filter="$3"

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
		local is_index_of_array='no'

		filter_stack+=("$key")

		bash_object.trace_loop

		if [ "${key::1}" = $'\x1C' ]; then
			key="${key#?}"
			is_index_of_array='yes'
		fi

		# If 'key' is not a member of object or index of array, error
		if [ -z "${current_object["$key"]+x}" ]; then
			echo "Error: Key '$key' is not in object '$current_object_name'"
			exit 1
		else
		# If 'key' is a member of an object, or index of array
			if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
				stdtrace.log 2 "BLOCK: OBJECT/ARRAY"
			fi

			local key_value="${current_object["$key"]}"

			# If the 'key_value' is a virtual object, it starts with the byte sequence
			# This means we will be setting either an object or an array
			if [ "${key_value::2}" = $'\x1C\x1D' ]; then
				virtual_item="${key_value#??}"

				bash_object.parse_virtual_object "$virtual_item"
				local current_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"

				local -n current_object="$current_object_name"

				if ((i+1 < ${#REPLIES[@]})); then
					# TODO: test these internal invalid errors
					# Do nothing (assuming the type is correct), we have already set 'current_object'
					# for the next iteration
					case "$vmd_dtype" in
					object)
						if [ "$is_index_of_array" = yes ]; then
							bash_object.util.traverse_fail 'ERROR_INTERNAL_INVALID_VOBJ' "Expected object, but reference to array was found"
							return
						fi
						;;
					array)
						if [ "$is_index_of_array" = no ]; then
							bash_object.util.traverse_fail 'ERROR_INTERNAL_INVALID_VOBJ' "Expected array, but reference to object was found"
							return
						fi
						;;
					*)
						bash_object.util.traverse_fail 'ERROR_INTERNAL_INVALID_VOBJ' "vmd_dtype: $vmd_dtype"
						return
						;;
					esac
				elif ((i+1 == ${#REPLIES[@]})); then
					# We are last element of query, return the object
					if [ "$final_value_type" = object ]; then
						case "$vmd_dtype" in
						object)
							REPLY=("${current_object[@]}")
							;;
						array)
							bash_object.util.traverse_fail 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for object, but found array'
							return
							;;
						*)
							bash_object.util.traverse_fail 'ERROR_INTERNAL_INVALID_VOBJ' "vmd_dtype: $vmd_dtype"
							return
							;;
						esac
					elif [ "$final_value_type" = array ]; then
						case "$vmd_dtype" in
						object)
							bash_object.util.traverse_fail 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for array, but found object'
							return
							;;
						array)
							declare -ga REPLY=()
							local key=
							for key in "${!current_object[@]}"; do
								REPLY["$key"]="${current_object["$key"]}"
							done
							;;
						*)
							bash_object.util.traverse_fail 'ERROR_INTERNAL_INVALID_VOBJ' "vmd_dtype: $vmd_dtype"
							return
							;;
						esac
					elif [ "$final_value_type" = string ]; then
						case "$vmd_dtype" in
						object)
							bash_object.util.traverse_fail 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for string, but found object'
							return
							;;
						array)
							bash_object.util.traverse_fail 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for string, but found array'
							return
							;;
						*)
							bash_object.util.traverse_fail 'ERROR_INTERNAL_INVALID_VOBJ' "vmd_dtype: $vmd_dtype"
							return
						esac
					else
						bash_object.util.traverse_fail 'ERROR_INTERNAL_INVALID_PARAM' "final_value_type: $final_value_type"
						return
					fi
				fi
			# Otherwise, 'key_value' is a string
			else
				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 2 "BLOCK: STRING"
				fi

				if ((i+1 < ${#REPLIES[@]})); then
					# TODO
					echo "mu" >&3
					exit 2
					:
				elif ((i+1 == ${#REPLIES[@]})); then
					local value="${current_object["$key"]}"
					if [ "$final_value_type" = object ]; then
						bash_object.util.traverse_fail 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for object, but found string'
						return
					elif [ "$final_value_type" = array ]; then
						bash_object.util.traverse_fail 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for array, but found string'
						return
					elif [ "$final_value_type" = string ]; then
						REPLY="$value"
					fi
				fi
			fi

			bash_object.trace_current_object
			if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
				stdtrace.log 0 "END BLOCK"
			fi
		fi
	done
}
