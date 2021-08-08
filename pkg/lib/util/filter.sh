# shellcheck shell=bash

bash_object.filter_parse() {
	local filter="$1"

	declare -ga REPLIES=()
	local old_ifs="$IFS"

	IFS=.
	for key in $filter; do
		if [ -z "$key" ]; then
			continue
		fi

		REPLIES+=("$key")
	done
	IFS="$old_ifs"
}
