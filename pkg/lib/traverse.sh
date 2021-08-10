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
			if [ ${current_object["$key"]+x} ]; then
				local key_value="${current_object["$key"]}"
			else
				echo 'Error: KEY NOT IN OBJECT'
				exit 1
			fi
		elif [ "$action" = 'set' ]; then
			# if last leg
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

	# If the 'key_value' is a virtual object, it start with the two
	# character sequence
	if [ "${key_value::2}" = $'\x1C\x1D' ]; then
		virtual_item="${key_value#??}"

		local virtual_metadatas="${virtual_item%%&*}" # type=string;attr=smthn;
		local virtual_ref="${virtual_item#*&}" # __bash_object_383028

		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			cat >&3 <<-EOF
			    2. virtual_item: '$virtual_item'"
			    2. virtual_metadatas: '$virtual_metadatas'
			    2. virtual_ref: '$virtual_ref'
			EOF
		fi

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

		current_object_name="$virtual_ref"
		local -n current_object="$current_object_name"

		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			cat >&3 <<-EOF
			        4. current_object_name: '$current_object_name'
			EOF
		fi

		if ((i == ${#REPLIES[@]}-1)); then
			case "$vmd_dtype" in
				object|array)
					# TODO: not valid for associative arrays?
					REPLY=("${current_object[@]}")
					break
					;;
			esac
		fi
	else
		# shellcheck disable=SC2178
		REPLY="$key_value"
		# TODO: test if we try to access a "property" of this string. in other words,
		# we expected to find an object, but it really is a string

		# If the string does not represent a reference, then it is a normal string
		break
	fi
	done
}
