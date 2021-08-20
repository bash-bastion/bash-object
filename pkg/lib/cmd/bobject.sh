# shellcheck shell=bash

for f in "$BASH_OBJECT_LIB_DIR"/{,util/}?*.sh; do
	source "$f"
done

bobject() {
	local subcmd="$1"
	shift

	case "$subcmd" in
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
