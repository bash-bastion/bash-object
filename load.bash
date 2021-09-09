# shellcheck shell=bash

# TODO: autogen by basalt
if [ -z "$BASALT_PACKAGE_PATH" ]; then
	if [ "${BASH_SOURCE[0]::1}" = / ]; then
		BASALT_PACKAGE_PATH="${BASH_SOURCE[0]%/*}"
	else
		BASALT_PACKAGE_PATH="$(CDPATH=; cd "${BASH_SOURCE[0]%/*}" &>/dev/null; printf "$PWD")"
	fi
fi

for f in "$BASALT_PACKAGE_PATH"/pkg/lib/{,source/,util/}?*.sh; do
	source "$f"
done
