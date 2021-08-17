# shellcheck shell=bash

# TODO: double-check if new_current_object_name only has underscores, dots, etc. (printf %q?)
bash_object.ensure.variable_is_valid() {
	return 0
}

# TODO: swap with does_not
bash_object.ensure.variable_does_exist() {
	if bash_object.ensure.variable_does_not_exist "$1"; then
		bash_object.util.die 'ERROR_INTERNAL_MISCELLANEOUS' "Variable '$1' does not exist, but it should"
		return
	else
		:
	fi
}

# @description Test if the variable already exists. Note that the variable _must_ be sanitized before using this function
bash_object.ensure.variable_does_not_exist() {
	local variable_name="$1"

	if [ -z "$variable_name" ]; then
		bash_object.util.die "ERROR_INTERNAL_MISCELLANEOUS" "Parameter to function 'bash_object.ensure.variable_does_not_exist' was empty"
		return
	fi

	if ((BASH_VERSINFO[0] >= 5)) || ((BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 2)); then
		if [[ -v "$variable_name" ]]; then
			bash_object.util.die 'ERROR_INTERNAL_MISCELLANEOUS' "Variable '$variable_name' exists, but it shouldn't"
			return
		fi
	else
		if ! eval "
			if ! [ -z \${$variable_name+x} ]; then
				bash_object.util.die 'ERROR_INTERNAL_MISCELLANEOUS' \"Variable '$variable_name' exists, but it shouldn't\"
				return
			fi
		"; then
			bash_object.util.die 'ERROR_INTERNAL_MISCELLANEOUS' 'Eval unset test'
			return
		fi
	fi
}
