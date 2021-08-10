# shellcheck shell=bash

source "$BASH_OBJECT_LIB_DIR/util/util.sh"
for f in "$BASH_OBJECT_LIB_DIR"/{,util/}?*.sh; do
	source "$f"
done

bobject() {
	local subcmd="$1"
	shift

	case "$subcmd" in
		get-string)
			bash_object.traverse get string "$@"
			;;
		get-array)
			bash_object.traverse get array "$@"
			;;
		get-object)
			bash_object.traverse get object "$@"
			;;
		set-string)
			bash_object.traverse set string "$@"
			;;
		set-array)
			bash_object.traverse set array "$@"
			;;
		set-object)
			bash_object.traverse set object "$@"
			;;
		*)
			echo "Incorrect subcommand"
			exit 1
	esac
}
