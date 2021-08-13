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

		# If 'key' is not a member of object, create the object, and set it
		if [ -z "${current_object["$key"]+x}" ]; then
			# If we are before the last element in the query, then set
			if ((i+1 < ${#REPLIES[@]})); then
				# The variable is 'new_current_object_name', but it also could
				# be the name of a new _array_
				local new_current_object_name="__bash_object_${root_object_name}_tree_${key}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}"

				# TODO: double-check if new_current_object_name only has underscores, dots, etc. (printf %q?)
				if ! eval "declare -gA $new_current_object_name=()"; then
					printf '%s\n' 'Error: bash-object: eval declare failed'
					exit 1
				fi

				current_object["$key"]=$'\x1C\x1D'"type=object;&$new_current_object_name"

				current_object_name="$new_current_object_name"
				# shellcheck disable=SC2178
				local -n current_object="$new_current_object_name"
			# If we are at the last element in the query
			elif ((i+1 == ${#REPLIES[@]})); then
				# TODO: object, arrays
				current_object["$key"]="$final_value"
			fi
		# If 'key' is already a member of object, use it if it's a virtual object. If
		# it's not a virtual object, then a throw an error
		else
			if ((i+1 < ${#REPLIES[@]})); then
				local key_value="${current_object["$key"]}"

				if [ "${key_value::2}" = $'\x1C\x1D' ]; then
					virtual_item="${key_value#??}"

					bash_object.parse_virtual_object "$virtual_item"
					local current_object_name="$REPLY1"
					local vmd_dtype="$REPLY2"

					local -n current_object="$current_object_name"

					# Get the next value (number, string), and construct the next
					# element accordingly
					case "$vmd_dtype" in
						object)
							;;
						array) ;;
					esac
				else
					# TODO: throw error
					echo "phi" >&3
					exit 1
				fi
				:
			elif ((i+1 == ${#REPLIES[@]})); then
				local key_value="${current_object["$key"]}"

				if [ "${key_value::2}" = $'\x1C\x1D' ]; then
					virtual_item="${key_value#??}"

					bash_object.parse_virtual_object "$virtual_item"
					local current_object_name="$REPLY1"
					local vmd_dtype="$REPLY2"

					local -n current_object="$current_object_name"

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
							exit 1
							;;
						array)
							echo "Error: Cannot set string on array"
							exit 1
							;;
						esac
					fi
					current_object["$key"]="$final_value"
				else
					# TODO: throw error
					echo "omicron" >&3
					exit 1
				fi
			fi
		fi

		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			stdtrace.log 1 'AFTER OPERATION'
			stdtrace.log 1 "current_object_name: '$current_object_name'"
			stdtrace.log 1 "current_object=("
			for debug_key in "${!current_object[@]}"; do
				stdtrace.log 1 "  [$debug_key]='${current_object["$debug_key"]}'"
			done
			stdtrace.log 1 ")"
		fi
	done
}
