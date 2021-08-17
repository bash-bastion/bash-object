# shellcheck shell=bash

# @description Convert a user string into an array representing successive
# object / array access
# @exitcode 1 Miscellaneous error
# @exitcode 2 Parsing error
bash_object.parse_filter() {
	declare -ga REPLIES=()

	local flag_parser_type=

	for arg; do
		case "$arg" in
		-s|--simple)
			flag_parser_type='simple'
			shift
			;;
		-a|--advanced)
			flag_parser_type='advanced'
			shift
			;;
		esac
	done

	local filter="$1"

	if [ "$flag_parser_type" = 'simple' ]; then
		if [ "${filter::1}" != . ]; then
			bash_object.util.die 'ERROR_INVALID_FILTER' 'Filter must begin with a dot'
			return
		fi

		local old_ifs="$IFS"; IFS=.
		for key in $filter; do
			if [ -z "$key" ]; then
				continue
			fi

			REPLIES+=("$key")
		done
		IFS="$old_ifs"
	elif [ "$flag_parser_type" = 'advanced' ]; then
		declare char=
		declare mode='MODE_DEFAULT'
		declare -i PARSER_COLUMN_NUMBER=0

		# Append dot so parsing does not fail at end
		# This makes parsing a lot easier, since it always expects a dot after a ']'
		filter="${filter}."

		# Reply represents an accessor (e.g. 'sub_key')
		local reply=

		while IFS= read -rN1 char; do
			PARSER_COLUMN_NUMBER+=1

			if [ -n "${TRACE_BASH_OBJECT_PARSE+x}" ]; then
				echo "-- $mode: '$char'" >&3
			fi

			case "$mode" in
			MODE_DEFAULT)
				if [ "$char" = . ]; then
					mode='MODE_EXPECTING_BRACKET'
				else
					bash_object.util.die 'ERROR_INVALID_FILTER' 'Filter must begin with a dot'
					return
				fi
				;;
			MODE_BEFORE_DOT)
				if [ "$char" = . ]; then
					mode='MODE_EXPECTING_BRACKET'
				else
					bash_object.util.die 'ERROR_INVALID_FILTER' 'Each part in a filter must be deliminated by a dot'
					return
				fi
				;;
			MODE_EXPECTING_BRACKET)
				if [ "$char" = \[ ]; then
					mode='MODE_EXPECTING_OPENING_STRING_OR_NUMBER'
				elif [ "$char" = $'\n' ]; then
					return
				else
					bash_object.util.die 'ERROR_INVALID_FILTER' 'A dot MUST be followed by an opening bracket in this mode'
					return
				fi
				;;
			MODE_EXPECTING_OPENING_STRING_OR_NUMBER)
				reply=

				if [ "$char" = \" ]; then
					mode='MODE_EXPECTING_STRING'
				elif [ "$char" = ']' ]; then
					bash_object.util.die 'ERROR_INVALID_FILTER' 'Key cannot be empty'
					return
				else
					case "$char" in
					0|1|2|3|4|5|6|7|8|9)
						reply=$'\x1C'"$char"
						mode='MODE_EXPECTING_READ_NUMBER'
						;;
					*)
						bash_object.util.die 'ERROR_INVALID_FILTER' 'A number or opening quote must follow an open bracket'
						return
						;;
					esac
				fi
				;;
			MODE_EXPECTING_STRING)
				if [ "$char" = \\ ]; then
					mode='MODE_STRING_ESCAPE_SEQUENCE'
				elif [ "$char" = \" ]; then
					if [ -z "$reply" ]; then
						bash_object.util.die 'ERROR_INVALID_FILTER' 'Key cannot be empty'
						return
					fi

					REPLIES+=("$reply")
					mode='MODE_EXPECTING_CLOSING_BRACKET'
				elif [ "$char" = $'\n' ]; then
					bash_object.util.die 'ERROR_INVALID_FILTER' 'Filter is not complete'
					return
				else
					reply+="$char"
				fi
				;;
			MODE_STRING_ESCAPE_SEQUENCE)
				case "$char" in
					\\) reply+=\\ ;;
					\") reply+=\" ;;
					']') reply+=']' ;;
					*)
						bash_object.util.die 'ERROR_INVALID_FILTER' "Escape sequence of '$char' not valid"
						return
						;;
				esac
				mode='MODE_EXPECTING_STRING'
				;;
			MODE_EXPECTING_READ_NUMBER)
				if [ "$char" = ']' ]; then
					REPLIES+=("$reply")
					mode='MODE_BEFORE_DOT'
				else
					case "$char" in
					0|1|2|3|4|5|6|7|8|9)
						reply+="$char"
						;;
					*)
						bash_object.util.die 'ERROR_INVALID_FILTER' "Expecting number, found '$char'"
						return
						;;
					esac
				fi
				;;
			MODE_EXPECTING_CLOSING_BRACKET)
				if [ "$char" = ']' ]; then
					mode='MODE_BEFORE_DOT'
				else
					bash_object.util.die 'ERROR_INVALID_FILTER' 'Expected a closing bracket after the closing quotation mark'
					return
				fi
				;;
			esac
		done <<< "$filter"
	else
		bash_object.util.die 'ERROR_INVALID_ARGS' "Must pass either '--simple' or '--advanced'"
		return
	fi
}

# @description Parse a virtual object into its components
bash_object.parse_virtual_object() {
	REPLY1=; REPLY2=
	local virtual_object="$1"

	local virtual_metadatas="${virtual_object%%&*}" # type=string;attr=smthn;
	local virtual_object_name="${virtual_object#*&}" # __bash_object_383028

	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 2 "virtual_object: '$virtual_object'"
		stdtrace.log 2 "virtual_metadatas: '$virtual_metadatas'"
		stdtrace.log 2 "virtual_object_name: '$virtual_object_name'"
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
			stdtrace.log 2 "vmd: '$vmd'"
			stdtrace.log 3 "vmd_key: '$vmd_key'"
			stdtrace.log 3 "vmd_value: '$vmd_value'"
		fi

		case "$vmd_key" in
			type) vmd_dtype="$vmd_value" ;;
		esac
	done <<< "$virtual_metadatas"

	REPLY1="$virtual_object_name"
	REPLY2="$vmd_dtype"
}
