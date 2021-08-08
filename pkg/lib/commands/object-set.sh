# shellcheck shell=bash

bash_object.do-object-set() {
	REPLY=

	local root_object_name="$1"
	local filter="$2"
	local final_value="$3"

	# For the first iteration of the below for loop, the object will be set to
	# the root object. If there are any nested subobjects, then the object_name
	# will be reset
	local object_name="$root_object_name"
	local -n object="$root_object_name"


	bash_object.filter_parse "$filter"

	# Array of keys to 'apply' in the loop. Apply means we "follow the accessor" to
	# receive the underlying value
	local -a key_history=()

	local key=
	for ((i=0; i<${#REPLIES[@]}; i++)); do
		echo ------ >&3
		key="${REPLIES[$i]}"
		key_history+=("$key")

		echo a key: "$key" >&3
		# We continuously create subkeys, until we hit the last element in 'REPLIES'
		# when that occurs, we set the final value, since we arrived at the final accessor
		for ((j=0; j<${#key_history[@]}; j++)); do
			local history_item="${key_history[$j]}"

			# If we are at the end of the 'filter'
			echo rr $((j+1)) ${#REPLIES[@]} >&3
			if ((j+1 == ${#REPLIES[@]})); then
				echo key_history "${key_history[@]}" >&3
				for l in "${!object[@]}"; do
					echo "key  : $l"
					echo "value: ${object[$l]}"
				done >&3
				# TODO: make work for nested objects
				object["$history_item"]="$final_value"
			else
				# declare -A global_aa_1=([nested]='WOOF')
				declare -A OBJ=([my_key]="!'\`\"!type=string;&global_aa_1")

				# object_name="global_aa_1"
				local -n object="global_aa_1"
				# echo "AT ENDGAME '$history_item'" >&3
				# new_object_name="__bash_object_${key}_${SRANDOM}_fileNameAtCallSite_$SRANDOM"
				# declare -A "$new_object_name"
				# local -n new_object="$new_object_name"

				# if [ ${array[key]+x} ]; then
				# 	# exists
				# 	:
				# else
				# 	:
				# fi
				# # TODO: This overwrites previous entries due to a limitation of the storage
				# new_object["$history_item"]=

				# # Now, make sure this new object can be found from the original object
				# # The value is empty because there are more accessors
				# object["$key"]="!'\`\"!type=string;&$new_object_name"
				# object_name="$new_object_name"

				# echo finallllllllll "${OBJ[my_key]}" >&3
			fi
		done
	done
}
