# shellcheck shell=bash

# TODO: test for -u and -o pipefail
set -e

load '../pkg/load.bash'
load './util/test_util.sh'

eval "$(basalt global init bash)"
basalt-load 'github.com/ztombol/bats-support'
basalt-load 'github.com/ztombol/bats-assert'

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
