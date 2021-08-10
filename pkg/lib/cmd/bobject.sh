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
			if (($# != 2)); then
				printf '%s\n' "bash-object: Error: Incorrect arguments for subcommand '$subcmd'"
				exit 1
			fi

			bash_object.traverse get string "$@"
			;;
		get-array)
			if (($# != 2)); then
				printf '%s\n' "bash-object: Error: Incorrect arguments for subcommand '$subcmd'"
				exit 1
			fi

			bash_object.traverse get array "$@"
			;;
		get-object)
			if (($# != 2)); then
				printf '%s\n' "bash-object: Error: Incorrect arguments for subcommand '$subcmd'"
				exit 1
			fi

			bash_object.traverse get object "$@"
			;;
		set-string)
			if (($# != 3)); then
				printf '%s\n' "bash-object: Error: Incorrect arguments for subcommand '$subcmd'"
				exit 1
			fi

			bash_object.traverse set string "$@"
			;;
		set-array)
			if (($# != 3)); then
				printf '%s\n' "bash-object: Error: Incorrect arguments for subcommand '$subcmd'"
				exit 1
			fi

			bash_object.traverse set array "$@"
			;;
		set-object)
			if (($# != 3)); then
				printf '%s\n' "bash-object: Error: Incorrect arguments for subcommand '$subcmd'"
				exit 1
			fi

			bash_object.traverse set object "$@"
			;;
		*)
			printf '%s\n' "bash-object: Error: Subcommand '$subcmd' not recognized"
			exit 1
	esac
}
