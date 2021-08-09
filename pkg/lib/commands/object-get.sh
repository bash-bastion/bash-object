# shellcheck shell=bash

bash_object.do-object-get() {
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

		# cat >&3 <<-EOF
		#   1. key: '$key'
		#   1. key_value: '$key_value'
		# EOF

		# If the 'key_value' is a virtual object, it must start with a two character sequence
		if [ "${key_value::2}" = $'\x1C\x1D' ]; then
			key_value="${key_value#??}"
			virtual_item="$key_value"


			# echo "    2. virtual_item: '$virtual_item'" >&3

			local virtual_metadatas="${key_value%%&*}" # type=string;attr=smthn;
			local virtual_ref="${key_value#*&}" # __bash_object_383028

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

			# echo aaa $i ${#REPLIES[@]} >&3
			if ((i == ${#REPLIES[@]}-1)); then
				value_type="$(declare -p "$current_object_name")"
				# echo vcvv "$value_type" >&3
				case "$value_type" in
					'declare -A '*|'declare -a '*)
						REPLY=("${current_object[@]}")
						break
					;;
				esac
				# echo found here >&3
				# for h in "${!REPLIES[@]}"; do
				# 	echo "--key  : $h"
				# 	echo "--value: ${REPLIES[$h]}"
				# done >&3

				# REPLY=("${current_objet[@]}")
				# continue
			fi
		else
			REPLY="$key_value"
			# TODO: test if we try to access a "property" of this string. in other words,
			# we expected to find an object, but it really is a string

			# If the string does not represent a reference, then it is a normal string
			break
		fi
	done
}
