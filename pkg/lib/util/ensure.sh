# shellcheck shell=bash

# TODO: double-check if new_current_object_name only has underscores, dots, etc. (printf %q?)
bash_object.ensure.variable_is_valid() {
	return 0
}

# @description Ensure the variable already exists
bash_object.ensure.variable_does_exist() {
	local variable_name="$1"

	if [ -z "$variable_name" ]; then
		bash_object.util.die "ERROR_INTERNAL" "Parameter to function 'bash_object.ensure.variable_does_exist' was empty"
		return
	fi

	if ! declare -p "$variable_name" &>/dev/null; then
		bash_object.util.die 'ERROR_INTERNAL' "Variable '$variable_name' does not exist, but it should"
		return
	fi
}

# @description Ensure the variable does not exist
bash_object.ensure.variable_does_not_exist() {
	local variable_name="$1"

	if [ -z "$variable_name" ]; then
		bash_object.util.die "ERROR_INTERNAL" "Parameter to function 'bash_object.ensure.variable_does_not_exist' was empty"
		return
	fi

	if bash_object.ensure.variable_does_exist "$1"; then
		bash_object.util.die 'ERROR_INTERNAL' "Variable '$variable_name' exists, but it shouldn't"
		return
	fi
}
