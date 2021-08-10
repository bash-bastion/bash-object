# shellcheck shell=bash

source "$BASH_OBJECT_LIB_DIR/util/util.sh"
for f in "$BASH_OBJECT_LIB_DIR"/{,commands/,util/}?*.sh; do
	source "$f"
done

bobject() {
	local subcmd="$1"
	shift

	case "$subcmd" in
		get-string)
			bash_object.traverse 'object-get' "$@"
			;;
		get-array)
			bash_object.traverse 'object-get' "$@"
			;;
		get-object)
			bash_object.traverse 'object-get' "$@"
			;;
		set-string)
			bash_object.traverse 'object-set' "$@"
			;;
		set-array)
			bash_object.traverse 'object-set' "$@"
			;;
		set-object)
			bash_object.traverse 'object-set' "$@"
			;;
		*)
			echo "Incorrect subcommand"
			exit 1
	esac
}
