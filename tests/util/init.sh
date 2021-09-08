# shellcheck shell=bash

set -e

# TODO: only do once
eval "$(basalt global init bash)"

load './util/test_util.sh'

basalt-load 'github.com/ztombol/bats-support'
basalt-load 'github.com/ztombol/bats-assert'

# TODO
ROOT_DIR="$(realpath "${BASH_SOURCE[0]}")"
ROOT_DIR="${ROOT_DIR%/*}"; ROOT_DIR="${ROOT_DIR%/*}"; ROOT_DIR="${ROOT_DIR%/*}"

export PATH="$ROOT_DIR/pkg/bin:$PATH"
for f in "$ROOT_DIR"/pkg/lib/{,util}/?*.sh; do
	# shellcheck disable=SC1090
	source "$f"
done
source 'bobject'

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
