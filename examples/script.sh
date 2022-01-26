#!/usr/bin/env bash
set -eo pipefail

lsobj() {
	local -i count=0
	while IFS= read -r line || [ -n "$line" ]; do
		((++count))
		if [[ $line =~ ^__bash_object ]]; then
			printf '%s\n' "$line"
		fi

	done < <(set -o posix; set); unset line

	printf 'COUNT: %d\n' "$count"
}

# Necessary for Basalt to load dependencies
eval "$(basalt-package-init)"
basalt.package-init
basalt.package-load

lsobj

declare -A root_object=()
declare -A zulu_object=()
declare -A yankee_object=()
declare -A xray_object=([whiskey]=victor)
declare -a foxtrot_array=(omicron pi rho sigma)

bobject set-object --ref root_object '.zulu' zulu_object
bobject set-object --ref root_object '.zulu.yankee' yankee_object
bobject set-object --ref root_object '.zulu.yankee.xray' xray_object
bobject set-array --ref root_object '.zulu.yankee.xray.foxtrot' foxtrot_array

bobject get-object --value root_object '.zulu.yankee.xray'
printf '%s - %s\n' "${REPLY[whiskey]}" victor

bobject get-string --value root_object '.zulu.yankee.xray.whiskey'
printf '%s - %s\n' "$REPLY" victor

bobject get-array --value root_object '.zulu.yankee.xray.foxtrot'
printf '%d - %d\n' ${#REPLY[@]} 4

bobject get-string --value root_object '.["zulu"].["yankee"].["xray"].["foxtrot"].[2]'
printf '%s - %s\n' "$REPLY" rho

bobject.print 'root_object'

bobject.unset 'root_object'

lsobj
