# shellcheck shell=bash

bash_object.traverse-set() {
	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 ''
		stdtrace.log 0 "CALL: bash_object.traverse-set: $*"
	fi

	local flag_pass_by_what=
	local -a args=()

	for arg; do case "$arg" in
	--ref)
		if [ -n "$flag_pass_by_what" ]; then
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Flags '--ref' and '--value' are mutually exclusive"
			return
		fi
		flag_pass_by_what='by-ref'
		;;
	--value)
		if [ -n "$flag_pass_by_what" ]; then
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Flags '--ref' and '--value' are mutually exclusive"
			return
		fi
		flag_pass_by_what='by-value'
		;;
	--)
		# All arguments after '--' are in '$@'
		break
		;;
	*)
		args+=("$arg")
		;;
	esac; shift; done

	if [ -z "$flag_pass_by_what" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Must pass either the '--ref' or '--value' flag"
		return
	fi

	if [ "$flag_pass_by_what" = 'by-ref' ]; then
		if (( ${#args[@]} != 4)); then
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Expected 4 arguments (with --ref), but received ${#args[@]}"
			return
		fi
	elif [ "$flag_pass_by_what" = 'by-value' ]; then
		if (( ${#args[@]} != 3)); then
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Expected 3 arguments (with --value) before '--', but received ${#args[@]})"
			return
		fi
	else
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Unexpected final_value_type '$final_value_type'"
		return
	fi

	local final_value_type="${args[0]}"
	local root_object_name="${args[1]}"
	local querytree="${args[2]}"

	# Ensure parameters are not empty
	if [ -z "$final_value_type" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Positional parameter 1 is empty. Please check passed parameters"
		return
	fi
	if [ -z "$root_object_name" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Positional parameter 2 is empty. Please check passed parameters"
		return
	fi
	if [ -z "$querytree" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Positional parameter 3 is empty. Please check passed parameters"
		return
	fi

	# Set final_value after we ensure 'final_value_type' is non-empty
	local final_value=
	if [ "$flag_pass_by_what" = 'by-ref' ]; then
		final_value="${args[3]}"

		if [ -z "$final_value" ]; then
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Positional parameter 4 is empty. Please check passed parameters"
			return
		fi
	elif [ "$flag_pass_by_what" = 'by-value' ]; then
		if [ "$final_value_type" == object ]; then
			local -A temp_var_name="__bash_object_${RANDOM}_$RANDOM"
			local -n temp_var="$temp_var_name"
			if [ "$1" != -- ]; then
				bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Must pass '--' and the value when using --value"
				return
			fi
			if (( $# & 1 )); then
				bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "When passing --value with set-object, an even number of values must be passed after the '--'"
				return
			fi
			for ((i=0; i<$#; i+2)); do
				temp_var["${!i}"]="${!i+1}"
			done
		elif [ "$final_value_type" == array ]; then
			local -a temp_var_name="__bash_object_${RANDOM}_$RANDOM"
			local -n temp_var="$temp_var_name"
			if [ "$1" != -- ]; then
				bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Must pass '--' and the value when using --value"
				return
			fi
			shift
			temp_var=("$@")
			final_value="$temp_var_name"
		elif [ "$final_value_type" == string ]; then
			local temp_var_name="__bash_object_${RANDOM}_$RANDOM"
			local -n temp_var="$temp_var_name"
			if [ "$1" != -- ]; then
				bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Must pass '--' and the value when using --value"
				return
			fi
			shift

			if (( $# > 1)); then
				bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "When passing --value with set-string, only one value must be passed after the '--'"
				return
			fi
			temp_var="$1"
			final_value="$temp_var_name"
		else
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Unexpected final_value_type '$final_value_type'"
			return
		fi
	else
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Unexpected final_value_type '$final_value_type'"
		return
	fi

	if [ -n "${VERIFY_BASH_OBJECT+x}" ]; then
		# Ensure the root object exists, and is an associative array
		local root_object_type=
		if root_object_type="$(declare -p "$root_object_name" 2>/dev/null)"; then :; else
			bash_object.util.die 'ERROR_NOT_FOUND' "The associative array '$root_object_name' does not exist"
			return
		fi
		root_object_type="${root_object_type#declare -}"
		if [ "${root_object_type::1}" != 'A' ]; then
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "The 'root object' must be an associative array"
			return
		fi

		if [ "$flag_pass_by_what" = 'by-ref' ]; then
			# Ensure the 'final_value' is the same type as specified by the user
			local actual_final_value_type=
			if ! actual_final_value_type="$(declare -p "$final_value" 2>/dev/null)"; then
				bash_object.util.die 'ERROR_NOT_FOUND' "The variable '$final_value' does not exist"
				return
			fi
			actual_final_value_type="${actual_final_value_type#declare -}"
			case "${actual_final_value_type::1}" in
				A) actual_final_value_type='object' ;;
				a) actual_final_value_type='array' ;;
				-) actual_final_value_type='string' ;;
				*) actual_final_value_type='other' ;;
			esac

			if [ "$final_value_type" == object ]; then
				if [ "$actual_final_value_type" != object ]; then
					bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "Argument 'set-$final_value_type' was specified, but a variable with type '$actual_final_value_type' was passed"
					return
				fi
			elif [ "$final_value_type" == array ]; then
				if [ "$actual_final_value_type" != array ]; then
					bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "Argument 'set-$final_value_type' was specified, but a variable with type '$actual_final_value_type' was passed"
					return
				fi
			elif [ "$final_value_type" == string ]; then
				if [ "$actual_final_value_type" != string ]; then
					bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "Argument 'set-$final_value_type' was specified, but a variable with type '$actual_final_value_type' was passed"
					return
				fi
			else
				bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "Unexpected final_value_type '$final_value_type'"
				return
			fi
		fi
	fi

	# Start traversing at the root object
	local current_object_name="$root_object_name"
	local -n current_object="$root_object_name"

	# A stack of all the evaluated querytree elements
	local -a querytree_stack=()

	# Parse the querytree, and recurse over their elements
	case "$querytree" in
		*']'*) bash_object.parse_querytree --advanced "$querytree" ;;
		*) bash_object.parse_querytree --simple "$querytree" ;;
	esac
	for ((i=0; i<${#REPLIES[@]}; i++)); do
		local key="${REPLIES[$i]}"

		local is_index_of_array='no'
		if [ "${key::1}" = $'\x1C' ]; then
			key="${key#?}"
			is_index_of_array='yes'
		fi

		querytree_stack+=("$key")
		bash_object.util.generate_querytree_stack_string
		local querytree_stack_string="$REPLY"

		bash_object.trace_loop

		# If 'key' is not a member of object or index of array, error
		if [ -z "${current_object["$key"]+x}" ]; then
			# If we are before the last element in the query, then error
			if ((i+1 < ${#REPLIES[@]})); then
				bash_object.util.die 'ERROR_NOT_FOUND' "Key or index '$key' (querytree index '$i') does not exist"
				return
			# If we are at the last element in the query, and it doesn't exist, create it
			elif ((i+1 == ${#REPLIES[@]})); then
				if [ "$final_value_type" = object ]; then
					bash_object.util.generate_vobject_name "$root_object_name" "$querytree_stack_string"
					local global_object_name="$REPLY"

					if bash_object.ensure.variable_does_not_exist "$global_object_name"; then :; else
						return
					fi

					if ! declare -gA "$global_object_name"; then
						bash_object.util.die 'ERROR_INTERNAL' 'Eval declare failed'
						return
					fi
					local -n global_object="$global_object_name"
					global_object=()

					current_object["$key"]=$'\x1C\x1D'"type=object;&$global_object_name"

					local -n object_to_copy_from="$final_value"

					for key in "${!object_to_copy_from[@]}"; do
						# shellcheck disable=SC2034
						global_object["$key"]="${object_to_copy_from["$key"]}"
					done
				elif [ "$final_value_type" = array ]; then
					bash_object.util.generate_vobject_name "$root_object_name" "$querytree_stack_string"
					local global_array_name="$REPLY"

					if bash_object.ensure.variable_does_not_exist "$global_array_name"; then :; else
						return
					fi

					if ! eval "declare -ga $global_array_name=()" 2>/dev/null; then
						bash_object.util.die 'ERROR_INTERNAL' 'Eval declare failed'
						return
					fi

					current_object["$key"]=$'\x1C\x1D'"type=array;&$global_array_name"

					local -n global_array="$global_array_name"
					local -n array_to_copy_from="$final_value"

					# shellcheck disable=SC2034
					global_array=("${array_to_copy_from[@]}")
				elif [ "$final_value_type" = string ]; then
					local -n string_to_copy_from="$final_value"
					current_object["$key"]="$string_to_copy_from"
				else
					bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "Unexpected final_value_type '$final_value_type'"
					return
				fi
			fi
		# If 'key' is already a member of object or index of array
		else
			local key_value="${current_object["$key"]}"

			# If 'key_value' is a virtual object, dereference it
			if [ "${key_value::2}" = $'\x1C\x1D' ]; then
				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 2 "BLOCK: OBJECT/ARRAY"
				fi

				local old_current_object_name="$current_object_name"

				virtual_item="${key_value#??}"
				bash_object.parse_virtual_object "$virtual_item"
				local current_object_name="$REPLY1"
				local vmd_dtype="$REPLY2"
				local -n current_object="$current_object_name"

				if [ -n "${VERIFY_BASH_OBJECT+x}" ]; then
					# Ensure the 'final_value' is the same type as specified by the user (WET)
					local current_object_type=
					if ! current_object_type="$(declare -p "$current_object_name" 2>/dev/null)"; then
						bash_object.util.die 'ERROR_INTERNAL' "The variable '$current_object_name' does not exist"
						return
					fi
					current_object_type="${current_object_type#declare -}"
					case "${current_object_type::1}" in
						A) current_object_type='object' ;;
						a) current_object_type='array' ;;
						-) current_object_type='string' ;;
						*) current_object_type='other' ;;
					esac
					case "$vmd_dtype" in
					object)
						if [ "$current_object_type" != object ]; then
							bash_object.util.die 'ERROR_VOBJ_INCORRECT_TYPE' "Virtual object has a reference of type '$vmd_dtype', but when dereferencing, a variable of type '$current_object_type' was found"
							return
						fi
						;;
					array)
						if [ "$current_object_type" != array ]; then
							bash_object.util.die 'ERROR_VOBJ_INCORRECT_TYPE' "Virtual object has a reference of type '$vmd_dtype', but when dereferencing, a variable of type '$current_object_type' was found"
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
					# We are last element of query, but do not set the object there is one that already exists
					if [ "$final_value_type" = object ]; then
						case "$vmd_dtype" in
						object) :;;
						array)
							bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Assigning an $final_value_type, but found existing $vmd_dtype"
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
							bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Assigning an $final_value_type, but found existing $vmd_dtype"
							return
							;;
						array) :;;
						*)
							bash_object.util.die 'ERROR_VOBJ_INVALID_TYPE' "Unexpected vmd_dtype '$vmd_dtype'"
							return
							;;
						esac
					elif [ "$final_value_type" = string ]; then
						case "$vmd_dtype" in
						object)
							bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Assigning an $final_value_type, but found existing $vmd_dtype"
							return
							;;
						array)
							bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Assigning an $final_value_type, but found existing $vmd_dtype"
							return
							;;
						*)
							bash_object.util.die 'ERROR_VOBJ_INVALID_TYPE' "Unexpected vmd_dtype '$vmd_dtype'"
							return
							;;
						esac
					else
						bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "Unexpected final_value_type '$final_value_type'"
						return
					fi
				fi
			# Otherwise, 'key_value' is a string
			else
				if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
					stdtrace.log 2 "BLOCK: STRING"
				fi

				if ((i+1 < ${#REPLIES[@]})); then
					bash_object.util.die 'ERROR_NOT_FOUND' "The passed querytree implies that '$key' accesses an object or array, but a string with a value of '$key_value' was found instead"
					return
				elif ((i+1 == ${#REPLIES[@]})); then
					local value="${current_object["$key"]}"
					if [ "$final_value_type" = object ]; then
						bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Assigning an $final_value_type, but found existing string '$value'"
						return
					elif [ "$final_value_type" = array ]; then
						bash_object.util.die 'ERROR_ARGUMENTS_INCORRECT_TYPE' "Assigning an $final_value_type, but found existing string '$value'"
						return
					elif [ "$final_value_type" = string ]; then
						local -n string_to_copy_from="$final_value"
						current_object["$key"]="$string_to_copy_from"
					else
						bash_object.util.die 'ERROR_ARGUMENTS_INVALID_TYPE' "Unexpected final_value_type '$final_value_type'"
						return
					fi
				fi
			fi
		fi

		bash_object.trace_current_object
		if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
			stdtrace.log 0 "END BLOCK"
		fi
	done
}
