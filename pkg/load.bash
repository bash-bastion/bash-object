# shellcheck shell=bash

# TODO: autogen by basalt?

if [ -z "$BASALT_PACKAGE_PATH" ]; then
	if [ "${BASH_SOURCE[0]::1}" = / ]; then
		BASALT_PACKAGE_PATH="${BASH_SOURCE[0]}"
	elif command -v greadlink &>/dev/null; then
		BASALT_PACKAGE_PATH="$(greadlink -f "${BASH_SOURCE[0]}")"
	elif command -v realfile &>/dev/null; then
		BASALT_PACKAGE_PATH="$(realfile "${BASH_SOURCE[0]}")"
	elif command -v readlink &>/dev/null; then
		BASALT_PACKAGE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
	fi

	BASALT_PACKAGE_PATH="${BASALT_PACKAGE_PATH%/*}"
	BASALT_PACKAGE_PATH="${BASALT_PACKAGE_PATH%/*}"
fi

for f in "$BASALT_PACKAGE_PATH"/pkg/lib/{,source/,util/}?*.sh; do
	source "$f"
done
