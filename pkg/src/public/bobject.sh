# shellcheck shell=bash

bobject() {
	local subcmd="$1"
	if ! shift; then
		bash_object.util.die 'ERROR_INTERNAL' 'Shift failed, but was expected to succeed'
		return
	fi

	case $subcmd in
		get-string)
			bash_object.traverse-get string "$@"
			;;
		get-array)
			bash_object.traverse-get array "$@"
			;;
		get-object)
			bash_object.traverse-get object "$@"
			;;
		set-string)
			bash_object.traverse-set string "$@"
			;;
		set-array)
			bash_object.traverse-set array "$@"
			;;
		set-object)
			bash_object.traverse-set object "$@"
			;;
		*)
			bash_object.util.die 'ERROR_ARGUMENTS_INVALID' "Subcommand '$subcmd' not recognized"
			return
	esac
}
