# shellcheck shell=bash

bash_object.traverse-set() {
	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 ''
		stdtrace.log 0 "CALL: bash_object.traverse-set: $*"
	fi

	# TODO: errors if vmd_dtype, final_value_type is not one of the known ones

	local final_value_type="$1"
	local root_object_name="$2"
	local filter="$3"
	local final_value="$4"

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

		bash_object.trace_loop

		# If 'key' is not a member of object or index of array, error
		if [ -z "${current_object["$key"]+x}" ]; then
			# If we are before the last element in the query, then error
			if ((i+1 < ${#REPLIES[@]})); then
				echo "could not traverse property does not exist"
				return 2
			# 	# The variable is 'new_current_object_name', but it also could
			# 	# be the name of a new _array_
			# 	local new_current_object_name="__bash_object_${root_object_name}_tree_${key}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}"

			# 	# TODO: double-check if new_current_object_name only has underscores, dots, etc. (printf %q?)
			# 	if ! eval "declare -gA $new_current_object_name=()"; then
			# 		printf '%s\n' 'Error: bash-object: eval declare failed'
			# 		return 1
			# 	fi

			# 	current_object["$key"]=$'\x1C\x1D'"type=object;&$new_current_object_name"

			# 	current_object_name="$new_current_object_name"
			# 	# shellcheck disable=SC2178
			# 	local -n current_object="$new_current_object_name"
			# If we are at the last element in the query
			elif ((i+1 == ${#REPLIES[@]})); then
				if [ "$final_value_type" = object ]; then
					# TODO: late bash srandom
					local new_current_object_name="__bash_object_${root_object_name}_tree_${key}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}"

					# TODO: test if name is already used

					# TODO: double-check if new_current_object_name only has underscores, dots, etc. (printf %q?)

					# 1. Create object
					if ! eval "declare -gA $new_current_object_name=()"; then
						# TODO: error
						printf '%s\n' 'Error: bash-object: eval declare failed'
						return 1
					fi

					# 2. Create virtual object
					current_object["$key"]=$'\x1C\x1D'"type=object;&$new_current_object_name"

					local -n new_current_object="$new_current_object_name"
					local -n object_to_copy="$final_value"
					# test if the object_to_copy is of the right type
					for key in "${!object_to_copy[@]}"; do
						new_current_object["$key"]="${object_to_copy["$key"]}"
					done
				elif [ "$final_value_type" = array ]; then
					# local new_current_object_name="__bash_object_${root_object_name}_tree_${key}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}"
					# current_object["$key"]=$'\x1C\x1D'"type=array;&$new_current_object_name"

					# local -n new_array = "$final_value"
					:
					# current_object["$key"]=("${new_array[@]}")
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
