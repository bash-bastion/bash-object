# shellcheck shell=bash

bash_object.filter_parse() {
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

	declare -ga REPLIES=()

	if [ "$flag_parser_type" = 'simple' ]; then
		if [ "${filter::1}" != . ]; then
			printf '%s\n' "Error: bash-object: Filter must begin with a dot"
			return 1
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

		# Reply represents an accessor (e.g. 'sub_key')
		local reply=

		while IFS= read -rN1 char; do
			PARSER_COLUMN_NUMBER+=1
			echo "-- $mode > '$char'" >&3
			case "$mode" in
			MODE_DEFAULT)
				if [ "$char" = . ]; then
					mode='MODE_EXPECTING_BRACKET'
				else
					printf '%s\n' "Error: bash-object: Filter must begin with a dot"
					return 1
				fi
				;;
			MODE_DEFAULT_2)
				# if [ "$is_at_end" = 'yes' ]; then
					# continue
				# fi

				if [ "$char" = . ]; then
					mode='MODE_EXPECTING_BRACKET'
				else
					:
					# printf '%s\n' "Error: bash-object: Each part in a filter must be deliminated by a dot"
					# return 1
				fi
				;;
			MODE_EXPECTING_BRACKET)
				if [ "$char" = \[ ]; then
					mode='MODE_EXPECTING_OPENING_STRING_OR_NUMBER'
				else
					printf '%s\n' "Error: bash-object: A dot MUST be followed by an opening bracket in this mode"
					return 1
				fi
				;;
			MODE_EXPECTING_OPENING_STRING_OR_NUMBER)
				reply=

				if [ "$char" = \" ]; then
					mode='MODE_EXPECTING_STRING'
				else
					case "$char" in
					0|1|2|3|4|5|6|7|8|9)
						reply=$'\x1C'"$char"
						mode='MODE_EXPECTING_READ_NUMBER'
						;;
					*)
						printf '%s\n' "Error: bash-object: A number or opening quote must follow an open bracket"
						exit 1
						;;
					esac
				fi
				;;
			MODE_EXPECTING_STRING)
				if [ "$char" = \\ ]; then
					mode='MODE_STRING_ESCAPE_SEQUENCE'
				elif [ "$char" = \" ]; then
					REPLIES+=("$reply")
					mode='EXPECTING_CLOSING_BRACKET'
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
						printf '%s\n' "Error: bash-object: Escape sequence of '$char' not valid"
						exit 1
						;;
				esac
				mode='MODE_EXPECTING_STRING'
				;;
			MODE_EXPECTING_READ_NUMBER)
				if [ "$char" = ']' ]; then
					REPLIES+=("$reply")
					mode='MODE_DEFAULT_2'
					is_at_end='yes'
				else
					case "$char" in
					0|1|2|3|4|5|6|7|8|9)
						reply+="$char"
						;;
					*)
						printf '%s\n' "Error: bash-object: Expecting number, found '$char'"
						exit 1
						;;
					esac
				fi
				;;
			EXPECTING_CLOSING_BRACKET)
				if [ "$char" = ']' ]; then
					mode='MODE_DEFAULT_2'
					is_at_end='yes'
				else
					printf '%s\n' "Error: bash-object: Expected a closing bracket after the closing quotation mark"
					exit 1
				fi
				;;
			esac
		done <<< "$filter"
	else
		printf '%s\n' "bash-object: Must choose simple or advanced; no current default established"
		return 1
	fi
}
