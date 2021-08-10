# shellcheck shell=bash

load './util/test_util.sh'

source bpm-load
bpm-load 'ztombol/bats-support'
bpm-load 'ztombol/bats-assert'

ROOT_DIR="$(realpath "${BASH_SOURCE[0]}")"
ROOT_DIR="${ROOT_DIR%/*}"; ROOT_DIR="${ROOT_DIR%/*}"; ROOT_DIR="${ROOT_DIR%/*}"

export PATH="$ROOT_DIR/pkg/bin:$PATH"
for f in "$ROOT_DIR"/pkg/lib/{,util}/?*.sh; do
	# shellcheck disable=SC1090
	source "$f"
done
source 'bobject'

setup() {
	unset TOML
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
