# shellcheck shell=bash

bash_object.traverse-get() {
	unset REPLY; REPLY=

	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		bash_object.trace_print 0 ''
		bash_object.trace_print 0 "CALL: bash_object.traverse-get: $*"
	fi

	local flag_as_what=
	local -a args=()

	local arg=
	for arg; do case $arg in
	--ref)
		if [ -n "$flag_as_what" ]; then
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Flags '--ref' and '--value' are mutually exclusive"
			return
		fi
		flag_as_what='as-ref'
		;;
	--value)
		if [ -n "$flag_as_what" ]; then
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Flags '--ref' and '--value' are mutually exclusive"
			return
		fi
		flag_as_what='as-value'
		;;
	--)
		break
		;;
	*)
		args+=("$arg")
		;;
	esac done; unset -v arg

	if [ -z "$flag_as_what" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Must pass either the '--ref' or '--value' flag"
		return
	fi

	# Ensure correct number of arguments have been passed
	if (( ${#args[@]} != 3)); then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Expected 3 arguments, but received ${#args[@]}"
		return
	fi

	# Ensure parameters are not empty
	if [ -z "${args[0]}" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Positional parameter 1 is empty. Please check passed parameters"
		return
	fi
	if [ -z "${args[1]}" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Positional parameter 2 is empty. Please check passed parameters"
		return
	fi
	if [ -z "${args[2]}" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Positional parameter 3 is empty. Please check passed parameters"
		return
	fi

	local final_value_type="${args[0]}"
	local root_object_name="${args[1]}"
	local querytree="${args[2]}"

	# Start traversing at the root object
	local current_object_name="$root_object_name"
	local -n __current_object="$root_object_name"

	# A stack of all the evaluated querytree elements
	# local -a querytree_stack=()

	# Parse the querytree, and recurse over their elements
	case "$querytree" in
		*']'*) bash_object.parse_querytree --advanced "$querytree" ;;
		*) bash_object.parse_querytree --simple "$querytree" ;;
	esac
	local i=
	for ((i=0; i<${#REPLIES[@]}; i++)); do
		local key="${REPLIES[$i]}"

		local is_index_of_array='no'
		if [ "${key::1}" = $'\x1C' ]; then
			key="${key#?}"
			is_index_of_array='yes'
		fi

		# querytree_stack+=("$key")
		# bash_object.util.generate_querytree_stack_string
		# local querytree_stack_string="$REPLY"

		bash_object.trace_loop

		# If 'key' is not a member of object or index of array, error
		if [ -z "${__current_object[$key]+x}" ]; then
			bash_object.util.die 'ERROR_NOT_FOUND' "Key or index '$key' (querytree index '$i') does not exist"
			return
		# If 'key' is a member of an object or index of array
		else
			local key_value="${__current_object[$key]}"

			# If 'key_value' is a virtual object, dereference it
			if [ "${key_value::2}" = $'\x1C\x1D' ]; then
				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					bash_object.trace_print 2 "BLOCK: OBJECT/ARRAY"
				fi

				local old_current_object_name="$current_object_name"

				virtual_item="${key_value#??}"
				bash_object.parse_virtual_object "$virtual_item"
				local current_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"
				local -n __current_object="$current_object_name"

				if [ -n "${VERIFY_BASH_OBJECT+x}" ]; then
					# Ensure the 'final_value' is the same type as specified by the user (WET)
					local __current_object_type=
					if ! __current_object_type="$(declare -p "$current_object_name" 2>/dev/null)"; then
						bash_object.util.die 'ERROR_INTERNAL' "The variable '$current_object_name' does not exist"
						return
					fi
					__current_object_type="${__current_object_type#declare -}"
					case "${__current_object_type::1}" in
						A) __current_object_type='object' ;;
						a) __current_object_type='array' ;;
						-) __current_object_type='string' ;;
						*) __current_object_type='other' ;;
					esac
					case "$vmd_dtype" in
					object)
						if [ "$__current_object_type" != object ]; then
							bash_object.util.die 'ERROR_VOBJ_INCORRECT_TYPE' "Virtual object has a reference of type '$vmd_dtype', but when dereferencing, a variable of type '$__current_object_type' was found"
							return
						fi
						;;
					array)
						if [ "$__current_object_type" != array ]; then
							bash_object.util.die 'ERROR_VOBJ_INCORRECT_TYPE' "Virtual object has a reference of type '$vmd_dtype', but when dereferencing, a variable of type '$__current_object_type' was found"
							return
						fi
						;;
					*)
						bash_object.util.die 'ERROR_VOBJ_INVALID_TYPE' "Unexpected vmd_dtype '$vmd_dtype'"
						return
						;;
					esac
				fi

				# Ensure no circular references (WET)
				if [ "$old_current_object_name" = "$current_object_name" ]; then
					bash_object.util.die 'ERROR_SELF_REFERENCE' "Virtual object '$current_object_name' cannot reference itself"
					return
				fi

				if ((i+1 < ${#REPLIES[@]})); then
					# Do nothing, and continue to next element in query. We already check for the
					# validity of the virtual object above, so no need to do anything here
					:
				elif ((i+1 == ${#REPLIES[@]})); then
					# We are last element of query, return the object
					if [ "$final_value_type" = object ]; then
						case "$vmd_dtype" in
						object)
							if [ "$flag_as_what" = 'as-value' ]; then
								declare -gA REPLY=()
								local key=
								for key in "${!__current_object[@]}"; do
									REPLY["$key"]="${__current_object[$key]}"
								done
							elif [ "$flag_as_what" = 'as-ref' ]; then
								bash_object.util.die 'ERROR_INTERNAL' "--ref not implemented"
								return
								# declare -gn REPLY="$current_object_name"
							else
								bash_object.util.die 'ERROR_INTERNAL' "Unexpected flag_as_what '$flag_as_what'"
								return
							fi
							;;
						array)
							bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Queried for object, but found existing $vmd_dtype"
							return
							;;
						*)
							bash_object.util.die 'ERROR_VOBJ_INVALID_TYPE' "Unexpected vmd_dtype '$vmd_dtype'"
							return
							;;
						esac
					elif [ "$final_value_type" = array ]; then
						case "$vmd_dtype" in
						object)
							bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Queried for array, but found existing $vmd_dtype"
							return
							;;
						array)
							if [ "$flag_as_what" = 'as-value' ]; then
								declare -ga REPLY=()
								# shellcheck disable=SC2190
								REPLY=("${__current_object[@]}")
							elif [ "$flag_as_what" = 'as-ref' ]; then
								bash_object.util.die 'ERROR_INTERNAL' "--ref not implemented"
								return
							else
								bash_object.util.die 'ERROR_INTERNAL' "Unexpected flag_as_what '$flag_as_what'"
								return
							fi
							;;
						*)
							bash_object.util.die 'ERROR_VOBJ_INVALID_TYPE' "Unexpected vmd_dtype '$vmd_dtype'"
							return
							;;
						esac
					elif [ "$final_value_type" = string ]; then
						case "$vmd_dtype" in
						object)
							bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Queried for string, but found existing $vmd_dtype"
							return
							;;
						array)
							bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Queried for string, but found existing $vmd_dtype"
							return
							;;
						*)
							bash_object.util.die 'ERROR_VOBJ_INVALID_TYPE' "Unexpected vmd_dtype '$vmd_dtype'"
							return
						esac
					else
						bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "Unexpected final_value_type '$final_value_type'"
						return
					fi
				fi
			# Otherwise, 'key_value' is a string
			else
				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					bash_object.trace_print 2 "BLOCK: STRING"
				fi

				if ((i+1 < ${#REPLIES[@]})); then
					bash_object.util.die 'ERROR_NOT_FOUND' "The passed querytree implies that '$key' accesses an object or array, but a string with a value of '$key_value' was found instead"
					return
				elif ((i+1 == ${#REPLIES[@]})); then
					local value="${__current_object[$key]}"
					if [ "$final_value_type" = object ]; then
						bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Queried for $final_value_type, but found existing string '$value'"
						return
					elif [ "$final_value_type" = array ]; then
						bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Queried for $final_value_type, but found existing string '$value'"
						return
					elif [ "$final_value_type" = string ]; then
						if [ "$flag_as_what" = 'as-value' ]; then
							# shellcheck disable=SC2178
							REPLY="$value"
						elif [ "$flag_as_what" = 'as-ref' ]; then
							bash_object.util.die 'ERROR_INTERNAL' "--ref not implemented"
							return
						else
							bash_object.util.die 'ERROR_INTERNAL' "Unexpected flag_as_what '$flag_as_what'"
							return
						fi

					fi
				fi
			fi
		fi

		bash_object.trace_current_object
		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			bash_object.trace_print 0 "END BLOCK"
		fi
	done; unset i
}
