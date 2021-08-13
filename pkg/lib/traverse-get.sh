# shellcheck shell=bash

bash_object.traverse-get() {
	REPLY=

	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 ''
		stdtrace.log 0 "CALL: bash_object.traverse: $*"
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
		filter_stack+=("$key")

		bash_object.trace_loop

		# If 'key' is not a member of object, error
		if [ -z "${current_object["$key"]+x}" ]; then
			echo "Error: Key '$key' is not in object '$current_object_name'"
			exit 1
		# If 'key' is a member of object, then we check to see if it's an object, array, or string
		else
			local key_value="${current_object["$key"]}"

			if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
				stdtrace.log 1 "key: '$key'"
				stdtrace.log 1 "key_value: '$key_value'"
				stdtrace.log 1 "current_object_name: '$current_object_name'"
				stdtrace.log 1 "current_object=("
				for debug_key in "${!current_object[@]}"; do
					stdtrace.log 1 "  [$debug_key]='${current_object["$debug_key"]}'"
				done
				stdtrace.log 1 ")"
			fi

			# If the 'key_value' is a virtual object, it starts with the byte sequence
			# This means we will be setting either an object or an array
			if [ "${key_value::2}" = $'\x1C\x1D' ]; then
				virtual_item="${key_value#??}"

				bash_object.parse_virtual_object "$virtual_item"
				local current_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"

				local -n current_object="$current_object_name"

				# If we are not on the last element of the query, then do nothing. We have
				# already set 'current_object_name' and 'current_object', so at the next loop
				# iteration, the just-"dereferenced" virtual object will be evaluated
				if ((i+1 < ${#REPLIES[@]})); then
					:
				# If we are the last element, then we actually perform the get operation. Set
				# REPLY (and go to next loop)
				elif ((i+1 == ${#REPLIES[@]})); then
					if [ "$final_value_type" = object ]; then
						case "$vmd_dtype" in
						object)
							REPLY=("${current_object[@]}")
							;;
						array)
							printf '%s\n' "Error: 'A query for type 'object' was given, but an array was found"
							return 1
							;;
						esac
					elif [ "$final_value_type" = array ]; then
						case "$vmd_dtype" in
						object)
							printf '%s\n' "Error: 'A query for type 'array' was given, but an object was found"
							return 1
							;;
						array)
							# TODO: Perf: Use 'REPLY=("${current_object[@]}")'?
							local key=
							for key in "${!current_object[@]}"; do
								REPLY["$key"]="${current_object["$key"]}"
							done
							;;
						esac
					elif [ "$final_value_type" = string ]; then
						case "$vmd_dtype" in
						object)
							printf '%s\n' "Error: 'A query for type 'string' was given, but an object was found"
							return 1
							;;
						array)
							printf '%s\n' "Error: 'A query for type 'string' was given, but an array was found"
							return 1
							;;
						esac
					fi
				fi
			else
				# If we are getting a string

				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 2 "BLOCK: STRING"
				fi

				# If we are less than the last element in the query, and the object member has a type
				# of 'string', throw an error. This means the user expected an object to have a key
				# with type 'object', but the type really is 'string'
				if ((i+1 < ${#REPLIES[@]})); then
					:
				elif ((i+1 == ${#REPLIES[@]})); then
					local value="${current_object["$key"]}"
					if [ "$final_value_type" = object ]; then
						printf '%s\n' "Error: bash-object: A query for type 'object' was given, but a string was found"
						exit 1
					elif [ "$final_value_type" = array ]; then
						printf '%s\n' "Error: bash-object: A query for type 'array' was given, but a string was found"
						exit 1
					elif [ "$final_value_type" = string ]; then
						REPLY="$value"
					fi
				fi
			fi

			if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
				stdtrace.log 1 "current_object_name: '$current_object_name'"
				stdtrace.log 1 "current_object=("
				for debug_key in "${!current_object[@]}"; do
					stdtrace.log 1 "   [$debug_key]='${current_object["$debug_key"]}'"
				done
				stdtrace.log 1 ")"
				stdtrace.log 1 "final_value: '$final_value'"
				stdtrace.log 1 "END BLOCK 2"
			fi
		fi
	done
}
