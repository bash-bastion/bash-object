# shellcheck shell=bash

bash_object.do-object-get() {
	REPLY=

	local root_object_name="$1"
	local filter="$2"

	local current_object_name="$root_object_name"
	local -n current_object="$current_object_name"

	bash_object.filter_parse "$filter"
	for ((i=0; i<${#REPLIES[@]}; i++)); do
		local key="${REPLIES[$i]}"
		if [ ${current_object["$key"]+x} ]; then
			local key_value="${current_object["$key"]}"
		else
			echo 'Error: KEY NOT IN OBJECT'
			exit 1
		fi

		# cat >&3 <<-EOF
		#   1. key: '$key'
		#   1. key_value: '$key_value'
		# EOF

		# If the 'key_value' is a virtual object, it start with the two
		# character sequence
		if [ "${key_value::2}" = $'\x1C\x1D' ]; then
			virtual_item="${key_value#??}"

			# echo "    2. virtual_item: '$virtual_item'" >&3

			local virtual_metadatas="${virtual_item%%&*}" # type=string;attr=smthn;
			local virtual_ref="${virtual_item#*&}" # __bash_object_383028

			# cat >&3 <<-EOF
			#     2. virtual_metadatas: '$virtual_metadatas'
			#     2. virtual_ref: '$virtual_ref'
			# EOF

			local vmd_dtype=

			while IFS= read -rd \; vmd; do
				if [ -z "$vmd" ]; then
					continue
				fi

				vmd="${vmd%;}"
				vmd_key="${vmd%%=*}"
				vmd_value="${vmd#*=}"

				# cat >&3 <<-EOF
				#       3. vmd '$vmd'
				#       3. vmd_key '$vmd_key'
				#       3. vmd_value '$vmd_value'
				# EOF

				case "$vmd_key" in
					type) vmd_dtype="$vmd_value" ;;
				esac
			done <<< "$virtual_metadatas"

			current_object_name="$virtual_ref"
			local -n current_object="$current_object_name"

			# cat >&3 <<-EOF
			#         4. current_object_name: '$current_object_name'
			# EOF

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
