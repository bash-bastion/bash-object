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

	# Ensure correct number of arguments have been passed
	if (( $# != 3)); then
		bash_object.util.die 'ERROR_INVALID_ARGS' "Expected '3' arguments, but received '$#'"
		return
	fi

	# Ensure parameters are not empty
	if [ -z "$final_value_type" ]; then
		bash_object.util.die 'ERROR_INVALID_ARGS' "Positional parameter '1' is empty. Please check passed parameters"
		return
	fi
	if [ -z "$root_object_name" ]; then
		bash_object.util.die 'ERROR_INVALID_ARGS' "Positional parameter '2' is empty. Please check passed parameters"
		return
	fi
	if [ -z "$filter" ]; then
		bash_object.util.die 'ERROR_INVALID_ARGS' "Positional parameter '3' is empty. Please check passed parameters"
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

		# TODO: redo filter_stack string, and use stdlib.arrayprint TODO
		local oldIFS="$IFS"
		IFS='_'
		local filter_stack_string="${filter_stack[*]}"
		IFS="$oldIFS"

		bash_object.trace_loop

		local is_index_of_array='no'
		if [ "${key::1}" = $'\x1C' ]; then
			key="${key#?}"
			is_index_of_array='yes'
		fi

		# If 'key' is not a member of object or index of array, error
		if [ -z "${current_object["$key"]+x}" ]; then
			bash_object.util.die 'ERROR_VALUE_NOT_FOUND' "Key or index '$key' is not in '$filter_stack_string'"
			return
		# If 'key' is a member of an object or index of array
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
					# TODO: test these internal invalid errors (error when type=array references object, etc.)
					# Do nothing (assuming the type is correct), we have already set 'current_object'
					# for the next iteration
					:
					# case "$vmd_dtype" in
					# object)
					# 	if [ "$is_index_of_array" = yes ]; then
					# 		bash_object.util.die 'ERROR_INTERNAL_INVALID_VOBJ' "Expected object, but reference to array was found"
					# 		return
					# 	fi
					# 	;;
					# array)
					# 	if [ "$is_index_of_array" = no ]; then
					# 		bash_object.util.die 'ERROR_INTERNAL_INVALID_VOBJ' "Expected array, but reference to object was found"
					# 		return
					# 	fi
					# 	;;
					# *)
					# 	bash_object.util.die 'ERROR_INTERNAL_INVALID_VOBJ' "Unexpected vmd_dtype '$vmd_dtype'"
					# 	return
					# 	;;
					# esac
				elif ((i+1 == ${#REPLIES[@]})); then
					# We are last element of query, return the object
					if [ "$final_value_type" = object ]; then
						case "$vmd_dtype" in
						object)
							declare -gA REPLY=()
							local key=
							for key in "${!current_object[@]}"; do
								REPLY["$key"]="${current_object["$key"]}"
							done
							;;
						array)
							bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for object, but found existing array'
							return
							;;
						*)
							bash_object.util.die 'ERROR_INTERNAL_INVALID_VOBJ' "Unexpected vmd_dtype '$vmd_dtype'"
							return
							;;
						esac
					elif [ "$final_value_type" = array ]; then
						case "$vmd_dtype" in
						object)
							bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for array, but found existing object'
							return
							;;
						array)
							declare -ga REPLY=()
							# shellcheck disable=SC2190
							REPLY=("${current_object[@]}")
							;;
						*)
							bash_object.util.die 'ERROR_INTERNAL_INVALID_VOBJ' "Unexpected vmd_dtype '$vmd_dtype'"
							return
							;;
						esac
					elif [ "$final_value_type" = string ]; then
						case "$vmd_dtype" in
						object)
							bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for string, but found existing object'
							return
							;;
						array)
							bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' 'Queried for string, but found existing array'
							return
							;;
						*)
							bash_object.util.die 'ERROR_INTERNAL_INVALID_VOBJ' "Unexpected vmd_dtype '$vmd_dtype'"
							return
						esac
					else
						bash_object.util.die 'ERROR_INTERNAL_INVALID_PARAM' "Unexpected final_value_type '$final_value_type'"
						return
					fi
				fi
			# Otherwise, 'key_value' is a string
			else
				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 2 "BLOCK: STRING"
				fi

				if ((i+1 < ${#REPLIES[@]})); then
					# Means the query is one level deeper than expected. Expected
					# object/array, but got string
					# TODO
					echo "mu '$key_value'" >&3
					# return 2
				elif ((i+1 == ${#REPLIES[@]})); then
					local value="${current_object["$key"]}"
					if [ "$final_value_type" = object ]; then
						bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "Queried for object, but found existing string '$value'"
						return
					elif [ "$final_value_type" = array ]; then
						bash_object.util.die 'ERROR_VALUE_INCORRECT_TYPE' "Queried for array, but found existing string '$value'"
						return
					elif [ "$final_value_type" = string ]; then
						# shellcheck disable=SC2178
						REPLY="$value"
					fi
				fi
			fi
		fi

		bash_object.trace_current_object
		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			stdtrace.log 0 "END BLOCK"
		fi
	done
}
