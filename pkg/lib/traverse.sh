# shellcheck shell=bash

bash_object.traverse() {
	REPLY=
	local action="$1"
	local final_value_type="$2"
	shift 2

	local root_object_name="$1"
	local filter="$2"
	local final_value="$3" # Only used for 'set'

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
			cat >&3 <<-EOF
			  0. ----- -----
			  0. i+1: '$((i+1))'
			  0. \${#REPLIES[@]}: ${#REPLIES[@]}
			  0. current_object_name: '$current_object_name'
			  current_object=(
			EOF
			for debug_key in "${!current_object[@]}"; do
				cat >&3 <<-EOF
				   [$debug_key]='${current_object["$debug_key"]}'
				EOF
			done >&3
			cat >&3 <<-EOF
			  )
			EOF
		fi

		if [ "$action" = 'get' ]; then
			# We only want to actually get a value if we are on the last
			# element of the query
			# if ((i+1 == ${#REPLIES[@]})); then
			if [ ${current_object["$key"]+x} ]; then
				local key_value="${current_object["$key"]}"
			else
				echo 'Error: KEY NOT IN OBJECT'
				exit 1
			fi
			# fi
		elif [ "$action" = 'set' ]; then
			# If we are on the last element of the query, we now set the final
			# variable using '$final_value'
			if ((i+1 == ${#REPLIES[@]})); then
				current_object["$key"]="$final_value"
			else
				local jj=i+1
				succeeding_key="${REPLIES[$jj]}"
				declare -gA rename_this_inner_object=(["$succeeding_key"]='__placeholder__')
				current_object["$key"]=$'\x1C\x1Dtype=object;&rename_this_inner_object'

				local current_object_name="$new_object_name"

				declare current_object_name=rename_this_inner_object
				declare -n current_object="$current_object_name"

				continue
			fi
		fi

		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			cat >&3 <<-EOF
				  1. key: '$key'
				  1. key_value: '$key_value'
			EOF
		fi

		# If the 'key_value' is a virtual object, it starts with the two
		# character sequence
		if [ "${key_value::2}" = $'\x1C\x1D' ]; then
			virtual_item="${key_value#??}"
			local virtual_metadatas="${virtual_item%%&*}" # type=string;attr=smthn;
			local current_object_name="${virtual_item#*&}" # __bash_object_383028
			local -n current_object="$current_object_name"

			if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
				cat >&3 <<-EOF
				   2. virtual_item: '$virtual_item'"
				   2. virtual_metadatas: '$virtual_metadatas'
				   2. current_object_name: '$current_object_name'
				EOF
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
					cat >&3 <<-EOF
						3. vmd '$vmd'
						3. vmd_key '$vmd_key'
						3. vmd_value '$vmd_value'
					EOF
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

				break
			fi
		else
			# If an object or array is the last element of the query,
			# it is resolved above and this branch is not executed

			if [ "$action" = 'get' ]; then
				# Set 'REPLY' to '$key_value', but only if user wanted to get a string
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
				:
			fi
		fi
	done
}
