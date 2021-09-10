# shellcheck shell=bash
set -o pipefail

eval "$(basalt-package-init)"; basalt.package-init
basalt.package-load

load './util/test_util.sh'

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
