# shellcheck shell=bash

bash_object.traverse() {
	local action="$1"
	shift
	if [ "$action" = 'object-get' ]; then
		REPLY=

		local root_object_name="$1"
		local filter="$2"

		local current_object_name="$root_object_name"
		local -n current_object="$current_object_name"

		bash_object.parse_filter -s "$filter"
		for ((i=0; i<${#REPLIES[@]}; i++)); do
			local key="${REPLIES[$i]}"
			if [ ${current_object["$key"]+x} ]; then
				local key_value="${current_object["$key"]}"
			else
				# echo gett ----- >&3
				# for ss in "${!OBJ[@]}"; do
				# 	echo "key  : $ss"
				# 	echo "value: ${OBJ[$ss]}"
				# done >&3


				# echo "ddd get '$key'" >&3

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
	elif [ "$action" = 'object-set' ]; then
		REPLY=

		local root_object_name="$1"
		local filter="$2"
		local final_value="$3"

		local current_object_name="$root_object_name"
		local -n current_object="$current_object_name"

		bash_object.parse_filter -s "$filter"
		for ((i=0; i<${#REPLIES[@]}; i++)); do
			local key="${REPLIES[$i]}"
			# if key exists in object
			# TODO: test for overrides
			# if [ ${current_object["$key"]+x} ]; then
				:
				# local key_value="${current_object["$key"]}"
			# else
				# --------------- SET
				# construct the object
				# echo 'Error: KEY NOT IN OBJECT'
				# exit 1
				# if last leg
				echo aaaaaa $i $((${#REPLIES[@]}-1)) >&3
				if ((i == ${#REPLIES[@]}-1)); then
					echo "fooooo '$key'" >&3
					current_object["$key"]="$final_value"
					# return
					# local key_value="${current_object["$key"]}"
				else
					# reference
					# declare -A inner_object=([cool]='Wolf 359')
					# declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

					# construct the virtual object
					echo "ddd set '$key'" >&3
					local jj=i+1
					succeeding_key="${REPLIES[$jj]}"
					# The 'placeholder' is supposed to be set on the next iteration in the branch directly above this
					# local new_object_name="__bash_object_$RANDOM_$RANDOM"
					# local -n new_object="$new_object_name"

					declare -gA rename_this_inner_object=(["$succeeding_key"]='__placeholder__')
					# new_object["$succeeding_key"]='__placeholder__'
					# eval "declare -gA $new_object_name=([$succeeding_key]='__placeholder__')"
					# local -n new_object="$new_object_name"

					current_object["$key"]=$'\x1C\x1Dtype=object;&rename_this_inner_object'
					# new_object["$key"]=$'\x1C\x1Dtype=object;&'"$new_object_name"



					local current_object_name="$new_object_name"
					# declare -n current_object="$current_object_name"

					declare current_object_name=rename_this_inner_object
					declare -n current_object="$current_object_name"
					echo set ----- >&3
					for ss in "${!current_object[@]}"; do
						echo "key  : $ss"
						echo "value: ${current_object[$ss]}"
					done >&3
					continue
				fi
			# fi

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

				# if we are on the last leg
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
	fi
}
