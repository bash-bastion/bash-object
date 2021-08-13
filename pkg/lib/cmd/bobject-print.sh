# shellcheck shell=bash

for f in "$BASH_OBJECT_LIB_DIR"/{,util/}?*.sh; do
	source "$f"
done

bobject-print() {
	:
}
