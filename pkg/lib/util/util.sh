# shellcheck shell=bash

bash_object.util.die() {
	if [[ -n "$*" ]]; then
		bash_args.util.log_error "$*. Exiting"
	else
		bash_args.util.log_error "Exiting"
	fi

	if [[ -v PS1 || $- = *i* ]]; then
		return 1
	fi

	exit 1
}

bash_object.util.log_info() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Info: $*"
	else
		printf "\033[0;34m%s\033[0m\n" "Info: $*"
	fi
}

bash_object.util.log_warn() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Warn: $*"
	else
		printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
	fi
}

bash_object.util.log_error() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Error: $*"
	else
		printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
	fi
}
