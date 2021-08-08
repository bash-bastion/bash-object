# shellcheck shell=bash

source "$BASH_OBJECT_LIB_DIR/util/util.sh"
for f in "$BASH_OBJECT_LIB_DIR"/{commands,util}/?*.sh; do
	source "$f"
done

bobject() {
	local subcmd="$1"
	shift

	case "$subcmd" in
		set)
			bash_object.do-object-set "$@"
			;;
		get)
			bash_object.do-object-get "$@"
			;;
		*)
			echo "Incorrect subcommand"
			exit 1
	esac
}
