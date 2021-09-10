# shellcheck shell=bash

basalt_load() {
	for f in "$BASALT_PACKAGE_PATH"/pkg/lib/{,source/,util/}?*.sh; do
		source "$f"
	done; unset f
}
