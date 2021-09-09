# shellcheck shell=bash

# TODO: test for -u and -o pipefail
set -e

basalt-package-init
eval "$(basalt-package-init)"; basalt-package.init
# basalt-package.load_dependencies

load '../load.bash'
load './util/test_util.sh'

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
