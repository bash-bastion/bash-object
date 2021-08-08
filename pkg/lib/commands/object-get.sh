# shellcheck shell=bash

bash_object.do-object-get() {
	REPLY=

	local root_object_name="$1"
	local filter="$2"

	# For the first iteration of the below for loop, the object will be set to
	# the root object. If there are any nested subobjects, then the object_name
	# will be reset
	local object_name="$root_object_name"
	local -n object="$root_object_name"

	# shellcheck disable=SC1007
	local metadata_string= new_object_name= d_type=
	local -a metadata_array=()

	bash_object.filter_parse "$filter"
	# for key in "${REPLIES[@]}"; do
	for ((i=0; i<${#REPLIES[@]}; i++)); do
		key="${REPLIES[$i]}"
		# 'key_value' is either
		#   1. An actual string
		#   2. A reference to another variable (associative / indexed arrays) (in the form of a string)
		#   3. An index or associative array
		local key_value="${object["$key"]}"

		# key_value is a string
		if [ "${key_value::5}" == '!'\'\`\"'!' ]; then
			key_value="${key_value:5}"
			metadata_string="${key_value%%&*}"
			new_object_name="${key_value#*&}"

			# Corresponds to 'type' in metadata
			d_type=

			# TODO :( ?
			readarray -d\; metadata_array < <(printf '%s' "$metadata_string")
			for md in "${metadata_array[@]}"; do
				if [ -z "$md" ]; then
					continue
				fi

				md="${md%;}"

				# Right now, 'md' looks like: 'type=string'
				md_key="${md%%=*}"
				md_value="${md#*=}"

				case "$md_key" in
					type) d_type="$md_value" ;;
				esac
			done

			# TODO: Validate something with d_type

			object_name="$new_object_name"
			local -n object="$new_object_name"

			if ((i == ${#REPLIES[@]}-1)); then
				value_type="$(declare -p "$object_name")"
				 case "$value_type" in
					'declare -A '*|'declare -a '*)
						REPLY=("${object[@]}")
						break
					;;
				esac
			fi
		else
			REPLY="$key_value"
			break
		fi
	done
}
