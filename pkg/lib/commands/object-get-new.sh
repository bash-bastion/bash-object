# shellcheck shell=bash

bash_object.do-object-get-new() {
	REPLY=

	local final_value_type="$1"
	local root_object_name="$2"
	local filter="$3"

	local current_object_name="$root_object_name"
	local -n current_object="$current_object_name" # make 'current_object' a reference to the '$current_object_name' variable

	bash_object.filter_parse "$filter"
	for ((i=0; i<${#REPLIES[@]}; i++)); do
		local key="${REPLIES[$i]}"
		if [ ${current_object["$key"]+x} ]; then
			local key_value="${current_object["$key"]}"
		else
			echo 'Error: KEY NOT IN OBJECT'
			exit 1
		fi

		cat >&3 <<-EOF
		  1. key: '$key'
		  1. key_value: '$key_value'
		EOF

		# If the 'key_value' is a virtual object, it must start with a two character sequence
		if [ "${key_value::2}" = $'\x1C\x1D' ]; then
			key_value="${key_value#??}"

			# Loop over each item in the virtual object
			while IFS= read -rd $'\x1D' virtual_item; do
				# if [[ "$virtual_item" = $'\x1C' || -z "$virtual_item" ]]; then
				# 	continue
				# fi

				echo "    2. virtual_item: '$virtual_item'" >&3

				local virtual_metadatas="${key_value%%&*}" # type=string;attr=smthn;
				local virtual_ref="${key_value#*&}" # __bash_object_383028
				virtual_ref="${virtual_ref%?}" # TODO: hack

				cat >&3 <<-EOF
				    2. virtual_metadatas: '$virtual_metadatas'
				    2. virtual_ref: '$virtual_ref'
				EOF

				local vmd_dtype=

				while IFS= read -rd \; vmd; do
					if [ -z "$vmd" ]; then
						continue
					fi

					vmd="${vmd%;}"
					vmd_key="${vmd%%=*}"
					vmd_value="${vmd#*=}"

					cat >&3 <<-EOF
					      3. vmd '$vmd'
					      3. vmd_key '$vmd_key'
					      3. vmd_value '$vmd_value'
					EOF

					case "$vmd_key" in
						type) vmd_dtype="$vmd_value" ;;
					esac
				done <<< "$virtual_metadatas"

				# If the key has the correct type
				if [ "$vmd_dtype" = "$final_value_type" ]; then
						current_object_name="$virtual_ref"
						local -n current_object="$current_object_name"
				else
					echo "Error: NOT CORRECT TYPE"
					exit 1
				fi
			done < <(printf '%s' "$key_value")
		else
			# TODO: test if we try to access a "property" of this string. in other words,
			# we expected to find an object, but it really is a string

			# If the string does not represent a reference, then it is a normal string
			REPLY="$key_value"
			break
		fi
	done
}
