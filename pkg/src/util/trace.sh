# shellcheck shell=bash

bash_object.trace_loop() {
	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 "-- START LOOP ITERATION"
		stdtrace.log 0 "i+1: '$((i+1))'"
		stdtrace.log 0 "\${#REPLIES[@]}: ${#REPLIES[@]}"
		stdtrace.log 0 "key: '$key'"
		stdtrace.log 0 "current_object_name: '$current_object_name'"
		stdtrace.log 0 "current_object=("
		for debug_key in "${!current_object[@]}"; do
			stdtrace.log 0 "  [$debug_key]='${current_object[$debug_key]}'"
		done
		stdtrace.log 0 ")"
	fi
}

bash_object.trace_current_object() {
	if [ -n "${TRACE_BASH_OBJECT_TRAVERSE+x}" ]; then
		stdtrace.log 0 "key: '$key'"
		stdtrace.log 0 "current_object_name: '$current_object_name'"
		stdtrace.log 0 "current_object=("
		for debug_key in "${!current_object[@]}"; do
			stdtrace.log 0 "  [$debug_key]='${current_object[$debug_key]}'"
		done
		stdtrace.log 0 ")"
	fi
}
