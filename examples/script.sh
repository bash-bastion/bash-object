#!/usr/bin/env bash
set -eo pipefail

# Necessary for Basalt to load dependencies
eval "$(basalt-package-init)"
basalt.package-init
basalt.package-load


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
