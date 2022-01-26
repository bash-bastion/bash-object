# shellcheck shell=bash

bobject.unset() {
	local object_name="$1"

	if [ -z "$object_name" ]; then
		bash_object.util.die 'ERROR_ARGUMENTS_INVALID' 'Positional parameter 1 is empty. Please check passed parameters'
		return
	fi

	if declare -p "$object_name" &>/dev/null; then :; else
		bash_object.util.die 'ERROR_NOT_FOUND' "The variable '$object_name' does not exist"
		return
	fi

	bash_object.util.unset "$object_name"
}
