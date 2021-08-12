# shellcheck shell=bash

bash_object.traverse() {
	REPLY=
	local flag_variable=

	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 "CALL: bash_object.traverse: $*"
	fi

	# shellcheck disable=SC1007
	local currentArg= nextArg=
	for ((i=0; i<$#; i++)); do
		currentArg="${!i}"
		nextArg=$((i+1)); nextArg="${!nextArg}"

		case "$currentArg" in
			--variable)
				flag_variable="$nextArg"
				shift 2
				;;
		esac
	done

	local action="$1"
	local final_value_type="$2"
	local root_object_name="$3"
	local filter="$4"
	local final_value="${5:-}" # Only used for 'set'

	# Start traversing at the root object
	local current_object_name="$root_object_name"
	local -n current_object="$root_object_name"

	case "$filter" in
		*']'*) bash_object.parse_filter --advanced "$filter" ;;
		*) bash_object.parse_filter --simple "$filter" ;;
	esac
	for ((i=0; i<${#REPLIES[@]}; i++)); do
		local key="${REPLIES[$i]}"

		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			stdtrace.log 0 "loop iteration start"
			stdtrace.log 0 "i+1: '$((i+1))'"
			stdtrace.log 0 "\${#REPLIES[@]}: ${#REPLIES[@]}"
			stdtrace.log 0 "key: '$key'"
			stdtrace.log 0 "current_object_name: '$current_object_name'"
			stdtrace.log 0 "current_object=("
			for debug_key in "${!current_object[@]}"; do
				stdtrace.log 0 "  [$debug_key]='${current_object["$debug_key"]}'"
			done
			stdtrace.log 0 ")"
			stdtrace.log 0 "final_value: '$final_value'"
		fi

		# In 'get' mode, the object is already supposed to have the proper hierarchy. If
		# it does, then 'get' the subkey we are supposed to get with the query element
		# If the subkey doesn't exist, create it if we are in 'set' mode,
		# and throw error if we are in 'get' mode

		if [ "$action" = 'get' ]; then
			if [ ${current_object["$key"]+x} ]; then
				# Set the key_value; we will be using this variable in this
				# loop iteration when testing if 'key_value' is a virtual object
				local key_value="${current_object["$key"]}"

				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 1 "key_value: '$key_value'"
				fi
			else
				echo "Error: Key '$key' is not in object '$current_object_name'"
				exit 1
			fi
		elif [ "$action" = 'set' ]; then
			# When setting a value,
			if ((i+1 == ${#REPLIES[@]})); then
				# TODO: object, arrays
				current_object["$key"]="$final_value"

				# continue
			else
				# The variable is 'new_current_object_name', but it also could
				# be the name of a new _array_
				local new_current_object_name="__bash_object_${root_object_name}_tree_${key}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}"

				# TODO: double-check if new_current_object_name only has underscores, dots, etc. (printf %q?)

				if ! eval "declare -gA $new_current_object_name=()"; then
					printf '%s\n' 'Error: bash-object: eval declare failed'
					exit 1
				fi
				# local -n new_current_object="$new_current_object_name"

				current_object["$key"]=$'\x1C\x1D'"type=object;&$new_current_object_name"

				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 1 "current_object_name: '$current_object_name'"
					stdtrace.log 1 "current_object=("
					for debug_key in "${!current_object[@]}"; do
						stdtrace.log 1 "  [$debug_key]='${current_object["$debug_key"]}'"
					done
					stdtrace.log 1 ")"
					stdtrace.log 1 "final_value: '$final_value'"
				fi

				current_object_name="$new_current_object_name"
				# shellcheck disable=SC2178
				local -n current_object="$new_current_object_name"

				# Either the object or array has been created. We skip to
				# the next element in the query
				continue
			fi
		fi

		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			stdtrace.log 0 "key: '$key'"
			stdtrace.log 0 "current_object_name: '$current_object_name'"
			stdtrace.log 0 "current_object=("
			for debug_key in "${!current_object[@]}"; do
				stdtrace.log 0 "  [$debug_key]='${current_object["$debug_key"]}'"
			done
			stdtrace.log 0 ")"
		fi

		# If the 'key_value' is a virtual object, it starts with the two
		# character sequence
		if [ "${key_value::2}" = $'\x1C\x1D' ]; then
			virtual_item="${key_value#??}"
			local virtual_metadatas="${virtual_item%%&*}" # type=string;attr=smthn;
			local current_object_name="${virtual_item#*&}" # __bash_object_383028
			local -n current_object="$current_object_name"

			if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
				stdtrace.log 1 "block: virtual object"
				stdtrace.log 1 "virtual_item: '$virtual_item'"
				stdtrace.log 1 "virtual_metadatas: '$virtual_metadatas'"
				stdtrace.log 1 "current_object_name: '$current_object_name'"
			fi

			# Parse info about the virtual object
			local vmd_dtype=
			while IFS= read -rd \; vmd; do
				if [ -z "$vmd" ]; then
					continue
				fi

				vmd="${vmd%;}"
				vmd_key="${vmd%%=*}"
				vmd_value="${vmd#*=}"

				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 2 "vmd: '$vmd'"
					stdtrace.log 3 "vmd_key: '$vmd_key'"
					stdtrace.log 3 "vmd_value: '$vmd_value'"
				fi

				case "$vmd_key" in
					type) vmd_dtype="$vmd_value" ;;
				esac
			done <<< "$virtual_metadatas"

			# If we are on the last element of the query, it means we are supposed
			# to return an object or array
			if ((i+1 == ${#REPLIES[@]})); then
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
						printf '%s\n' "Error: 'A query for type 'object' was given, but an object was found"
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

				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 1 "end block"
				fi

				break
			else
				# If we are on anything but the last element of the query, then continue to next item
				:
			fi
		else
			if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
				stdtrace.log 1 "block: string"
			fi

			if [ "$action" = 'get' ]; then
				if [ "$final_value_type" = object ]; then
					printf '%s\n' "Error: 'A query for type '$final_value_type' was given, but a string was found"
					return 1
				elif [ "$final_value_type" = array ]; then
					printf '%s\n' "Error: 'A query for type '$final_value_type' was given, but a string was found"
					return 1
				elif [ "$final_value_type" = string ]; then
					REPLY="$key_value"
				fi
			elif [ "$action" = 'set' ]; then
				current_object["$key"]="$final_value"
			fi

			if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
				stdtrace.log 1 "current_object_name: '$current_object_name'"
				stdtrace.log 1 "current_object=("
				for debug_key in "${!current_object[@]}"; do
					stdtrace.log 1 "  [$debug_key]='${current_object["$debug_key"]}'"
				done
				stdtrace.log 1 ")"
				stdtrace.log 1 "final_value: '$final_value'"
				stdtrace.log 1 "end block"
			fi
		fi

		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			stdtrace.log 0 "loop iteration end"
		fi
	done
}
