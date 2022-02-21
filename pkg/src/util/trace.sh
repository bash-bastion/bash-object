# shellcheck shell=bash

bash_object.trace_loop() {
	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		bash_object.trace_print 0 "-- START LOOP ITERATION"
		bash_object.trace_print 0 "i+1: '$((i+1))'"
		bash_object.trace_print 0 "\${#REPLIES[@]}: ${#REPLIES[@]}"
		bash_object.trace_print 0 "key: '$key'"
		bash_object.trace_print 0 "current_object_name: '$current_object_name'"
		bash_object.trace_print 0 "current_object=("
		for debug_key in "${!current_object[@]}"; do
			bash_object.trace_print 0 "  [$debug_key]='${current_object[$debug_key]}'"
		done
		bash_object.trace_print 0 ")"
	fi
}

bash_object.trace_current_object() {
	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		bash_object.trace_print 0 "key: '$key'"
		bash_object.trace_print 0 "current_object_name: '$current_object_name'"
		bash_object.trace_print 0 "current_object=("
		for debug_key in "${!current_object[@]}"; do
			bash_object.trace_print 0 "  [$debug_key]='${current_object[$debug_key]}'"
		done
		bash_object.trace_print 0 ")"
	fi
}

bash_object.trace_print() {
	local level="$1"
	local message="$2"

	local padding=
	case "$level" in
		0) padding= ;;
		1) padding="  " ;;
		2) padding="    " ;;
		3) padding="      " ;;
	esac

	printf '%s\n' "TRACE $level: $padding| $message" >&3
}
